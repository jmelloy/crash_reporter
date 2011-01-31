create schema crash;

create table crash.status_lookup (
    status_id   serial primary key,
    name        text not null
);

create table crash.crash_logs (
    crash_id    serial primary key,
    crash_time  timestamp default now(),
    build       text,
    ip_address  inet,
    email       text,
    service_uid text,
    short_desc  varchar(300),
    description text,
    crash_log   text not null,
    status_id   int references crash.status_lookup not null,
    application varchar(30)
);

create table crash.users (
    user_id     serial primary key,
    name        text,
    email       text,
    handle      text,
    application varchar(30)
);

create table crash.comments (
    comment_id  serial primary key,
    user_id     int references crash.users,
    crash_id    int references crash.crash_logs,
    subject     text,
    message     text not null,
    date_added  timestamp default now()
);

create table crash.groups (
    group_id    serial primary key,
    description text not null,
    parent_id   int references crash.groups(group_id),
    created_by  int references crash.users(user_id),
    date_created    timestamp default now()
);

create table crash.crash_group (
    group_id    int references crash.groups,
    crash_id    int references crash.crash_logs,
    primary key(group_id, crash_id)
);

create table crash.status_history (
    crash_id    int references crash.crash_logs not null,
    user_id     int references crash.users not null,
    status_id   int references crash.status_lookup not null,
    reason      text,
    change_date timestamp default now() not null
);

create table crash.group_history (
    crash_id    int references crash.crash_logs not null,
    user_id     int references crash.users not null,
    group_id    int references crash.groups not null,
    reason      text,
    change_date timestamp default now() not null
);

insert into crash.status_lookup (name) values ('Unknown');
insert into crash.status_lookup (name) values ('Known');
insert into crash.status_lookup (name) values ('Fixed');
insert into crash.satus_lookup (name) values ('Flagged');


create or replace function public.html_entity(text) returns text as '
declare
    entry_text  alias for $1;
    return_text text;
begin

    return_text := replace(entry_text, ''&'', ''&amp;'');
    return_text := replace(return_text, ''"'', ''&quot;'');
    return_text := replace(return_text, ''>'', ''&gt;'');
    return_text := replace(return_text, ''<'', ''&lt;'');

    return return_text;
end;
' language plpgsql;

