bash = '/bin/bash'
python = '/Users/lawh/Envs/mysql-slow/bin/python3'
R = '/Users/lawh/local/R-3.3.3/bin/Rscript'


STAGES = [
    ('1', bash,    '1_uncompress.bash'),
    ('2', python,  '2_csv.py'),
    ('3', R,       '3_rds.R'),
    ('4', R,       '4_visualise.R'),
]
