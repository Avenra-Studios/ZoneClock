.pragma library

// Single source of truth for timezone identifiers used by Zone Clock.
//
// Two independent modes are supported, chosen per clock:
//
// - "offset": a fixed UTC offset (UTC, UTC+1, UTC-5, etc), computed
//   with plain date-math against a stored minutes-from-UTC value.
//   Never observes daylight saving - a fixed offset has none by
//   definition.
//
// - "iana": a real IANA timezone id (e.g. "America/New_York"), with
//   daylight saving applied automatically where the city observes it.
//
//   This used to be resolved with Intl.DateTimeFormat's "timeZone"
//   option, which is the normal way to do this in JavaScript - but
//   Plasma's QML JS engine frequently doesn't ship the ICU timezone
//   database that option depends on, and throws for every id, valid
//   ones included, rather than just unrecognized ones. That made
//   Country/City mode show "Invalid TZ" unconditionally on affected
//   systems. So daylight saving here is computed directly instead:
//   each curated zone below carries its own standard UTC offset plus
//   (if it observes DST) a rule describing when it switches. This
//   has no dependency on Intl/ICU at all, so it works the same way
//   offset-mode does - it just cannot resolve zones outside the
//   curated list.
//
//   DST rules do change over time by national decree (several zones
//   below abolished or reinstated DST within the last few years) -
//   this reflects each country's practice as of 2026 and may need
//   updating if a country changes its policy again.

function buildZones() {
    var list = []

    // Real-world UTC offsets run from -12:00 to +14:00.
    for (var offset = -12; offset <= 14; offset++) {
        var id = offset === 0 ? "UTC" : "UTC" + (offset > 0 ? "+" : "-") + Math.abs(offset)
        list.push({ display: id, tzdata: id, offsetMinutes: offset * 60 })
    }

    return list
}

var zones = buildZones()

// Case-insensitive lookup by id against the canonical offset list.
function isKnownZone(tzId) {
    return findZone(tzId) !== null
}

function findZone(tzId) {
    if (!tzId || tzId.length === 0) {
        return null
    }

    var needle = tzId.toLowerCase()

    for (var i = 0; i < zones.length; i++) {
        if (zones[i].tzdata.toLowerCase() === needle) {
            return zones[i]
        }
    }

    return null
}

// Offset in minutes for a given zone id. Defaults to 0 (UTC) for an
// unrecognized id (e.g. a value saved by an older version of this
// widget) rather than failing - there is no "invalid" state here.
function offsetMinutesForId(tzId) {
    var zone = findZone(tzId)
    return zone ? zone.offsetMinutes : 0
}

// --- Daylight saving rules for "iana" mode ---
//
// A rule describes the two clock-change instants in terms of "the
// nth given weekday of a given month, at a given local clock hour" -
// the way almost every country's law actually states it - plus
// whether that hour is read against standard or daylight time and
// whether the DST period wraps across a calendar year (Southern
// Hemisphere summers span Oct-Apr, not Mar-Nov).
//
// weekday: 0=Sunday .. 6=Saturday. n: 1st/2nd/... occurrence, or -1
// for "last". utcBasis: true means the transition is defined as a
// fixed UTC instant rather than a local clock reading (the EU's is:
// 01:00 UTC on the day, for every EU zone at once).
var DST_RULES = {
    // US & Canada: 2nd Sunday of March 02:00 standard -> 1st Sunday
    // of November 02:00 daylight.
    us: { startMonth: 2, startN: 2, startWeekday: 0, startHour: 2,
          endMonth: 10, endN: 1, endWeekday: 0, endHour: 2 },

    // EU (and UK/Ireland, which happen to share the same weekends):
    // last Sunday of March 01:00 UTC -> last Sunday of October
    // 01:00 UTC, the same instant for every zone.
    eu: { startMonth: 2, startN: -1, startWeekday: 0, startHour: 1,
          endMonth: 9, endN: -1, endWeekday: 0, endHour: 1, utcBasis: true },

    // Australia (NSW/VIC/SA/TAS/ACT only - WA/QLD/NT don't observe
    // DST, handled by giving those zones no rule at all): 1st Sunday
    // of October 02:00 standard -> 1st Sunday of April 03:00 daylight.
    au: { startMonth: 9, startN: 1, startWeekday: 0, startHour: 2,
          endMonth: 3, endN: 1, endWeekday: 0, endHour: 3, wrap: true },

    // New Zealand: last Sunday of September 02:00 standard -> 1st
    // Sunday of April 03:00 daylight.
    nz: { startMonth: 8, startN: -1, startWeekday: 0, startHour: 2,
          endMonth: 3, endN: 1, endWeekday: 0, endHour: 3, wrap: true },

    // Egypt (reinstated 2023): last Friday of April midnight standard
    // -> last Friday of October midnight daylight.
    egypt: { startMonth: 3, startN: -1, startWeekday: 5, startHour: 0,
             endMonth: 9, endN: -1, endWeekday: 5, endHour: 0 },

    // Chile (mainland): 1st Sunday of September midnight standard ->
    // 1st Sunday of April midnight daylight. Set by annual decree,
    // so future years could shift slightly from this.
    chile: { startMonth: 8, startN: 1, startWeekday: 0, startHour: 0,
             endMonth: 3, endN: 1, endWeekday: 0, endHour: 0, wrap: true }

    // Israel's rule ("the Friday before the last Sunday of March" to
    // "the last Sunday of October") doesn't fit this nth-weekday
    // shape and is handled separately in israelIsDst() below.
}

