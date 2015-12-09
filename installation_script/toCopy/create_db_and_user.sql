create database "odk_prod";
create user "odk_user" with unencrypted password 'all4one';
grant all privileges on database "odk_prod" to "odk_user";
alter database "odk_prod" owner to "odk_user";
\c "odk_prod";
create schema "odk_prod";
grant all privileges on schema "odk_prod" to "odk_user";
