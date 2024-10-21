-- Shell: mysql --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --database=nocobase < /docker-entrypoint-initdb.d/3-maaser-calculate-view.sql
CREATE OR REPLACE VIEW salary_maaser_summary AS
SELECT
	salary_summary.sum_of_salary,
	maaser_summary.sum_of_maaser,
    (salary_summary.sum_of_salary / 10) - maaser_summary.sum_of_maaser AS calculated
FROM 
    (SELECT SUM(neto) AS sum_of_salary FROM salary) AS salary_summary,
    (SELECT SUM(sum) AS sum_of_maaser FROM maaser WHERE tithe = 1) AS maaser_summary;