// Returns the day-of-month (1-31) of the nth occurrence of a weekday
// in a given UTC month, or the last occurrence if n is -1.
function nthWeekdayOfMonthUTC(year, month, weekday, n) {
    if (n > 0) {
        var firstWeekday = new Date(Date.UTC(year, month, 1)).getUTCDay()
        var offset = (weekday - firstWeekday + 7) % 7
        return 1 + offset + (n - 1) * 7
    }

    var lastDayOfMonth = new Date(Date.UTC(year, month + 1, 0)).getUTCDate()
    var lastWeekday = new Date(Date.UTC(year, month, lastDayOfMonth)).getUTCDay()
    return lastDayOfMonth - ((lastWeekday - weekday + 7) % 7)
}

// UTC instant (ms) of a rule's transition in a given year, given the
// UTC offset (in minutes) that the rule's local-time reading is
// against - the standard offset for a "spring forward" edge, the
// daylight offset for a "fall back" edge (see DST_RULES comments).
function transitionMillisUTC(year, month, n, weekday, hour, basisOffsetMinutes) {
    var day = nthWeekdayOfMonthUTC(year, month, weekday, n)
    return Date.UTC(year, month, day, hour, 0, 0) - basisOffsetMinutes * 60000
}

function ruleWindowForYear(rule, year, standardOffsetMinutes, daylightOffsetMinutes) {
    var startBasis = rule.utcBasis ? 0 : standardOffsetMinutes
    var endBasis = rule.utcBasis ? 0 : daylightOffsetMinutes

    var startMillis = transitionMillisUTC(year, rule.startMonth, rule.startN, rule.startWeekday, rule.startHour, startBasis)
    var endYear = rule.wrap ? year + 1 : year
    var endMillis = transitionMillisUTC(endYear, rule.endMonth, rule.endN, rule.endWeekday, rule.endHour, endBasis)

    return [startMillis, endMillis]
}

// Whether a UTC instant falls within a rule's DST window. For a
// wrapping (Southern Hemisphere) rule the window can belong to
// either "this" local year or the previous one (e.g. an instant in
// January belongs to the window that started the previous October),
// so both are checked.
function isWithinDstRule(rule, utcMillis, standardOffsetMinutes) {
    var daylightOffsetMinutes = standardOffsetMinutes + 60
    var year = new Date(utcMillis).getUTCFullYear()
    var candidateYears = rule.wrap ? [year - 1, year] : [year]

    for (var i = 0; i < candidateYears.length; i++) {
        var window = ruleWindowForYear(rule, candidateYears[i], standardOffsetMinutes, daylightOffsetMinutes)
        if (utcMillis >= window[0] && utcMillis < window[1]) {
            return true
        }
    }

    return false
}

