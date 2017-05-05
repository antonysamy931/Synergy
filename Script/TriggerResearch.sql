----------------
-- Trigger 
----------------
-- Reference - https://www.codeproject.com/Articles/25600/Triggers-SQL-Server

Create table [Trigger_Table]
(
	Id int identity(1,1) primary key,
	Name varchar(100)
)
go

Create table [Trigger_Table_Monitor]
(
Id int identity(1,1) primary key,
Name varchar(100),
[Action] varchar(30)
)
go

Create trigger Insert_Trigger on Trigger_Table
For insert
As
declare @name varchar(200)
select @name = i.Name from inserted i

insert into Trigger_Table_Monitor
values(@name,'insert')
go

Create trigger Update_Trigger on Trigger_Table
For update
as
declare @name varchar(200)
select @name = i.Name from inserted i
insert into Trigger_Table_Monitor
values(@name,'update')
go

Create trigger Delete_Trigger on Trigger_Table
after delete
as
declare @name varchar(200)
select @name = i.Name from deleted i
insert into Trigger_Table_Monitor
values(@name,'delete')
go

-- enable all trigger for particular table using this command
--alter table [Trigger_Table] disable trigger all
--go

-- disable all trigger for particular table using this command
--alter table Trigger_Table disable trigger all
--go

create trigger Update_Instead_Trigger on Trigger_Table
instead of update
as
declare @id int
declare @name varchar(200)
declare @beforname varchar(200)
select @id = u.Id from inserted u
select @name = u.Name from inserted u

select @beforname = Name from Trigger_Table where id=@id
update Trigger_Table set Name = @name where id=@id
--print @beforname
go

-- enable specified trigger for particular table
alter table Trigger_Table enable trigger Update_Instead_Trigger
go

--disable specified trigger for particular table
--alter table Trigger_Table disable trigger Update_Instead_Trigger
--go