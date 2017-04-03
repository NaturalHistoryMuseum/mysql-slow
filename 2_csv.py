#!/usr/bin/env python3
"""Preprocesses mysql-slow log files (/var/log/mysql/mysql-slow.log)
"""
import collections
import itertools
import mmap
import re

from datetime import datetime
from pathlib import Path

INPUT_DIR = Path('0_data')
OUTPUT_DIR = Path(Path(__file__).stem)

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

"""
# Time: 160311 21:42:01
# User@Host: vbranteu[vbranteu] @ sp-app-1.nhm.ac.uk [157.140.2.182]  Id: 37056517
# Schema: vbranteu  Last_errno: 0  Killed: 0
# Query_time: 2.939464  Lock_time: 0.000101  Rows_sent: 0  Rows_examined: 0  Rows_affected: 1
# Bytes_sent: 19
use vbranteu;
SET timestamp=1457732521;
INSERT INTO watchdog
    (uid, type, message, variables, severity, link, location, referer, hostname, timestamp)
    VALUES
    (0, 'php', '%message in %file on line %line.', 'a:4:{s:6:\"%error\";s:14:\"strict warning\";s:8:\"%message\";s:62:\"Non-static method view::load() should not be called statically\";s:5:\"%file\";s:67:\"/var/aegir/platforms/vbrant.eu/sites/all/modules/views/views.module\";s:5:\"%line\";i:906;}', 3, '', 'http://vbrant.eu/calendar-date/2012-01-28?destination=calendar-date/2013-08-16', '', ' 192.243.55.133', 1457732518);
# User@Host: phasmidstudygr_0[phasmidstudygr_0] @ sp-app-2.nhm.ac.uk [157.140.2.183]  Id: 37056516
# Schema: phasmidstudygr_0  Last_errno: 0  Killed: 0
# Query_time: 2.751858  Lock_time: 0.000100  Rows_sent: 0  Rows_examined: 1  Rows_affected: 0
# Bytes_sent: 52
use phasmidstudygr_0;
SET timestamp=1457732521;
UPDATE citethispage SET path='biblio', uid='0', results='b:0;'
WHERE  (sid = '31');
"""

METADATA = re.compile(
    b'# Time: '
    b'(?P<year>[0-9]{2})(?P<month>[0-9]{2})(?P<day>[0-9]{2}) {1,2}'
    b'(?P<hours>[0-9]{1,2}):(?P<minutes>[0-9]{2}):(?P<seconds>[0-9]{2})\n'
    b'# User@Host: .*\n'
    b'# Schema: (?P<schema>[a-z]+)[ \t]+'
    b'Last_errno: (?P<last_errno>[0-9]+)[ \t]+'
    b'Killed: (?P<killed>[0-9]+)\n'
    b'# Query_time: (?P<seconds_elapsed>[0-9]+\.[0-9]+) .*\n'
    b'# Bytes_sent: .*\n'
    b'(?P<query>[^#]+)'
)


SlowSQL = collections.namedtuple(
    'SlowSQL', ['datetime', 'schema', 'last_errno', 'killed', 'seconds_elapsed']
)

def parse_match(match):
    datetime_values = (int(v) for v in match.groups()[:6])
    # Years are all after 2000 and are in YY form
    dt = datetime(
        *itertools.chain([2000 + next(datetime_values)], datetime_values)
    )
    return SlowSQL(
        dt,
        match.group('schema').decode('ascii'),
        int(match.group('last_errno')),
        int(match.group('killed')),
        float(match.group('seconds_elapsed')),
        # match.group('query')
    )


if __name__ == '__main__':
    for log in (p for p in INPUT_DIR.glob('*.log') if p.is_file()):
        csv = OUTPUT_DIR.joinpath(log.with_suffix('.csv').name)
        print(f'Processing [{log}] to [{csv}]')
        with log.open('rb') as infile, csv.open('w') as outfile:
            # Headers
            print(','.join(SlowSQL._fields), file=outfile)
            with mmap.mmap(infile.fileno(), length=0, access=mmap.ACCESS_READ) as data:
                for res in map(parse_match, METADATA.finditer(data)):
                    print(','.join(map(str, res)), file=outfile)