// Israel: DST starts the Friday before the last Sunday of March
// (02:00 standard) and ends the last Sunday of October (02:00
// daylight) - a shape the generic nth-weekday rule can't express.
function israelIsDst(utcMillis, standardOffsetMinutes) {
    var daylightOffsetMinutes = standardOffsetMinutes + 60
    var year = new Date(utcMillis).getUTCFullYear()

    var lastSundayMarch = nthWeekdayOfMonthUTC(year, 2, 0, -1)
    var fridayBeforeMarch = lastSundayMarch - 2
    var startMillis = Date.UTC(year, 2, fridayBeforeMarch, 2, 0, 0) - standardOffsetMinutes * 60000

    var endMillis = transitionMillisUTC(year, 9, -1, 0, 2, daylightOffsetMinutes)

    return utcMillis >= startMillis && utcMillis < endMillis
}

// Effective UTC offset (in minutes) for a curated IANA zone at a
// given instant - its standard offset, or standard+60 if a DST rule
// says the instant falls in daylight time.
function offsetMinutesForIanaZone(zone, utcMillis) {
    if (!zone.dst) {
        return zone.standardOffsetMinutes
    }

    var isDst = zone.dst === "israel"
        ? israelIsDst(utcMillis, zone.standardOffsetMinutes)
        : isWithinDstRule(DST_RULES[zone.dst], utcMillis, zone.standardOffsetMinutes)

    return isDst ? zone.standardOffsetMinutes + 60 : zone.standardOffsetMinutes
}

