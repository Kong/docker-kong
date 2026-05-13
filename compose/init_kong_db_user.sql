\getenv password_file_path KONG_PASSWORD_FILE

\if :{?password_file_path}
  \set kong_password `cat :password_file_path`
\else
  \set kong_password 'kong'
\endif

CREATE USER kong WITH NOSUPERUSER NOCREATEDB NOCREATEROLE PASSWORD :'kong_password';
CREATE DATABASE kong OWNER kong;

\c kong
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO kong;
REVOKE EXECUTE ON FUNCTION pg_ls_dir(text) FROM kong;
REVOKE EXECUTE ON FUNCTION pg_read_file(text) FROM kong;
