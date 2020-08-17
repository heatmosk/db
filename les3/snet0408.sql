drop database if exists snet0408;
create database snet0408 charset=utf8;
use snet0408;


/* Может быть отдельная таблица / таблицыа с настройками полномочий? вроде создания постов, 
	комментирования и т.п.? */
drop table if exists users;
create table users(
	id serial primary key,
	email varchar(120) not null unique,
	phone varchar(15) not null,
	pass varchar(200) not null,
	created_at datetime default current_timestamp,
	visible_for enum('all', 'frends_of_friends', 'friends') default 'all',
	can_comment bool, 
	can_message enum('all', 'frends_of_friends', 'friends') default 'all',
	invite_to_community enum('all', 'frends_of_friends', 'friends') default 'all'
);
/* почему char? для возможности указания более чем 2х полов? 
 будет ли сильная разница если изменить на int(1) или bool?  */
drop table if exists profiles;
create table profiles(
	user_id serial primary key,
	name varchar(255) not null,
	lastname varchar(255) not null,
	gender char(1),  
	birthday date,
	photo_id bigint unsigned not null,
	foreign key(user_id) references users(id)
);


-- добавили индексы
alter table profiles add index(name);
alter table profiles add index(lastname);


-- разрешили значение null в поле photo_id
alter table profiles change column photo_id photo_id bigint unsigned null;

drop table if exists friend_requests;
create table friend_requests(
	initiator_user_id bigint unsigned not null,
	target_user_id bigint unsigned not null,
	status enum('requested', 'approved', 'unfriended', 'decline') default 'requested',
	requested_at datetime default current_timestamp,
	updated_at datetime,
	primary key(initiator_user_id, target_user_id),
	key `friend_requests_iui_idx` (initiator_user_id),
	key(target_user_id),
	constraint `friend_requests_fk1` foreign key(initiator_user_id) references profiles(user_id),
	foreign key(target_user_id) references profiles(user_id)
);

drop table if exists messages;
create table messages(
	id serial,
	from_user_id bigint unsigned not null,
	to_user_id bigint unsigned not null,
	body text,
	is_read bool,
	created_at datetime default current_timestamp,
	primary key (id),
	attachments json,  -- Для возможности прикрепления медиа файла к сообщению
	foreign key(from_user_id) references profiles(user_id),
	foreign key(to_user_id) references profiles(user_id) 
);

drop table if exists posts;
create table posts(
	id serial primary key,
	user_id bigint unsigned not null,
	body text,
	attachments json,
	metadata json,
	created_at datetime default current_timestamp,
	updated_at datetime default current_timestamp on update current_timestamp,
	foreign key (user_id) references profiles(user_id)
);

drop table if exists comments;
create table comments (
	id serial primary key,
	user_id bigint unsigned not null,
	post_id bigint unsigned not null,
	body text,
	created_at datetime default current_timestamp,
	updated_at datetime default current_timestamp on update current_timestamp,
	foreign key (user_id) references profiles(user_id),
	foreign key (post_id) references posts(id)
);

drop table if exists photos;
create table photos(
	id serial primary key,
	file varchar(255),
	user_id bigint unsigned not null,
	description text,
	created_at datetime default current_timestamp,
	updated_at datetime default current_timestamp on update current_timestamp,
	foreign key (user_id) references profiles(user_id)
);

drop table if exists communities;
create table communities(
	id serial primary key,
	name varchar(255),
	key(name)
);

drop table if exists users_communities;
create table users_communities(
	community_id bigint unsigned not null,
	user_id bigint unsigned not null,
	is_admin bool,
	primary key (community_id, user_id),
	foreign key (user_id) references profiles(user_id),
	foreign key (community_id) references communities(id)
);



/*Таблица для хранения лайков постов*/
drop table if exists post_likes;
create table post_likes (
	post_id bigint unsigned not null,
	user_id bigint unsigned not null, 
	primary key (post_id, user_id),
	foreign key (post_id) references posts(id),
	foreign key (user_id) references profiles(user_id)
);