// A representative set of IANA timezones grouped by country/city, for
// the "Country / City" picker. Not exhaustive (the full IANA database
// has ~400 zones) - one or a few representative cities per country,
// enough to cover every UTC offset and every daylight-saving region
// in normal use. "Etc/UTC" stands in for plain UTC in this list.
//
// standardOffsetMinutes is each zone's non-DST UTC offset; dst names
// an entry in DST_RULES above ("israel" is handled specially), or is
// left unset for a zone that doesn't observe DST at all.
function buildIanaZones() {
    return [
        { display: "UTC — Coordinated Universal Time", tzdata: "Etc/UTC", standardOffsetMinutes: 0 },

        { display: "United States — New York", tzdata: "America/New_York", standardOffsetMinutes: -300, dst: "us" },
        { display: "United States — Chicago", tzdata: "America/Chicago", standardOffsetMinutes: -360, dst: "us" },
        { display: "United States — Denver", tzdata: "America/Denver", standardOffsetMinutes: -420, dst: "us" },
        { display: "United States — Phoenix", tzdata: "America/Phoenix", standardOffsetMinutes: -420 },
        { display: "United States — Los Angeles", tzdata: "America/Los_Angeles", standardOffsetMinutes: -480, dst: "us" },
        { display: "United States — Anchorage", tzdata: "America/Anchorage", standardOffsetMinutes: -540, dst: "us" },
        { display: "United States — Honolulu", tzdata: "Pacific/Honolulu", standardOffsetMinutes: -600 },
        { display: "Canada — Toronto", tzdata: "America/Toronto", standardOffsetMinutes: -300, dst: "us" },
        { display: "Canada — Winnipeg", tzdata: "America/Winnipeg", standardOffsetMinutes: -360, dst: "us" },
        { display: "Canada — Edmonton", tzdata: "America/Edmonton", standardOffsetMinutes: -420, dst: "us" },
        { display: "Canada — Vancouver", tzdata: "America/Vancouver", standardOffsetMinutes: -480, dst: "us" },
        { display: "Canada — Halifax", tzdata: "America/Halifax", standardOffsetMinutes: -240, dst: "us" },
        { display: "Canada — St. John's", tzdata: "America/St_Johns", standardOffsetMinutes: -210, dst: "us" },
        // Mexico abolished DST nationally in 2022, except the Baja
        // California / US-border strip, which still follows the US
        // schedule to stay in sync with its US neighbors.
        { display: "Mexico — Mexico City", tzdata: "America/Mexico_City", standardOffsetMinutes: -360 },
        { display: "Mexico — Tijuana", tzdata: "America/Tijuana", standardOffsetMinutes: -480, dst: "us" },
        // Brazil abolished DST nationally in 2019.
        { display: "Brazil — São Paulo", tzdata: "America/Sao_Paulo", standardOffsetMinutes: -180 },
        { display: "Brazil — Manaus", tzdata: "America/Manaus", standardOffsetMinutes: -240 },
        // Argentina abolished DST in 2009 (fixed -3:00 year-round).
        { display: "Argentina — Buenos Aires", tzdata: "America/Argentina/Buenos_Aires", standardOffsetMinutes: -180 },
        { display: "Chile — Santiago", tzdata: "America/Santiago", standardOffsetMinutes: -240, dst: "chile" },
        { display: "Colombia — Bogotá", tzdata: "America/Bogota", standardOffsetMinutes: -300 },
        { display: "Peru — Lima", tzdata: "America/Lima", standardOffsetMinutes: -300 },
        { display: "Venezuela — Caracas", tzdata: "America/Caracas", standardOffsetMinutes: -240 },

        { display: "United Kingdom — London", tzdata: "Europe/London", standardOffsetMinutes: 0, dst: "eu" },
        { display: "Ireland — Dublin", tzdata: "Europe/Dublin", standardOffsetMinutes: 0, dst: "eu" },
        { display: "Portugal — Lisbon", tzdata: "Europe/Lisbon", standardOffsetMinutes: 0, dst: "eu" },
        { display: "Spain — Madrid", tzdata: "Europe/Madrid", standardOffsetMinutes: 60, dst: "eu" },
        { display: "France — Paris", tzdata: "Europe/Paris", standardOffsetMinutes: 60, dst: "eu" },
        { display: "Belgium — Brussels", tzdata: "Europe/Brussels", standardOffsetMinutes: 60, dst: "eu" },
        { display: "Netherlands — Amsterdam", tzdata: "Europe/Amsterdam", standardOffsetMinutes: 60, dst: "eu" },
        { display: "Germany — Berlin", tzdata: "Europe/Berlin", standardOffsetMinutes: 60, dst: "eu" },
        { display: "Switzerland — Zurich", tzdata: "Europe/Zurich", standardOffsetMinutes: 60, dst: "eu" },
        { display: "Austria — Vienna", tzdata: "Europe/Vienna", standardOffsetMinutes: 60, dst: "eu" },
        { display: "Italy — Rome", tzdata: "Europe/Rome", standardOffsetMinutes: 60, dst: "eu" },
        { display: "Denmark — Copenhagen", tzdata: "Europe/Copenhagen", standardOffsetMinutes: 60, dst: "eu" },
        { display: "Norway — Oslo", tzdata: "Europe/Oslo", standardOffsetMinutes: 60, dst: "eu" },
        { display: "Sweden — Stockholm", tzdata: "Europe/Stockholm", standardOffsetMinutes: 60, dst: "eu" },
        { display: "Finland — Helsinki", tzdata: "Europe/Helsinki", standardOffsetMinutes: 120, dst: "eu" },
        { display: "Poland — Warsaw", tzdata: "Europe/Warsaw", standardOffsetMinutes: 60, dst: "eu" },
        { display: "Czech Republic — Prague", tzdata: "Europe/Prague", standardOffsetMinutes: 60, dst: "eu" },
        { display: "Hungary — Budapest", tzdata: "Europe/Budapest", standardOffsetMinutes: 60, dst: "eu" },
        { display: "Romania — Bucharest", tzdata: "Europe/Bucharest", standardOffsetMinutes: 120, dst: "eu" },
        { display: "Greece — Athens", tzdata: "Europe/Athens", standardOffsetMinutes: 120, dst: "eu" },
        { display: "Ukraine — Kyiv", tzdata: "Europe/Kyiv", standardOffsetMinutes: 120, dst: "eu" },
        // Turkey abolished DST in 2016 (fixed +3:00 year-round).
        { display: "Turkey — Istanbul", tzdata: "Europe/Istanbul", standardOffsetMinutes: 180 },
        // Russia abolished DST in 2014 (fixed standard time year-round).
        { display: "Russia — Moscow", tzdata: "Europe/Moscow", standardOffsetMinutes: 180 },
        { display: "Russia — Yekaterinburg", tzdata: "Asia/Yekaterinburg", standardOffsetMinutes: 300 },
        { display: "Russia — Novosibirsk", tzdata: "Asia/Novosibirsk", standardOffsetMinutes: 420 },
        { display: "Russia — Vladivostok", tzdata: "Asia/Vladivostok", standardOffsetMinutes: 600 },

        // Egypt reinstated DST in 2023 after several years without it.
        { display: "Egypt — Cairo", tzdata: "Africa/Cairo", standardOffsetMinutes: 120, dst: "egypt" },
        // Morocco is moving to permanent GMT (no more Ramadan-linked
        // clock changes) from September 2026 - simplified to that
        // fixed offset here rather than modeling the old Islamic-
        // calendar-dependent Ramadan exception.
        { display: "Morocco — Casablanca", tzdata: "Africa/Casablanca", standardOffsetMinutes: 0 },
        { display: "Nigeria — Lagos", tzdata: "Africa/Lagos", standardOffsetMinutes: 60 },
        { display: "Kenya — Nairobi", tzdata: "Africa/Nairobi", standardOffsetMinutes: 180 },
        { display: "South Africa — Johannesburg", tzdata: "Africa/Johannesburg", standardOffsetMinutes: 120 },

        { display: "Israel — Jerusalem", tzdata: "Asia/Jerusalem", standardOffsetMinutes: 120, dst: "israel" },
        { display: "United Arab Emirates — Dubai", tzdata: "Asia/Dubai", standardOffsetMinutes: 240 },
        { display: "Saudi Arabia — Riyadh", tzdata: "Asia/Riyadh", standardOffsetMinutes: 180 },
        { display: "Qatar — Doha", tzdata: "Asia/Qatar", standardOffsetMinutes: 180 },
        // Iran abolished DST in 2022 (fixed +3:30 year-round).
        { display: "Iran — Tehran", tzdata: "Asia/Tehran", standardOffsetMinutes: 210 },
        { display: "Iraq — Baghdad", tzdata: "Asia/Baghdad", standardOffsetMinutes: 180 },
        { display: "Pakistan — Karachi", tzdata: "Asia/Karachi", standardOffsetMinutes: 300 },
        { display: "India — Mumbai", tzdata: "Asia/Kolkata", standardOffsetMinutes: 330 },
        { display: "Bangladesh — Dhaka", tzdata: "Asia/Dhaka", standardOffsetMinutes: 360 },
        { display: "Thailand — Bangkok", tzdata: "Asia/Bangkok", standardOffsetMinutes: 420 },
        { display: "Vietnam — Hanoi", tzdata: "Asia/Ho_Chi_Minh", standardOffsetMinutes: 420 },
        { display: "Indonesia — Jakarta", tzdata: "Asia/Jakarta", standardOffsetMinutes: 420 },
        { display: "Malaysia — Kuala Lumpur", tzdata: "Asia/Kuala_Lumpur", standardOffsetMinutes: 480 },
        { display: "Singapore — Singapore", tzdata: "Asia/Singapore", standardOffsetMinutes: 480 },
        { display: "Philippines — Manila", tzdata: "Asia/Manila", standardOffsetMinutes: 480 },
        { display: "Hong Kong — Hong Kong", tzdata: "Asia/Hong_Kong", standardOffsetMinutes: 480 },
        { display: "Taiwan — Taipei", tzdata: "Asia/Taipei", standardOffsetMinutes: 480 },
        { display: "China — Shanghai", tzdata: "Asia/Shanghai", standardOffsetMinutes: 480 },
        { display: "South Korea — Seoul", tzdata: "Asia/Seoul", standardOffsetMinutes: 540 },
        { display: "Japan — Tokyo", tzdata: "Asia/Tokyo", standardOffsetMinutes: 540 },

        { display: "Australia — Perth", tzdata: "Australia/Perth", standardOffsetMinutes: 480 },
        { display: "Australia — Darwin", tzdata: "Australia/Darwin", standardOffsetMinutes: 570 },
        { display: "Australia — Adelaide", tzdata: "Australia/Adelaide", standardOffsetMinutes: 570, dst: "au" },
        { display: "Australia — Brisbane", tzdata: "Australia/Brisbane", standardOffsetMinutes: 600 },
        { display: "Australia — Sydney", tzdata: "Australia/Sydney", standardOffsetMinutes: 600, dst: "au" },
        { display: "New Zealand — Auckland", tzdata: "Pacific/Auckland", standardOffsetMinutes: 720, dst: "nz" },
        // Fiji repealed its DST law in 2024 (fixed +12:00 year-round).
        { display: "Fiji — Suva", tzdata: "Pacific/Fiji", standardOffsetMinutes: 720 }
    ]
}

