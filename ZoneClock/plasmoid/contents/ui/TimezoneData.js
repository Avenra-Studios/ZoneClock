.pragma library

// Single source of truth for timezone identifiers used by Zone Clock.
//
// Zones are fixed UTC offsets (UTC, UTC+1, UTC-5, etc). Each entry
// carries its offset as a plain number of minutes from UTC, because
// the clock display is computed with plain date-math (see
// shiftedTimeParts below) rather than by asking Intl.DateTimeFormat
// to resolve a timeZone string. Plasma's QML JS engine does not
// reliably support the timeZone option of Intl.DateTimeFormat, which
// is what caused every previous approach (city names, then
// Etc/GMT ids) to show "Invalid TZ" even for correct zones. Plain
// arithmetic has no such dependency and cannot fail this way.

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

// Case-insensitive lookup by id against the canonical list above.
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

// Formats "now" (a JS Date) as hh:mm:ss for the given zone id, using
// plain arithmetic - no Intl / timeZone resolution involved, so this
// cannot produce an "invalid timezone" failure.
function formatTime(now, tzId, format24h, showSeconds) {
    var offsetMinutes = offsetMinutesForId(tzId)

    // now.getTime() is already an absolute, zone-agnostic UTC epoch
    // value (that's what the JS epoch always is) - so the target
    // zone's wall-clock time is just that instant shifted by the
    // target's UTC offset. No local getTimezoneOffset() correction
    // is needed (or correct) here: that call reports the offset of
    // the machine running the widget, not of the "now" instant, and
    // folding it in was double-counting a shift that getTime() had
    // already accounted for - it made every zone's displayed time
    // wrong by exactly the local machine's own UTC offset.
    var shifted = new Date(now.getTime() + offsetMinutes * 60000)

    var hours = shifted.getUTCHours()
    var minutes = shifted.getUTCMinutes()
    var seconds = shifted.getUTCSeconds()

    function pad(n) {
        return (n < 10 ? "0" : "") + n
    }

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
