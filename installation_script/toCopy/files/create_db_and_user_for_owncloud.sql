create user owncloud with password 'all4one';
create database owncloud;
alter database owncloud owner to owncloud;
grant all privileges on database owncloud to owncloud;