var ianaZones = buildIanaZones()

function findIanaZone(tzId) {
    if (!tzId || tzId.length === 0) {
        return null
    }

    var needle = tzId.toLowerCase()

    for (var i = 0; i < ianaZones.length; i++) {
        if (ianaZones[i].tzdata.toLowerCase() === needle) {
            return ianaZones[i]
        }
    }

    return null
}

function isKnownIanaZone(tzId) {
    return findIanaZone(tzId) !== null
}

// Human-readable label for a zone id in either mode - the picker's
// "display" text if known, otherwise the raw id as a last resort
// (e.g. for an id saved by a version of the widget with a longer
// zone list than the current one).
function displayForZone(tzId, mode) {
    if (mode === "iana") {
        var iz = findIanaZone(tzId)
        return iz ? iz.display : tzId
    }

    var oz = findZone(tzId)
    return oz ? oz.display : tzId
}

function pad(n) {
    return (n < 10 ? "0" : "") + n
}

// Renders a UTC-offset-shifted instant as a time string. Shared by
// both formatting modes below - "offset" mode calls it with the
// zone's fixed offset, "iana" mode with whatever offset is in effect
// (standard or daylight) for the instant being displayed.
function formatShiftedTime(now, offsetMinutes, format24h, showSeconds) {
    var shifted = new Date(now.getTime() + offsetMinutes * 60000)

    var hours = shifted.getUTCHours()
    var minutes = shifted.getUTCMinutes()
    var seconds = shifted.getUTCSeconds()

    // showSeconds defaults to true so entries saved by an older
    // version of this widget (before the option existed) keep
    // showing seconds rather than silently losing them.
    var secondsPart = showSeconds === false ? "" : (":" + pad(seconds))

    if (format24h) {
        return pad(hours) + ":" + pad(minutes) + secondsPart
    }

    var suffix = hours >= 12 ? "PM" : "AM"
    var hours12 = hours % 12
    if (hours12 === 0) {
        hours12 = 12
    }

    return hours12 + ":" + pad(minutes) + secondsPart + " " + suffix
}

// Formats "now" for a fixed UTC-offset zone id, using plain
// arithmetic - no timezone database involved, so this cannot produce
// an "invalid timezone" failure.
//
// now.getTime() is already an absolute, zone-agnostic UTC epoch
// value (that's what the JS epoch always is) - so the target zone's
// wall-clock time is just that instant shifted by the target's UTC
// offset. No local getTimezoneOffset() correction is needed (or
// correct) here: that call reports the offset of the machine running
// the widget, not of the "now" instant, and folding it in was
// double-counting a shift that getTime() had already accounted for -
// it made every zone's displayed time wrong by exactly the local
// machine's own UTC offset.
function formatTimeOffset(now, tzId, format24h, showSeconds) {
    return formatShiftedTime(now, offsetMinutesForId(tzId), format24h, showSeconds)
}

// Formats "now" for a real IANA zone id, computing daylight saving
// with the rules above (see the file-level comment for why this
// isn't left to Intl.DateTimeFormat). Falls back to a visible
// "Invalid TZ" only for a genuinely unrecognized id (e.g. one saved
// by a version of the widget with a longer zone list than this one)
// rather than throwing, so one broken clock can't take down the rest
// of the widget.
function formatTimeIana(now, tzId, format24h, showSeconds) {
    var zone = findIanaZone(tzId)

    if (!zone) {
        return "Invalid TZ"
    }

    var offsetMinutes = offsetMinutesForIanaZone(zone, now.getTime())
    return formatShiftedTime(now, offsetMinutes, format24h, showSeconds)
}

// Single entry point used by the UI - dispatches to the offset or
// IANA formatter depending on mode ("offset" is the default, so
// entries saved before this option existed keep working unchanged).
function formatTime(now, tzId, format24h, showSeconds, mode) {
    if (mode === "iana") {
        return formatTimeIana(now, tzId, format24h, showSeconds)
    }

    return formatTimeOffset(now, tzId, format24h, showSeconds)
}
