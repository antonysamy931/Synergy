USE [bistroMDMP]
GO
/****** Object:  User [219367-7\Aaron]    Script Date: 8/20/2016 10:36:37 PM ******/
CREATE USER [219367-7\Aaron] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [Bistr]    Script Date: 8/20/2016 10:36:38 PM ******/
CREATE USER [Bistr] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [Bistro]    Script Date: 8/20/2016 10:36:38 PM ******/
CREATE USER [Bistro] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [mybistromd]    Script Date: 8/20/2016 10:36:38 PM ******/
CREATE USER [mybistromd] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_accessadmin] ADD MEMBER [219367-7\Aaron]
GO
ALTER ROLE [db_securityadmin] ADD MEMBER [219367-7\Aaron]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [219367-7\Aaron]
GO
ALTER ROLE [db_backupoperator] ADD MEMBER [219367-7\Aaron]
GO
ALTER ROLE [db_datareader] ADD MEMBER [219367-7\Aaron]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [219367-7\Aaron]
GO
ALTER ROLE [db_denydatareader] ADD MEMBER [219367-7\Aaron]
GO
ALTER ROLE [db_denydatawriter] ADD MEMBER [219367-7\Aaron]
GO
ALTER ROLE [db_owner] ADD MEMBER [Bistr]
GO
ALTER ROLE [db_owner] ADD MEMBER [Bistro]
GO
ALTER ROLE [db_owner] ADD MEMBER [mybistromd]
GO
/****** Object:  UserDefinedFunction [dbo].[DAYSEARCH]    Script Date: 8/20/2016 10:36:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[DAYSEARCH](@day_name VARCHAR(9), @step_count INT, @direction smallint)
RETURNS datetime
AS
BEGIN
/*
Returns a date based upon criteria to find a specific day-of-week 
 for a specific number of "steps" forward or backward.
 For instance, "last Wednesday" or "two Thursdays from today".
@day_name = day of week to find ie. Monday, Tuesday...
@step_count = number of iterations back for a specific day:
--------> "1 Last Monday " =  1
--------> "3 Thursdays from now" = 3
@direction:
--------> -1 if Past
--------> 1 if Future
*/

 DECLARE @daysearch datetime
 DECLARE @counter smallint
 DECLARE @hits smallint
 DECLARE @day_name_calc VARCHAR(9)

 SELECT @counter = @direction
 SELECT @hits = 0

 WHILE @hits < @step_count
   BEGIN
     SELECT @day_name_calc = DATENAME(weekday , DATEADD(d, @counter, GETDATE())) 
     
     IF @day_name_calc = @day_name
       BEGIN
         SELECT @hits = @hits + 1
         SELECT @daysearch = DATEADD(d, @counter, GETDATE())
       END

     SELECT @counter = (@counter + (1 * @direction))
   END
 RETURN @daysearch      
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetMealRating]    Script Date: 8/20/2016 10:36:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetMealRating]
(	
	-- Add the parameters for the function here
	@Rating INT,
	@MealID INT	
)
RETURNS INT 
AS
BEGIN
	-- Add the SELECT statement with parameter references here
	  -- Insert Values into Temp table
	DECLARE @Output INT
	DECLARE @TempRating TABLE (Rating INT)
	DECLARE @CustomerID INT
	DECLARE @getCustomerID CURSOR
	SET @getCustomerID = CURSOR FOR
		SELECT DISTINCT CustomerID FROM UserRatings with (nolock) WHERE MealID = @MealID
	OPEN @getCustomerID
	FETCH NEXT
	FROM @getCustomerID INTO @CustomerID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO @TempRating
		SELECT Top 1 Rating FROM UserRatings with (nolock) WHERE MealID = @MealID and CustomerID = @CustomerID ORDER BY CreatedDate DESC
		 
	FETCH NEXT
	FROM @getCustomerID INTO @CustomerID
	END
	CLOSE @getCustomerID
	DEALLOCATE @getCustomerID
		SELECT  @Output = COUNT(Rating) FROM @TempRating where Rating = @Rating
	RETURN @OutPut
END


GO
/****** Object:  UserDefinedFunction [dbo].[splitString]    Script Date: 8/20/2016 10:36:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[splitString]
(	
	@Input NVARCHAR(MAX),
	@Character CHAR(1)
)
RETURNS @Output TABLE (
	Item NVARCHAR(1000)
)
AS
BEGIN
	DECLARE @StartIndex INT, @EndIndex INT

	SET @StartIndex = 1
	IF SUBSTRING(@Input, LEN(@Input) - 1, LEN(@Input)) <> @Character
	BEGIN
		SET @Input = @Input + @Character
	END

	WHILE CHARINDEX(@Character, @Input) > 0
	BEGIN
		SET @EndIndex = CHARINDEX(@Character, @Input)
		
		INSERT INTO @Output(Item)
		SELECT SUBSTRING(@Input, @StartIndex, @EndIndex - 1)
		
		SET @Input = SUBSTRING(@Input, @EndIndex + 1, LEN(@Input))
	END

	RETURN
END



GO
/****** Object:  UserDefinedFunction [dbo].[udf_GetCategoryForIngredient]    Script Date: 8/20/2016 10:36:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE FUNCTION [dbo].[udf_GetCategoryForIngredient]
 ( -- Add the parameters for the stored procedure here
       @IngredientID int,
       @SelectionType        int  --1 All  2 Top 3 Records Only
 )
 RETURNS VARCHAR(MAX)
 AS
 BEGIN
   DECLARE @IngredientCategoryName VARCHAR(MAX) 
   DECLARE @mIngredientCount INTEGER

IF @SelectionType=1 
	BEGIN
			(SELECT @IngredientCategoryName =  COALESCE(@IngredientCategoryName + ',', '') + ISNULL(IngredientCategory.name,'') FROM         IngredientCategory RIGHT OUTER JOIN
								  IngredientIngredientCategory ON IngredientCategory.IngredientCategoryID = IngredientIngredientCategory.IngredientCategoryID RIGHT OUTER JOIN
								  Ingredient ON IngredientIngredientCategory.IngredientID = Ingredient.IngredientID  
								  Where   Ingredient.IngredientID=@IngredientID) 
	END
ELSE
	BEGIN
	
		(SELECT TOP 3 @IngredientCategoryName =  COALESCE(@IngredientCategoryName + ',', '') + ISNULL(IngredientCategory.name,'') FROM         IngredientCategory RIGHT OUTER JOIN
									  IngredientIngredientCategory ON IngredientCategory.IngredientCategoryID = IngredientIngredientCategory.IngredientCategoryID RIGHT OUTER JOIN
									  Ingredient ON IngredientIngredientCategory.IngredientID = Ingredient.IngredientID  
									  Where   Ingredient.IngredientID=@IngredientID) 
									  
                     SELECT @mIngredientCount =COUNT(IngredientCategory.Name) FROM         IngredientCategory RIGHT OUTER JOIN
									  IngredientIngredientCategory ON IngredientCategory.IngredientCategoryID = IngredientIngredientCategory.IngredientCategoryID RIGHT OUTER JOIN
									  Ingredient ON IngredientIngredientCategory.IngredientID = Ingredient.IngredientID  
									  Where   Ingredient.IngredientID=@IngredientID
                    
                    
                    IF @mIngredientCount>3
                    BEGIN
						SET @IngredientCategoryName=@IngredientCategoryName+ '...'
                    END
	END
				   RETURN(@IngredientCategoryName)
 END

GO
/****** Object:  UserDefinedFunction [dbo].[udf_GetIngredientForCategory]    Script Date: 8/20/2016 10:36:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE FUNCTION [dbo].[udf_GetIngredientForCategory]
 ( -- Add the parameters for the stored procedure here
       @IngredientCategoryID int,
       @SelectionType        int  --1 All  2 Top 3 Records Only
      
 )
 RETURNS VARCHAR(MAX)
 AS
 BEGIN
   DECLARE @IngredientName VARCHAR(MAX) 
   DECLARE @mIngredientCount INTEGER
IF @SelectionType=1 
	BEGIN
		SELECT @IngredientName =  COALESCE(@IngredientName + ',', '') + ISNULL(Ingredient.Name ,'') FROM         
			
	        IngredientCategory INNER JOIN
                      IngredientIngredientCategory ON IngredientCategory.IngredientCategoryID = IngredientIngredientCategory.IngredientCategoryID INNER JOIN
                      Ingredient ON IngredientIngredientCategory.IngredientID = Ingredient.IngredientID
                    WHERE IngredientCategory.IngredientCategoryID=@IngredientCategoryID
	END
ELSE
	BEGIN
			SELECT TOP 3 @IngredientName =  COALESCE(@IngredientName + ',', '') + ISNULL(Ingredient.Name ,'') FROM         
			
	        IngredientCategory INNER JOIN
                      IngredientIngredientCategory ON IngredientCategory.IngredientCategoryID = IngredientIngredientCategory.IngredientCategoryID INNER JOIN
                      Ingredient ON IngredientIngredientCategory.IngredientID = Ingredient.IngredientID
                    WHERE IngredientCategory.IngredientCategoryID=@IngredientCategoryID
                    ORDER BY Ingredient.Name
                    
                   SELECT @mIngredientCount =COUNT(Ingredient.Name)FROM IngredientCategory INNER JOIN
                      IngredientIngredientCategory ON IngredientCategory.IngredientCategoryID = IngredientIngredientCategory.IngredientCategoryID INNER JOIN
                      Ingredient ON IngredientIngredientCategory.IngredientID = Ingredient.IngredientID
                    WHERE IngredientCategory.IngredientCategoryID=@IngredientCategoryID
                    
                    
                    IF @mIngredientCount>3
                    BEGIN
						SET @IngredientName=@IngredientName+ '...'
                    END
	END
	


       RETURN(@IngredientName)
 END

GO
/****** Object:  UserDefinedFunction [dbo].[udf_GetIngredientForMeal]    Script Date: 8/20/2016 10:36:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE FUNCTION [dbo].[udf_GetIngredientForMeal]
 ( -- Add the parameters for the stored procedure here
       @MealID int
      
 )
 RETURNS VARCHAR(MAX)
 AS
 BEGIN
   DECLARE @IngredientName VARCHAR(MAX) 


(SELECT @IngredientName =  COALESCE(@IngredientName + ',', '') + ISNULL(Ingredient.name,'') FROM MealIngredient INNER JOIN
                      Ingredient ON MealIngredient.IngredientID = Ingredient.IngredientID
                      Where   MealIngredient.MealID=@MealID) 


       RETURN(@IngredientName)
 END

GO
/****** Object:  Table [dbo].[Active]    Script Date: 8/20/2016 10:36:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Active](
	[ActiveId] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AgentNote]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AgentNote](
	[AgentNoteID] [int] IDENTITY(1,1) NOT NULL,
	[AgentID] [int] NOT NULL CONSTRAINT [DF_AgentNote_AgentID]  DEFAULT ((0)),
	[Subject] [varchar](255) NOT NULL CONSTRAINT [DF_AgentNote_Subject]  DEFAULT (''),
	[Notes] [text] NOT NULL CONSTRAINT [DF_AgentNote_Notes]  DEFAULT (''),
	[NoteDate] [datetime] NULL,
	[CustomerID] [int] NULL,
	[OrderID] [int] NULL,
	[PurchaseOrderID] [int] NULL,
	[MealID] [int] NULL,
	[PlanID] [int] NULL,
	[InventoryItemID] [int] NULL,
 CONSTRAINT [PK_AgentNote] PRIMARY KEY CLUSTERED 
(
	[AgentNoteID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ApiReport]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ApiReport](
	[ApiReportId] [int] IDENTITY(1,1) NOT NULL,
	[OrderId] [int] NULL,
	[CustomerName] [nchar](30) NULL,
	[ApiStatus] [nchar](10) NULL,
	[Result] [varchar](250) NULL,
	[SentOn] [date] NULL,
 CONSTRAINT [PK_ApiReport] PRIMARY KEY CLUSTERED 
(
	[ApiReportId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Application]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Application](
	[ApplicationID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](256) NOT NULL,
	[Description] [nvarchar](256) NULL,
 CONSTRAINT [PK_Application] PRIMARY KEY CLUSTERED 
(
	[ApplicationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BistroKey]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BistroKey](
	[BistroKeyId] [int] IDENTITY(1,1) NOT NULL,
	[BistroKeyName] [varchar](100) NULL,
	[DisplayName] [varchar](150) NULL,
	[CreatedOn] [datetime] NULL,
	[CreatedBy] [varchar](50) NULL,
	[UpdatedOn] [datetime] NULL,
	[UpdatedBy] [varchar](50) NULL,
 CONSTRAINT [PK_BistroKeys] PRIMARY KEY CLUSTERED 
(
	[BistroKeyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Build]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Build](
	[BuildID] [int] IDENTITY(1,1) NOT NULL,
	[Status] [int] NOT NULL CONSTRAINT [DF_Build_Status]  DEFAULT ((0)),
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[ShipDate] [datetime] NULL,
	[UserID] [int] NULL,
	[PlanID] [int] NULL,
	[ProgramID] [int] NULL,
	[InProgress] [bit] NOT NULL CONSTRAINT [DF_Build_InProgress]  DEFAULT ((0)),
 CONSTRAINT [PK_Build] PRIMARY KEY CLUSTERED 
(
	[BuildID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BulkOrderHistory]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BulkOrderHistory](
	[BulkOrderID] [int] IDENTITY(1,1) NOT NULL,
	[BulkOrderDate] [datetime] NULL,
	[BulkOrderGUID] [uniqueidentifier] NOT NULL,
	[CustomerID] [int] NOT NULL CONSTRAINT [DF_Table_1_ErrorType]  DEFAULT ((0)),
	[OrderID] [int] NOT NULL CONSTRAINT [DF_Table_1_CustomerName]  DEFAULT ((0)),
	[Status] [text] NOT NULL CONSTRAINT [DF_Table_1_Exception]  DEFAULT (''),
 CONSTRAINT [PK_BulkOrderHistory] PRIMARY KEY CLUSTERED 
(
	[BulkOrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Carrier]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Carrier](
	[CarrierID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NOT NULL CONSTRAINT [DF_Carrier_Name]  DEFAULT (''),
	[Description] [text] NOT NULL CONSTRAINT [DF_Carrier_Description]  DEFAULT (''),
	[Active] [bit] NOT NULL CONSTRAINT [DF_Carrier_Active]  DEFAULT ((0)),
 CONSTRAINT [PK_Carrier] PRIMARY KEY CLUSTERED 
(
	[CarrierID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Control]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Control](
	[ControlID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NULL,
	[Description] [text] NULL,
	[Path] [varchar](255) NULL,
	[ClassName] [varchar](50) NULL,
 CONSTRAINT [PK_Control] PRIMARY KEY CLUSTERED 
(
	[ControlID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ControlChangePassword]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ControlChangePassword](
	[PageControlID] [int] NOT NULL,
	[Title] [varchar](50) NOT NULL,
 CONSTRAINT [PK_ControlChangePassword] PRIMARY KEY CLUSTERED 
(
	[PageControlID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ControlLogin]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ControlLogin](
	[PageControlID] [int] NOT NULL,
	[Title] [varchar](50) NOT NULL,
 CONSTRAINT [PK_ControlLogin] PRIMARY KEY CLUSTERED 
(
	[PageControlID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ControlLoginName]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ControlLoginName](
	[PageControlID] [int] NOT NULL,
	[WelcomeText] [varchar](50) NOT NULL,
 CONSTRAINT [PK_ControlLoginName] PRIMARY KEY CLUSTERED 
(
	[PageControlID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ControlLoginStatus]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ControlLoginStatus](
	[PageControlID] [int] NOT NULL,
	[LoginText] [varchar](50) NOT NULL,
	[LogoutText] [varchar](50) NOT NULL,
 CONSTRAINT [PK_ControlLoginStatus] PRIMARY KEY CLUSTERED 
(
	[PageControlID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ControlMarkup]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ControlMarkup](
	[PageControlID] [int] NOT NULL,
	[Markup] [text] NULL,
 CONSTRAINT [PK_ControlMarkup] PRIMARY KEY CLUSTERED 
(
	[PageControlID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ControlProfile]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ControlProfile](
	[PageControlID] [int] NOT NULL,
	[Title] [varchar](50) NOT NULL,
 CONSTRAINT [PK_ControlProfile] PRIMARY KEY CLUSTERED 
(
	[PageControlID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ControlRegister]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ControlRegister](
	[PageControlID] [int] NOT NULL,
	[UsernameText] [varchar](50) NOT NULL,
	[PasswordText] [varchar](50) NOT NULL,
 CONSTRAINT [PK_ControlRegister] PRIMARY KEY CLUSTERED 
(
	[PageControlID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Country]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Country](
	[CountryID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](255) NOT NULL CONSTRAINT [DF_Country_Name]  DEFAULT (''),
	[Abbreviation] [varchar](10) NOT NULL CONSTRAINT [DF_Country_Abbreviation]  DEFAULT (''),
 CONSTRAINT [PK_Country] PRIMARY KEY CLUSTERED 
(
	[CountryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Customer]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Customer](
	[CustomerID] [int] IDENTITY(10000,1) NOT NULL,
	[First] [varchar](50) NULL CONSTRAINT [DF_Customer_First]  DEFAULT (''),
	[Last] [varchar](50) NULL CONSTRAINT [DF_Customer_Last]  DEFAULT (''),
	[LeadDate] [datetime] NULL,
	[LeadSource] [varchar](255) NULL CONSTRAINT [DF_Customer_LeadSource]  DEFAULT (''),
	[Email] [varchar](200) NULL CONSTRAINT [DF_Customer_Email]  DEFAULT (''),
	[CreatedDate] [datetime] NULL,
	[UpdatedDate] [datetime] NULL,
	[BillingAddressID] [int] NULL CONSTRAINT [DF_Customer_BillingAddressID]  DEFAULT ((0)),
	[ShippingAddressID] [int] NULL CONSTRAINT [DF_Customer_ShippingAddressID]  DEFAULT ((0)),
	[EmailPreference] [int] NULL,
	[EmailBounces] [int] NULL,
	[CustomerStatusID] [int] NOT NULL CONSTRAINT [DF_Customer_CustomerStatusID]  DEFAULT ((1)),
	[UserID] [int] NULL,
	[Ice] [int] NULL CONSTRAINT [DF_Customer_Ice]  DEFAULT ((2)),
	[AlwaysReviewHold] [bit] NULL CONSTRAINT [DF_Customer_AlwaysReviewHold]  DEFAULT ((0)),
	[PickListComments] [varchar](1000) NULL,
	[MenuComments] [varchar](255) NULL,
	[LegacyUserID] [int] NULL,
	[LegacyLastModified] [datetime] NULL,
	[CustomerPlanID] [int] NULL,
	[PreferredShipDay] [int] NULL CONSTRAINT [DF_Customer_PreferedShipDay]  DEFAULT ((1)),
	[AlwaysHoldReason] [text] NULL,
	[IsDeleted] [bit] NOT NULL CONSTRAINT [DF_Customer_IsDeleted]  DEFAULT ((0)),
	[Active] [bit] NOT NULL CONSTRAINT [DF_Customer_Active]  DEFAULT ((0)),
	[SalesForceID] [varchar](50) NULL,
	[CarrierID] [int] NOT NULL CONSTRAINT [DF_Customer_CarrierID]  DEFAULT ((12)),
	[WareHouse] [nchar](10) NULL,
	[Custom] [bit] NULL,
	[IsShipDateOverride] [bit] NULL,
	[CustomerShipDate] [datetime] NULL,
	[CutOffDate] [datetime] NULL,
	[PaymentStatus] [int] NULL,
	[OrderType] [varchar](50) NULL,
	[CustomerTypeId] [int] NULL,
	[IsVerified] [bit] NULL,
	[SnackTemlplateId] [int] NULL,
	[IsUrgentShipping] [bit] NULL,
 CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CustomerAccess]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerAccess](
	[CustomerAccessID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NOT NULL,
	[LoginDate] [datetime] NULL,
 CONSTRAINT [PK_CustomerAccess] PRIMARY KEY CLUSTERED 
(
	[CustomerAccessID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CustomerAddress]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CustomerAddress](
	[CustomerAddressID] [int] IDENTITY(10000,1) NOT NULL,
	[Address1] [varchar](255) NOT NULL CONSTRAINT [DF_CustomerAddress_Address1]  DEFAULT (''),
	[Address2] [varchar](255) NOT NULL CONSTRAINT [DF_CustomerAddress_Address2]  DEFAULT (''),
	[City] [varchar](255) NOT NULL CONSTRAINT [DF_CustomerAddress_City]  DEFAULT (''),
	[StateID] [int] NOT NULL CONSTRAINT [DF_CustomerAddress_StateProvinceID]  DEFAULT ((1)),
	[PostalCode] [varchar](255) NOT NULL CONSTRAINT [DF_CustomerAddress_PostalCode]  DEFAULT (''),
	[Phone] [varchar](255) NOT NULL CONSTRAINT [DF_CustomerAddress_Phone]  DEFAULT (''),
	[CustomerID] [int] NOT NULL,
	[DeliveryInstructions] [varchar](255) NOT NULL CONSTRAINT [DF_CustomerAddress_DeliveryInstructions]  DEFAULT (''),
	[BusinessAddress] [bit] NOT NULL CONSTRAINT [DF_CustomerAddress_BusinessAddress]  DEFAULT ((0)),
	[BusinessName] [varchar](255) NULL,
	[First] [varchar](255) NULL,
	[Last] [varchar](255) NULL,
 CONSTRAINT [PK_CustomerAddress] PRIMARY KEY CLUSTERED 
(
	[CustomerAddressID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CustomerImport]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CustomerImport](
	[Name] [nvarchar](255) NULL,
	[Address1] [nvarchar](255) NULL,
	[Address2] [nvarchar](255) NULL,
	[City] [nvarchar](255) NULL,
	[St] [nvarchar](255) NULL,
	[PostalCode] [nvarchar](255) NULL,
	[StartDate] [datetime] NULL,
	[StatusID] [nvarchar](255) NULL,
	[Week] [nvarchar](255) NULL,
	[Email] [nvarchar](255) NULL,
	[PlanID] [nvarchar](255) NULL,
	[ICE] [nvarchar](255) NULL,
	[Warehouse] [nvarchar](255) NULL,
	[First] [varchar](50) NULL,
	[Last] [varchar](50) NULL,
	[ID] [int] NOT NULL,
 CONSTRAINT [PK_CustomerImport] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CustomerIngredientCategoryExclusion]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerIngredientCategoryExclusion](
	[CustomerIngredientCategoryExclusionID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NOT NULL,
	[IngredientCategoryID] [int] NOT NULL,
 CONSTRAINT [PK_CustomerIngredientCatagoryExclusion] PRIMARY KEY CLUSTERED 
(
	[CustomerIngredientCategoryExclusionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CustomerIngredientExclusion]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerIngredientExclusion](
	[CustomerIngredientExclusionID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NOT NULL,
	[IngredientID] [int] NOT NULL,
	[IngredientLevelID] [int] NOT NULL,
 CONSTRAINT [PK_CustomerIngredientExclusion] PRIMARY KEY CLUSTERED 
(
	[CustomerIngredientExclusionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CustomerIngredientExclusionHistory]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CustomerIngredientExclusionHistory](
	[CustomerIngredientExclusionID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[IngredientID] [int] NOT NULL,
	[IngredientLevelID] [int] NOT NULL,
	[Status] [varchar](50) NOT NULL CONSTRAINT [DF_CustomerIngredientExclusionHistory_Status]  DEFAULT (''),
	[LastAction] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CustomerMeal]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerMeal](
	[CustomerMealID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NOT NULL,
	[MealID] [int] NOT NULL,
	[Approved] [bit] NOT NULL CONSTRAINT [DF_CustomerMeal_Approved]  DEFAULT ((0)),
	[Override] [bit] NOT NULL CONSTRAINT [DF_CustomerMeal_Override]  DEFAULT ((0)),
	[LastAction] [datetime] NULL,
	[Rating] [int] NOT NULL CONSTRAINT [DF_CustomerMeal_Rating]  DEFAULT ((0)),
	[IngredientStatus] [int] NOT NULL CONSTRAINT [DF_CustomerMeal_IngredientStatus]  DEFAULT ((1)),
	[CustomerStatus] [int] NOT NULL CONSTRAINT [DF_CustomerMeal_CustomerStatus]  DEFAULT ((0)),
 CONSTRAINT [PK_CustomerMeal] PRIMARY KEY CLUSTERED 
(
	[CustomerMealID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CustomerMealHistory]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerMealHistory](
	[CustomerMealReferenceID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NOT NULL,
	[MealID] [int] NOT NULL,
	[Approved] [bit] NOT NULL CONSTRAINT [DF_CustomerMealHistory_Approved]  DEFAULT ((0)),
	[Override] [bit] NOT NULL CONSTRAINT [DF_CustomerMealHistory_Override]  DEFAULT ((0)),
	[LastAction] [datetime] NULL,
	[Rating] [int] NOT NULL CONSTRAINT [DF_CustomerMealHistory_Rating]  DEFAULT ((0)),
	[IngredientStatus] [int] NOT NULL CONSTRAINT [DF_CustomerMealHistory_IngredientStatus]  DEFAULT ((1)),
	[CustomerStatus] [int] NOT NULL CONSTRAINT [DF_CustomerMealHistory_CustomerStatus]  DEFAULT ((0)),
 CONSTRAINT [PK_CustomerMealHistory] PRIMARY KEY CLUSTERED 
(
	[CustomerMealReferenceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CustomerPayment]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CustomerPayment](
	[CustomerPaymentID] [int] IDENTITY(1,1) NOT NULL,
	[CardNumber] [varchar](255) NOT NULL,
	[ExpMonth] [int] NOT NULL,
	[ExpYear] [int] NOT NULL,
	[LastFour] [char](4) NOT NULL,
	[NameOnCard] [varchar](255) NOT NULL,
	[CardType] [int] NOT NULL,
	[SecurityCode] [varchar](4) NULL,
	[DefaultPayment] [bit] NOT NULL,
	[CustomerID] [int] NOT NULL,
 CONSTRAINT [PK_CustomerPayment] PRIMARY KEY CLUSTERED 
(
	[CustomerPaymentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CustomerPlan]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CustomerPlan](
	[CustomerPlanID] [int] IDENTITY(10000,1) NOT NULL,
	[CustomerID] [int] NOT NULL,
	[PlanID] [int] NOT NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[Week] [int] NOT NULL CONSTRAINT [DF_CustomerPlan_PlanWeekID]  DEFAULT ((0)),
	[TotalWeek] [int] NOT NULL CONSTRAINT [DF_CustomerPlan_TotalWeek]  DEFAULT ((0)),
	[PreferedShipDayOfWeek] [int] NOT NULL CONSTRAINT [DF_CustomerPlan_PreferedShipDay]  DEFAULT ((1)),
	[Price] [money] NULL,
	[Shipping] [money] NULL,
	[PromoID] [int] NULL,
	[Nickname] [varchar](255) NULL,
	[LegacyOrderID] [int] NULL,
	[IsDynamic] [bit] NOT NULL CONSTRAINT [DF_CustomerPlan_IsDynamic]  DEFAULT ((0)),
	[DynamicBreakfast] [int] NOT NULL CONSTRAINT [DF_CustomerPlan_DynamicBreakfast]  DEFAULT ((0)),
	[DynamicLunch] [int] NOT NULL CONSTRAINT [DF_CustomerPlan_DynamicLunch]  DEFAULT ((0)),
	[DynamicDinner] [int] NOT NULL CONSTRAINT [DF_CustomerPlan_DynamicDinner]  DEFAULT ((0)),
	[DynamicSnack] [int] NOT NULL CONSTRAINT [DF_CustomerPlan_DynamicSnack]  DEFAULT ((0)),
	[IsDeleted] [bit] NOT NULL CONSTRAINT [DF_CustomerPlan_IsDeleted]  DEFAULT ((0)),
 CONSTRAINT [PK_CustomerPlan] PRIMARY KEY CLUSTERED 
(
	[CustomerPlanID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CustomerPlanHold]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerPlanHold](
	[CustomerPlanHoldID] [int] NOT NULL,
	[HoldDate] [datetime] NULL,
	[ResumeDate] [datetime] NULL,
	[Notes] [text] NULL,
	[CustomerPlanID] [int] NOT NULL,
 CONSTRAINT [PK_CustomerPlanHold] PRIMARY KEY CLUSTERED 
(
	[CustomerPlanHoldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CustomerStatus]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CustomerStatus](
	[CustomerStatusID] [int] IDENTITY(1,1) NOT NULL,
	[Status] [varchar](50) NOT NULL,
 CONSTRAINT [PK_CustomerStatus] PRIMARY KEY CLUSTERED 
(
	[CustomerStatusID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CustomerType]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CustomerType](
	[CustomerTypeId] [int] NOT NULL,
	[Status] [varchar](10) NOT NULL,
 CONSTRAINT [PK_OrderType] PRIMARY KEY CLUSTERED 
(
	[CustomerTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CustomOrder]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CustomOrder](
	[CustomOrderID] [int] IDENTITY(1,1) NOT NULL,
	[BuildDate] [datetime] NULL,
	[PrintDate] [datetime] NULL,
	[OrderStatusID] [int] NULL,
	[ShippedWeight] [int] NULL,
	[TrackingNumber] [varchar](255) NULL,
	[ShipDate] [datetime] NULL,
	[ReceivedDate] [datetime] NULL,
	[MealWeight] [int] NULL,
	[PackagingWeight] [int] NULL,
	[CustomerID] [int] NULL,
	[PlanID] [int] NULL,
	[Week] [int] NULL,
	[Address1] [varchar](255) NULL,
	[Address2] [varchar](255) NULL,
	[City] [varchar](255) NULL,
	[StateID] [int] NULL,
	[PostalCode] [varchar](255) NULL,
	[Phone] [varchar](255) NULL,
	[DeliveryInstructions] [varchar](255) NULL,
	[Ice] [int] NULL,
	[BusinessAddress] [bit] NULL,
	[PaymentStatus] [int] NULL,
	[Price] [money] NULL,
	[Shipping] [money] NULL,
	[PickListComments] [varchar](255) NULL,
	[MenuComments] [varchar](255) NULL,
	[PickListOrderPrintID] [int] NULL,
	[MenuOrderPrintID] [int] NULL,
	[FirstOrder] [bit] NULL,
	[SecondOrder] [bit] NULL,
	[MovedToOrder] [bit] NULL,
	[OpportunityName] [varchar](max) NULL,
	[BuildID] [int] NULL,
 CONSTRAINT [PK_CustomOrder] PRIMARY KEY CLUSTERED 
(
	[CustomOrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CustomOrderDay]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomOrderDay](
	[CustomOrderDayID] [int] IDENTITY(1,1) NOT NULL,
	[CustomOrderID] [int] NOT NULL,
	[Day] [int] NOT NULL,
 CONSTRAINT [PK_CustomOrderDay] PRIMARY KEY CLUSTERED 
(
	[CustomOrderDayID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CustomOrderDayMeal]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CustomOrderDayMeal](
	[CustomOrderDayMealID] [int] IDENTITY(1,1) NOT NULL,
	[MealID] [int] NOT NULL,
	[MealName] [varchar](255) NULL,
	[MealDescription] [varchar](max) NULL,
	[IsSubstitute] [bit] NOT NULL,
	[CustomOrderDayID] [int] NOT NULL,
	[MealTypeID] [int] NOT NULL,
	[IsAutoSubstitute] [bit] NULL,
	[Priority] [int] NULL,
 CONSTRAINT [PK_CustomOrderDayMeal] PRIMARY KEY CLUSTERED 
(
	[CustomOrderDayMealID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EmailNotification]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmailNotification](
	[MailID] [int] NOT NULL,
	[From] [nvarchar](60) NOT NULL,
	[To] [nvarchar](max) NOT NULL,
	[CC] [nvarchar](max) NULL,
	[Subject] [nvarchar](max) NULL,
	[Body] [nvarchar](max) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NULL CONSTRAINT [DF_EmailNotification_ModifiedDate]  DEFAULT (getdate()),
 CONSTRAINT [PK_EmailNotification] PRIMARY KEY CLUSTERED 
(
	[MailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ErrorLog]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ErrorLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ErrorNo] [varchar](50) NULL,
	[Application] [varchar](max) NULL,
	[Function] [varchar](max) NULL,
	[ErrorDesc] [varchar](max) NULL,
	[DetailedDesc] [varchar](max) NULL,
	[CreatedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ErrorLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FishBowl]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FishBowl](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CARRIERNAME] [nvarchar](30) NULL,
	[TaxRateName] [nchar](31) NULL,
	[SOItemTypeID] [int] NULL,
	[ProductQuantity] [int] NULL,
	[UOM] [text] NULL,
	[ProductPrice] [int] NULL,
	[Taxable] [bit] NULL,
	[QuickBooksClassName] [text] NULL,
	[ShowItem] [bit] NULL,
	[KitItem] [bit] NULL,
 CONSTRAINT [PK_FishBowl] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Ingredient]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Ingredient](
	[IngredientID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[IsVisible] [bit] NOT NULL CONSTRAINT [DF_Ingredient_IsVisible]  DEFAULT ((0)),
	[RestrictionCount] [int] NOT NULL DEFAULT ((0)),
 CONSTRAINT [PK_Ingredient] PRIMARY KEY CLUSTERED 
(
	[IngredientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[IngredientCategory]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IngredientCategory](
	[IngredientCategoryID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NOT NULL CONSTRAINT [DF_IngredientCatagory_Name]  DEFAULT (''),
	[IsVisible] [bit] NOT NULL CONSTRAINT [DF_IngredientCategory_IsVisible]  DEFAULT ((0)),
 CONSTRAINT [PK_IngredientCatagory] PRIMARY KEY CLUSTERED 
(
	[IngredientCategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[IngredientIngredientCategory]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IngredientIngredientCategory](
	[IngredientIngredientCategoryID] [int] IDENTITY(1,1) NOT NULL,
	[IngredientCategoryID] [int] NOT NULL,
	[IngredientID] [int] NOT NULL,
 CONSTRAINT [PK_IngredientIngredientCategory] PRIMARY KEY CLUSTERED 
(
	[IngredientIngredientCategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[IngredientIngredientStatus]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IngredientIngredientStatus](
	[IngredientID] [int] NOT NULL,
	[StatusID] [int] NOT NULL,
	[Description] [varchar](500) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[IngredientLevel]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IngredientLevel](
	[IngredientLevelID] [int] IDENTITY(1,1) NOT NULL,
	[MealText] [varchar](50) NOT NULL CONSTRAINT [DF_IngredientLevel_LevelText]  DEFAULT (''),
	[CustomerText] [varchar](50) NULL,
 CONSTRAINT [PK_IngredientLevel] PRIMARY KEY CLUSTERED 
(
	[IngredientLevelID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[IngredientStatus]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IngredientStatus](
	[StatusID] [int] NOT NULL,
	[Description] [varchar](255) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[InventoryItem]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InventoryItem](
	[InventoryItemID] [int] IDENTITY(1,1) NOT NULL,
	[SKU] [varchar](50) NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[SupplierID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[CostPerUnit] [money] NOT NULL,
	[CostPerCase] [money] NOT NULL,
	[UnitsPerCase] [int] NOT NULL,
	[OrderLeadDays] [int] NOT NULL,
	[QuantityInProcess] [int] NOT NULL,
	[QuantityShipped] [int] NOT NULL,
	[QuantityLost] [int] NOT NULL,
	[LocatorBin] [int] NOT NULL,
	[LocatorLevel] [varchar](1) NOT NULL,
	[ItemType] [int] NOT NULL,
 CONSTRAINT [PK_InventoryItem] PRIMARY KEY CLUSTERED 
(
	[InventoryItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[InventoryItemUsage]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InventoryItemUsage](
	[InventoryItemUsageID] [int] IDENTITY(1,1) NOT NULL,
	[ShipDate] [datetime] NOT NULL,
	[InventoryItemID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
 CONSTRAINT [PK_MealUsage] PRIMARY KEY CLUSTERED 
(
	[InventoryItemUsageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[InvImport]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvImport](
	[ID] [float] NULL,
	[Description] [nvarchar](255) NULL,
	[Qty] [float] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[IPAccess]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IPAccess](
	[IPAccessID] [int] IDENTITY(1,1) NOT NULL,
	[IPAddress] [varchar](50) NOT NULL,
	[AddedDate] [datetime] NULL,
	[Description] [varchar](255) NOT NULL,
 CONSTRAINT [PK_IPAccess] PRIMARY KEY CLUSTERED 
(
	[IPAccessID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Logging]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Logging](
	[LoggingID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](50) NULL,
	[Logged] [datetime] NULL,
	[EventName] [varchar](255) NULL,
	[URL] [varchar](255) NULL,
	[SiteID] [int] NULL,
	[Exception] [text] NULL,
 CONSTRAINT [PK_Logging] PRIMARY KEY CLUSTERED 
(
	[LoggingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LoggingForMyBistroMD]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoggingForMyBistroMD](
	[LoggingID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](50) NULL,
	[Logged] [datetime] NULL,
	[EventName] [varchar](225) NULL,
	[URL] [varchar](225) NULL,
	[SiteID] [int] NULL,
	[Exception] [text] NULL,
 CONSTRAINT [PK_LoggingForMyBistroMD] PRIMARY KEY CLUSTERED 
(
	[LoggingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MailTrack]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MailTrack](
	[MailTrackId] [int] IDENTITY(1,1) NOT NULL,
	[CustomerName] [varchar](50) NOT NULL,
	[MailId] [varchar](50) NOT NULL,
	[MailStatus] [bit] NOT NULL,
	[TrackingNum] [varchar](50) NULL,
	[SentOn] [date] NULL,
 CONSTRAINT [PK_MailTrack] PRIMARY KEY CLUSTERED 
(
	[MailTrackId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Meal]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Meal](
	[MealID] [int] IDENTITY(1000,1) NOT NULL,
	[Active] [bit] NOT NULL CONSTRAINT [DF_Meal_Active]  DEFAULT ((1)),
	[SKU] [varchar](50) NOT NULL CONSTRAINT [DF_Meal_SKU]  DEFAULT (''),
	[Name] [varchar](255) NOT NULL CONSTRAINT [DF_Meal_Name]  DEFAULT (''),
	[MealTypeID] [int] NOT NULL CONSTRAINT [DF_Meal_MealTypeID]  DEFAULT ((1)),
	[ShortDescription] [varchar](255) NOT NULL CONSTRAINT [DF_Meal_ShortDescription]  DEFAULT (''),
	[LongDescription] [text] NOT NULL CONSTRAINT [DF_Meal_Description]  DEFAULT (''),
	[Calories] [decimal](10, 2) NOT NULL CONSTRAINT [DF_Meal_CalorieGroupID]  DEFAULT ((0)),
	[CaloriesFromFat] [decimal](10, 2) NOT NULL CONSTRAINT [DF_Meal_CaloriesFromFat]  DEFAULT ((0)),
	[TotalFat] [decimal](10, 2) NOT NULL CONSTRAINT [DF_Meal_Fat]  DEFAULT ((0)),
	[SaturatedFat] [decimal](10, 2) NOT NULL CONSTRAINT [DF_Meal_SaturatedFat]  DEFAULT ((0)),
	[TransFat] [decimal](10, 2) NOT NULL CONSTRAINT [DF_Meal_TransFat]  DEFAULT ((0)),
	[Cholesterol] [decimal](10, 2) NOT NULL CONSTRAINT [DF_Meal_Cholesterol]  DEFAULT ((0)),
	[Protein] [decimal](10, 2) NOT NULL CONSTRAINT [DF_Meal_Protein]  DEFAULT ((0)),
	[Carbohydrate] [decimal](10, 2) NOT NULL CONSTRAINT [DF_Meal_Carbs]  DEFAULT ((0)),
	[DietaryFiber] [decimal](10, 2) NOT NULL CONSTRAINT [DF_Meal_Fiber]  DEFAULT ((0)),
	[Sugars] [decimal](10, 2) NOT NULL CONSTRAINT [DF_Meal_Sugars]  DEFAULT ((0)),
	[Sodium] [decimal](10, 2) NOT NULL CONSTRAINT [DF_Meal_Sodium]  DEFAULT ((0)),
	[AddDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
	[Status] [int] NOT NULL CONSTRAINT [DF_Meal_Status]  DEFAULT ((0)),
	[Quantity] [int] NOT NULL CONSTRAINT [DF_Meal_Quantity]  DEFAULT ((0)),
	[CutoffQuantity] [int] NOT NULL CONSTRAINT [DF_Meal_CutoffQuantity]  DEFAULT ((0)),
	[QuantityInProcess] [int] NOT NULL CONSTRAINT [DF_Meal_QuantityInProcess]  DEFAULT ((0)),
	[QuantityShipped] [int] NOT NULL CONSTRAINT [DF_Meal_QuantityShipped]  DEFAULT ((0)),
	[AlertLevelQuantity] [int] NOT NULL CONSTRAINT [DF_Meal_AlertLevelQuantity]  DEFAULT ((0)),
	[ItemCount] [int] NOT NULL CONSTRAINT [DF_Meal_ItemCount]  DEFAULT ((0)),
	[IsDeleted] [bit] NOT NULL CONSTRAINT [DF_Meal_isDeleted]  DEFAULT ((0)),
	[ProductNumber] [varchar](50) NOT NULL CONSTRAINT [DF_Meal_SKU1]  DEFAULT (''),
	[AllocatedQuantity] [int] NOT NULL CONSTRAINT [DF__Meal__AllocatedQ__5BA4467E]  DEFAULT ((0)),
	[BistroMDActive] [int] NULL,
	[DisplayOrder] [int] NULL,
	[TotalQuantity] [int] NULL CONSTRAINT [DF_Meal_TotalQuantity]  DEFAULT ((0)),
	[IsGluten] [bit] NULL,
	[MyBistroMDActive] [bit] NULL,
	[ingredient_label] [ntext] NULL,
 CONSTRAINT [PK_Meal_1] PRIMARY KEY CLUSTERED 
(
	[MealID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MealImageCategory]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MealImageCategory](
	[MealImageCategoryID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NOT NULL CONSTRAINT [DF_ImageCategory_Name]  DEFAULT (''),
	[Path] [varchar](255) NOT NULL CONSTRAINT [DF_ImageCategory_Path]  DEFAULT (''),
	[LocalPath] [varchar](255) NOT NULL CONSTRAINT [DF_ImageCategory_LocalPath]  DEFAULT (''),
	[Height] [int] NOT NULL,
	[Width] [int] NOT NULL,
	[Format] [varchar](50) NOT NULL,
 CONSTRAINT [PK_ImageCategory] PRIMARY KEY CLUSTERED 
(
	[MealImageCategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MealIngredient]    Script Date: 8/20/2016 10:36:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MealIngredient](
	[MealIngredientID] [int] IDENTITY(1,1) NOT NULL,
	[MealID] [int] NOT NULL,
	[IngredientID] [int] NOT NULL,
	[IngredientLevelID] [int] NOT NULL,
 CONSTRAINT [PK_MealIngredient] PRIMARY KEY CLUSTERED 
(
	[MealIngredientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MealInventoryItem]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MealInventoryItem](
	[MealInventoryItemID] [int] IDENTITY(1,1) NOT NULL,
	[MealID] [int] NOT NULL,
	[InventoryItemID] [int] NOT NULL,
	[ItemCount] [int] NOT NULL,
 CONSTRAINT [PK_MealInventoryItem] PRIMARY KEY CLUSTERED 
(
	[MealInventoryItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MealPlanDetails]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MealPlanDetails](
	[MealPlanID] [int] IDENTITY(1,1) NOT NULL,
	[MealID] [int] NOT NULL CONSTRAINT [DF_MealPlanDetails_MealID]  DEFAULT ((0)),
	[PlanID] [int] NOT NULL CONSTRAINT [DF_MealPlanDetails_PlanID]  DEFAULT ((0)),
 CONSTRAINT [PK_MealPlanDetails] PRIMARY KEY CLUSTERED 
(
	[MealPlanID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MealStatus]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MealStatus](
	[MealStatus] [int] NOT NULL CONSTRAINT [DF_MealStatus_MealStatus]  DEFAULT ((0)),
	[Description] [varchar](50) NOT NULL CONSTRAINT [DF_MealStatus_Description]  DEFAULT (''),
 CONSTRAINT [PK_MealStatus] PRIMARY KEY CLUSTERED 
(
	[MealStatus] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MealSubstitute]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MealSubstitute](
	[MealSubstituteID] [int] IDENTITY(1,1) NOT NULL,
	[MealID] [int] NOT NULL,
	[SubstituteMealID] [int] NOT NULL,
	[Priority] [int] NOT NULL CONSTRAINT [DF_MealSubstitute_Sequence]  DEFAULT ((1)),
	[SubstitutePlanID] [int] NOT NULL CONSTRAINT [DF_MealSubstitute_SubstitutePlanID]  DEFAULT ((2)),
 CONSTRAINT [PK_MealSubstitute] PRIMARY KEY CLUSTERED 
(
	[MealSubstituteID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MealType]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MealType](
	[MealTypeID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NOT NULL CONSTRAINT [DF_MealType_Name]  DEFAULT (''),
 CONSTRAINT [PK_MealType] PRIMARY KEY CLUSTERED 
(
	[MealTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MembershipLogin]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MembershipLogin](
	[ApplicationId] [uniqueidentifier] NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[Password] [nvarchar](128) NULL,
	[PasswordFormat] [int] NOT NULL,
	[PasswordSalt] [nvarchar](128) NOT NULL,
	[Email] [varchar](200) NULL,
	[PasswordQuestion] [nvarchar](256) NULL,
	[PasswordAnswer] [nvarchar](128) NULL,
	[IsApproved] [bit] NOT NULL,
	[IsLockedOut] [bit] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastLoginDate] [datetime] NOT NULL,
	[LastPasswordChangedDate] [datetime] NOT NULL,
	[LastLockoutDate] [datetime] NOT NULL,
	[FailedPasswordAttemptCount] [int] NOT NULL,
	[FailedPasswordAttemptWindowStart] [datetime] NOT NULL,
	[FailedPasswordAnswerAttemptCount] [int] NOT NULL,
	[FailedPasswordAnswerAttemptWindowsStart] [datetime] NOT NULL,
	[Comment] [nvarchar](256) NULL,
	[CustomerID] [int] NULL,
	[First] [varchar](50) NOT NULL CONSTRAINT [DF_MembershipLogin_First]  DEFAULT (''),
	[Last] [varchar](50) NOT NULL CONSTRAINT [DF_MembershipLogin_Last]  DEFAULT (''),
PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MyProfileDetails]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MyProfileDetails](
	[CustomerID] [int] NOT NULL,
	[CurrentWeight] [varchar](255) NULL,
	[GoalWeight] [varchar](255) NULL,
	[TimeFrame] [varchar](255) NULL,
	[Height] [varchar](255) NULL,
	[Inches] [varchar](255) NULL,
	[ActivityLevel] [varchar](255) NULL,
	[Gender] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Order]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Order](
	[OrderID] [int] IDENTITY(100000,1) NOT NULL,
	[BuildDate] [datetime] NULL,
	[PrintDate] [datetime] NULL,
	[OrderStatusID] [int] NOT NULL CONSTRAINT [DF_Order_OrderStatusID]  DEFAULT ((1)),
	[ShippedWeight] [int] NOT NULL CONSTRAINT [DF_Order_ShippedWeight]  DEFAULT ((0)),
	[TrackingNumber] [varchar](255) NOT NULL CONSTRAINT [DF_Order_TrackingNumber]  DEFAULT (''),
	[ShipDate] [datetime] NULL,
	[ReceivedDate] [datetime] NULL,
	[MealWeight] [int] NOT NULL CONSTRAINT [DF_Order_MealWeight]  DEFAULT ((0)),
	[PackagingWeight] [int] NOT NULL CONSTRAINT [DF_Order_PackagingWeight]  DEFAULT ((0)),
	[CustomerID] [int] NOT NULL,
	[PlanID] [int] NOT NULL CONSTRAINT [DF_Order_PlanID]  DEFAULT ((1)),
	[Week] [int] NOT NULL CONSTRAINT [DF_Order_Week]  DEFAULT ((0)),
	[Address1] [varchar](255) NOT NULL CONSTRAINT [DF_Order_Address1]  DEFAULT (''),
	[Address2] [varchar](255) NOT NULL CONSTRAINT [DF_Order_Address2]  DEFAULT (''),
	[City] [varchar](255) NOT NULL CONSTRAINT [DF_Order_City]  DEFAULT (''),
	[StateID] [int] NOT NULL CONSTRAINT [DF_Order_StateID]  DEFAULT ((1)),
	[PostalCode] [varchar](255) NOT NULL CONSTRAINT [DF_Order_PostalCode]  DEFAULT (''),
	[Phone] [varchar](255) NOT NULL CONSTRAINT [DF_Order_Phone]  DEFAULT (''),
	[DeliveryInstructions] [varchar](255) NOT NULL CONSTRAINT [DF_Order_DeliveryInstructions]  DEFAULT (''),
	[Ice] [int] NOT NULL CONSTRAINT [DF_Order_Ice]  DEFAULT ((1)),
	[BusinessAddress] [bit] NOT NULL CONSTRAINT [DF_Order_BusinessAddress]  DEFAULT ((0)),
	[PaymentStatus] [int] NOT NULL CONSTRAINT [DF_Order_PaymentStatus]  DEFAULT ((1)),
	[Price] [money] NULL,
	[Shipping] [money] NULL,
	[PickListComments] [varchar](1000) NULL,
	[MenuComments] [varchar](255) NULL,
	[PickListOrderPrintID] [int] NULL,
	[MenuOrderPrintID] [int] NULL,
	[FirstOrder] [bit] NULL CONSTRAINT [DF_Order_FirstOrder]  DEFAULT ((0)),
	[SecondOrder] [bit] NULL CONSTRAINT [DF_Order_SecondOrder]  DEFAULT ((0)),
	[OpportunityName] [varchar](max) NULL,
	[BuildID] [int] NOT NULL CONSTRAINT [DF_Order_BuildID_1]  DEFAULT ((0)),
	[Custom] [bit] NULL,
	[OpportunityId] [varchar](50) NULL,
	[OrderTypeId] [int] NULL,
 CONSTRAINT [PK_Order] PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[OrderDay]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderDay](
	[OrderDayID] [int] IDENTITY(1,1) NOT NULL,
	[OrderID] [int] NOT NULL,
	[Day] [int] NOT NULL CONSTRAINT [DF_OrderDay_Day]  DEFAULT ((1)),
 CONSTRAINT [PK_OrderDay] PRIMARY KEY CLUSTERED 
(
	[OrderDayID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[OrderDayHistory]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderDayHistory](
	[OrderDayID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[Day] [int] NOT NULL CONSTRAINT [DF_OrderDayHistory_Day]  DEFAULT ((1)),
	[LastAction] [datetime] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[OrderDayMeal]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderDayMeal](
	[OrderDayMealID] [int] IDENTITY(1,1) NOT NULL,
	[MealID] [int] NOT NULL,
	[IsSubstitute] [bit] NOT NULL,
	[OrderDayID] [int] NOT NULL,
	[MealTypeID] [int] NOT NULL CONSTRAINT [DF_OrderDayMeal_MealTypeID]  DEFAULT ((1)),
	[Priority] [int] NULL CONSTRAINT [DF_OrderDayMeal_Priority]  DEFAULT ((0)),
 CONSTRAINT [PK_OrderDayMeal] PRIMARY KEY CLUSTERED 
(
	[OrderDayMealID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[OrderDayMealHistory]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderDayMealHistory](
	[OrderDayMealID] [int] NOT NULL,
	[MealID] [int] NOT NULL,
	[IsSubstitute] [bit] NOT NULL,
	[OrderDayID] [int] NOT NULL,
	[MealTypeID] [int] NOT NULL CONSTRAINT [DF_OrderDayMealHistory_MealTypeID]  DEFAULT ((1)),
	[LastAction] [datetime] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[OrderPayment]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[OrderPayment](
	[OrderPaymentID] [int] IDENTITY(1,1) NOT NULL,
	[OrderID] [int] NOT NULL,
	[Amount] [money] NULL,
	[CardNumber] [varchar](255) NOT NULL,
	[ExpMonth] [int] NOT NULL,
	[ExpYear] [int] NOT NULL,
	[LastFour] [char](4) NOT NULL,
	[NameOnCard] [varchar](255) NOT NULL,
	[CardType] [int] NOT NULL,
	[SecurityCode] [varchar](4) NULL,
	[AuthDate] [datetime] NULL,
	[AuthResponseCode] [int] NULL,
	[AuthApproved] [bit] NULL,
	[AuthTransactionID] [varchar](255) NULL,
	[AuthMessage] [varchar](255) NULL,
	[AuthAuthorizationCode] [varchar](255) NULL,
	[CaptureDate] [datetime] NULL,
	[CaptureResponseCode] [int] NULL,
	[CaptureApproved] [bit] NULL,
	[CaptureTransactionID] [varchar](255) NULL,
	[CaptureMessage] [varchar](255) NULL,
	[CaptureAuthorizationCode] [varchar](255) NULL,
 CONSTRAINT [PK_OrderPayment] PRIMARY KEY CLUSTERED 
(
	[OrderPaymentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[OrderPrint]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[OrderPrint](
	[OrderPrintID] [int] IDENTITY(1,1) NOT NULL,
	[Title] [varchar](255) NOT NULL,
	[GeneratedDate] [datetime] NOT NULL,
	[TargetDate] [datetime] NOT NULL,
 CONSTRAINT [PK_OrderPrint] PRIMARY KEY CLUSTERED 
(
	[OrderPrintID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[OrderRegeneration]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[OrderRegeneration](
	[OrderRegenerationID] [int] IDENTITY(1,1) NOT NULL,
	[OrderID] [int] NOT NULL,
	[MyBistroRemarks] [varchar](max) NOT NULL CONSTRAINT [DF_OrderRegeneration_MyBistroRemarks]  DEFAULT (''),
	[OrdercreationRemarks] [varchar](max) NOT NULL CONSTRAINT [DF_OrderRegeneration_OrdercreationRemarks]  DEFAULT (''),
	[UpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_OrderRegeneration] PRIMARY KEY CLUSTERED 
(
	[OrderRegenerationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[OrderStatus]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[OrderStatus](
	[OrderStatusID] [int] IDENTITY(1,1) NOT NULL,
	[Status] [varchar](50) NOT NULL,
 CONSTRAINT [PK_OrderStatus] PRIMARY KEY CLUSTERED 
(
	[OrderStatusID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[OrderTypes]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[OrderTypes](
	[OrderTypeId] [int] IDENTITY(1,1) NOT NULL,
	[Status] [varchar](8000) NULL,
PRIMARY KEY CLUSTERED 
(
	[OrderTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[OrderTypeSettings]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[OrderTypeSettings](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Active] [bit] NOT NULL,
	[LastModified] [datetime] NOT NULL,
 CONSTRAINT [PK_OrderTypeSettings] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Page]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Page](
	[PageID] [int] IDENTITY(1,1) NOT NULL,
	[SiteID] [int] NULL,
	[Name] [varchar](50) NULL,
	[URL] [varchar](255) NULL,
	[TitleBar] [varchar](255) NULL,
	[LinkText] [varchar](50) NULL,
	[MetaDescription] [text] NULL,
	[MetaKeywords] [text] NULL,
	[InHeader] [text] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[PublishDate] [datetime] NULL,
	[ExpiresDate] [datetime] NULL,
	[ParentPageID] [int] NULL,
	[PageCategoryID] [int] NULL,
	[ThemeLayoutID] [int] NULL,
	[ListOrder] [int] NULL,
	[OnSitemap] [bit] NULL,
	[MembersOnly] [bit] NULL,
	[AdminsOnly] [bit] NULL,
	[RequireSSL] [bit] NULL,
	[IsPublished] [bit] NULL,
 CONSTRAINT [PK_Page] PRIMARY KEY CLUSTERED 
(
	[PageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PageAlias]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PageAlias](
	[PageAliasID] [int] IDENTITY(1,1) NOT NULL,
	[SiteID] [int] NOT NULL,
	[AliasURL] [varchar](255) NOT NULL,
	[PageID] [int] NOT NULL,
	[PermanentRedirect] [bit] NOT NULL,
 CONSTRAINT [PK_PageAlias] PRIMARY KEY CLUSTERED 
(
	[PageAliasID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PageControl]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PageControl](
	[PageControlID] [int] IDENTITY(1,1) NOT NULL,
	[PageID] [int] NOT NULL,
	[SiteID] [int] NOT NULL,
	[PageContainerID] [int] NOT NULL,
	[ControlID] [int] NOT NULL,
	[ControlOptionID] [int] NOT NULL,
	[ControlOrder] [int] NOT NULL,
	[ControlNickname] [varchar](50) NULL,
	[ControlInheritID] [int] NOT NULL,
 CONSTRAINT [PK_PageControl] PRIMARY KEY CLUSTERED 
(
	[PageControlID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PaymentStatus]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PaymentStatus](
	[PaymentStatusId] [int] IDENTITY(1,1) NOT NULL,
	[Status] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PaymentStatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PdfTemplate]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PdfTemplate](
	[PdfTemplateId] [int] IDENTITY(1,1) NOT NULL,
	[PdfTemplateName] [varchar](50) NULL,
	[ProgramID] [int] NULL,
 CONSTRAINT [PK_PdfTemplate] PRIMARY KEY CLUSTERED 
(
	[PdfTemplateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PendingNotification]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PendingNotification](
	[NotificationId] [int] IDENTITY(1,1) NOT NULL,
	[NotificationUser] [int] NOT NULL,
	[Message] [varchar](1000) NOT NULL,
	[IsNotified] [bit] NOT NULL,
 CONSTRAINT [PK_PendingNotification] PRIMARY KEY CLUSTERED 
(
	[NotificationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PermissionByRole]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PermissionByRole](
	[PermissionRoleId] [int] IDENTITY(1,1) NOT NULL,
	[PageId] [int] NOT NULL,
	[RoleId] [int] NOT NULL,
	[IsFullAccess] [bit] NULL,
	[IsReadOnly] [bit] NULL,
	[IsEditAccess] [bit] NULL,
	[IsDeleteAccess] [bit] NULL,
	[CreatedOn] [datetime] NULL,
	[CreatedBy] [varchar](50) NULL,
	[UpdtaedOn] [datetime] NULL,
	[UpdatedBy] [varchar](50) NULL,
 CONSTRAINT [PK_PermissionByRole] PRIMARY KEY CLUSTERED 
(
	[PermissionRoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Physical]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Physical](
	[PhysicalID] [int] IDENTITY(1,1) NOT NULL,
	[PhysicalDate] [datetime] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[Items] [int] NOT NULL,
 CONSTRAINT [PK_Physical] PRIMARY KEY CLUSTERED 
(
	[PhysicalID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PhysicalInventoryItem]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PhysicalInventoryItem](
	[PhysicalInventoryItemID] [int] IDENTITY(1,1) NOT NULL,
	[InventoryItemID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[PhysicalID] [int] NOT NULL,
	[PendingOrders] [int] NOT NULL,
	[Reported] [int] NOT NULL,
 CONSTRAINT [PK_PhysicalInventoryItem] PRIMARY KEY CLUSTERED 
(
	[PhysicalInventoryItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Plan]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Plan](
	[PlanID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](255) NOT NULL CONSTRAINT [DF_Plan_Name]  DEFAULT (''),
	[DisplayName] [varchar](255) NULL,
	[Description] [text] NULL,
	[IsCustomPlan] [bit] NOT NULL CONSTRAINT [DF_Plan_IsCustomPlan]  DEFAULT ((0)),
	[ProgramID] [int] NOT NULL CONSTRAINT [DF_Plan_ProgramID]  DEFAULT ((1)),
	[Active] [bit] NOT NULL CONSTRAINT [DF_Plan_Active]  DEFAULT ((1)),
	[Price] [money] NULL,
	[CostPerDay] [money] NULL,
	[Shipping] [money] NULL,
	[DoNotSubstitute] [bit] NOT NULL CONSTRAINT [DF_Plan_DoNotSubstitute]  DEFAULT ((0)),
	[IsDeleted] [bit] NOT NULL CONSTRAINT [DF_Plan_IsDeleted]  DEFAULT ((0)),
	[IsSnack] [bit] NOT NULL CONSTRAINT [DF_Plan_IsSnack]  DEFAULT ((0)),
	[SnackTemplateId] [int] NULL,
 CONSTRAINT [PK_Plan] PRIMARY KEY CLUSTERED 
(
	[PlanID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PlanDay]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PlanDay](
	[PlanDayID] [int] IDENTITY(1,1) NOT NULL,
	[PlanWeekID] [int] NOT NULL,
	[Day] [int] NOT NULL CONSTRAINT [DF_PlanDay_Day]  DEFAULT ((1)),
 CONSTRAINT [PK_PlanDay] PRIMARY KEY CLUSTERED 
(
	[PlanDayID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PlanDayMeal]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PlanDayMeal](
	[PlanDayMealID] [int] IDENTITY(1,1) NOT NULL,
	[PlanDayID] [int] NOT NULL,
	[MealTypeID] [int] NOT NULL,
	[MealID] [int] NOT NULL,
	[Priority] [int] NULL,
 CONSTRAINT [PK_PlanDayMeal] PRIMARY KEY CLUSTERED 
(
	[PlanDayMealID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PlanDetails]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PlanDetails](
	[CustomerID] [int] NOT NULL,
	[PlanType] [varchar](255) NULL,
	[DaysPerWeek] [varchar](255) NULL,
	[MealsPerDay] [varchar](255) NULL,
	[Snacks] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PlanWeek]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PlanWeek](
	[PlanWeekID] [int] IDENTITY(1,1) NOT NULL,
	[Week] [int] NOT NULL,
	[ShortDescription] [varchar](255) NULL CONSTRAINT [DF_PlanWeek_ShortDescription]  DEFAULT (''),
	[LongDescription] [text] NULL CONSTRAINT [DF_PlanWeek_LongDescription]  DEFAULT (''),
	[PlanID] [int] NOT NULL,
 CONSTRAINT [PK_PlanWeek] PRIMARY KEY CLUSTERED 
(
	[PlanWeekID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PrinterDetails]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PrinterDetails](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PrinterName] [varchar](max) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_PrinterDetails] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Profile]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Profile](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[PropertyNames] [ntext] NULL,
	[PropertyValuesString] [ntext] NULL,
	[PropertyValuesBinary] [image] NULL,
	[LastUpdatedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Profile_1] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Program]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Program](
	[ProgramID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](255) NOT NULL CONSTRAINT [DF_Program_Name]  DEFAULT (''),
	[Active] [bit] NOT NULL CONSTRAINT [DF_Program_Active]  DEFAULT ((1)),
	[IsDeleted] [bit] NOT NULL CONSTRAINT [DF_Program_IsDeleted]  DEFAULT ((0)),
 CONSTRAINT [PK_Program] PRIMARY KEY CLUSTERED 
(
	[ProgramID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Promo]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Promo](
	[PromoID] [int] IDENTITY(1,1) NOT NULL,
	[PomoCode] [varchar](50) NOT NULL,
	[Description] [text] NOT NULL,
	[DollarDiscount] [money] NOT NULL,
	[PercentDiscount] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[AppliesToPrice] [bit] NOT NULL,
	[AppliesToShipping] [bit] NOT NULL,
	[DollarLimit] [money] NOT NULL,
	[OrderLimit] [int] NOT NULL,
	[NewCustomerOnly] [bit] NOT NULL,
 CONSTRAINT [PK_Promo] PRIMARY KEY CLUSTERED 
(
	[PromoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PurchaseOrder]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PurchaseOrder](
	[PurchaseOrderID] [int] IDENTITY(1,1) NOT NULL,
	[SupplierID] [int] NOT NULL,
	[OrderDate] [datetime] NULL,
	[ExpectedDate] [datetime] NULL,
	[ReceivedDate] [datetime] NULL,
	[Status] [int] NOT NULL,
 CONSTRAINT [PK_PurchaseOrder] PRIMARY KEY CLUSTERED 
(
	[PurchaseOrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PurchaseOrderItem]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PurchaseOrderItem](
	[PurchaseOrderItemID] [int] IDENTITY(1,1) NOT NULL,
	[InventoryItemID] [int] NOT NULL,
	[QuantityOrdered] [int] NOT NULL,
	[QuantityReceived] [int] NOT NULL,
	[PurchaseOrderID] [int] NOT NULL,
 CONSTRAINT [PK_PurchaseOrderItem] PRIMARY KEY CLUSTERED 
(
	[PurchaseOrderItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Role]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Role](
	[RoleID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[ApplicationID] [int] NOT NULL,
 CONSTRAINT [PK_Role] PRIMARY KEY CLUSTERED 
(
	[RoleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SalesforceSyncReport]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SalesforceSyncReport](
	[SalesforceReportID] [int] IDENTITY(1,1) NOT NULL,
	[SyncDate] [datetime] NULL,
	[SyncGUID] [uniqueidentifier] NOT NULL,
	[ErrorType] [int] NOT NULL CONSTRAINT [DF_SalesforceSyncReport_ErrorType]  DEFAULT ((0)),
	[CustomerName] [varchar](500) NOT NULL CONSTRAINT [DF_SalesforceSyncReport_CustomerName]  DEFAULT (''),
	[Email] [varchar](200) NOT NULL CONSTRAINT [DF_SalesforceSyncReport_Email]  DEFAULT (''),
	[Exception] [text] NOT NULL CONSTRAINT [DF_SalesforceSyncReport_Exception]  DEFAULT (''),
 CONSTRAINT [PK_SalesforceSyncReport] PRIMARY KEY CLUSTERED 
(
	[SalesforceReportID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Setting]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Setting](
	[SettingID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Value] [varchar](255) NOT NULL,
 CONSTRAINT [PK_Setting] PRIMARY KEY CLUSTERED 
(
	[SettingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Site]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Site](
	[SiteID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NULL,
	[URL] [varchar](50) NULL,
	[ContactPhone] [varchar](50) NULL,
	[ContactEmail] [varchar](50) NULL,
	[ThemeID] [int] NULL,
	[TitlePrefix] [varchar](50) NULL,
	[UIThemeID] [int] NULL,
	[StagingSiteID] [int] NULL,
	[BackupSiteID] [int] NULL,
	[GoogleAnalytics] [varchar](50) NULL,
	[Active] [bit] NULL,
	[NotActiveRediret] [varchar](50) NULL,
 CONSTRAINT [PK_Site] PRIMARY KEY CLUSTERED 
(
	[SiteID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SiteURL]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SiteURL](
	[SiteID] [int] NOT NULL,
	[URL] [varchar](50) NOT NULL,
 CONSTRAINT [PK_SiteURL] PRIMARY KEY CLUSTERED 
(
	[SiteID] ASC,
	[URL] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[stagecu]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[stagecu](
	[CustomerID] [float] NULL,
	[Mealcount] [float] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[State]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[State](
	[StateID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](255) NOT NULL CONSTRAINT [DF_State_Name]  DEFAULT (''),
	[Abbreviation] [varchar](10) NOT NULL CONSTRAINT [DF_State_Abbreviation]  DEFAULT (''),
	[CountryID] [int] NOT NULL CONSTRAINT [DF_State_CountryID]  DEFAULT ((1)),
	[Ice] [int] NOT NULL CONSTRAINT [DF_State_Ice]  DEFAULT ((1)),
 CONSTRAINT [PK_State] PRIMARY KEY CLUSTERED 
(
	[StateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Supplier]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Supplier](
	[SupplierID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](255) NOT NULL CONSTRAINT [DF_Supplier_SupplierName]  DEFAULT (''),
	[ShortName] [varchar](10) NULL,
 CONSTRAINT [PK_Supplier] PRIMARY KEY CLUSTERED 
(
	[SupplierID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TempCustomMenu]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TempCustomMenu](
	[TempCustomMenuID] [int] IDENTITY(1,1) NOT NULL,
	[MealID] [int] NULL,
	[MealName] [varchar](255) NULL,
	[MealDescription] [varchar](max) NULL,
	[MealTypeID] [int] NULL,
	[Day] [int] NULL,
	[IsSubstitute] [bit] NULL,
	[OrderID] [int] NULL,
	[DayCount] [int] NULL,
	[DayMealID] [int] NULL,
	[CustomerID] [int] NULL,
	[IsAutoSubstitute] [bit] NULL,
	[Priority] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TempMealMerge]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempMealMerge](
	[MealMergeID] [bigint] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NULL,
	[CustomOrderDayMealID] [int] NULL,
	[MealID] [int] NULL,
	[MealTypeID] [int] NULL,
	[Day] [int] NULL,
	[CreatedDate] [datetime] NULL CONSTRAINT [DF_TempMealMerge_CreatedDate]  DEFAULT (getdate())
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TempMealQuantity]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempMealQuantity](
	[TempMealQuantityID] [int] IDENTITY(1,1) NOT NULL,
	[MealID] [int] NULL,
	[AllocatedQuantity] [int] NULL,
	[ChangedAllocatedQuantity] [int] NULL DEFAULT ((0)),
	[IsChanged] [bit] NULL,
	[CustomerID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[TempMealQuantityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[User]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[User](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[ApplicationID] [int] NOT NULL,
	[Name] [nvarchar](50) NULL,
	[CreationDate] [datetime] NULL,
	[Username] [nvarchar](50) NOT NULL,
	[FirstName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[Email] [nvarchar](100) NOT NULL,
	[Password] [nvarchar](100) NULL,
	[PasswordQuestion] [nvarchar](255) NULL,
	[PasswordAnswer] [nvarchar](255) NULL,
	[IsApproved] [bit] NOT NULL CONSTRAINT [DF_User_IsApproved]  DEFAULT ((1)),
	[LastActivityDate] [datetime] NOT NULL,
	[LastLoginDate] [datetime] NULL,
	[LastPasswordChangedDate] [datetime] NULL,
	[IsOnline] [bit] NULL,
	[IsLockedOut] [bit] NOT NULL,
	[LastLockedOutDate] [datetime] NULL,
	[FailedPasswordAttemptCount] [int] NULL,
	[FailedPasswordAttemptWindowStart] [datetime] NULL,
	[FailedPasswordAnswerAttemptCount] [int] NULL,
	[FailedPasswordAnswerAttemptWindowStart] [datetime] NULL,
	[LastModified] [datetime] NULL,
	[Comment] [nvarchar](255) NULL,
	[IsAnonymous] [bit] NOT NULL CONSTRAINT [DF_User_IsAnonymous]  DEFAULT ((0)),
	[CustomerID] [int] NULL,
	[IsNotified] [bit] NULL CONSTRAINT [DF_User_IsNotified]  DEFAULT ((0)),
	[IsDeleted] [bit] NOT NULL CONSTRAINT [DF_User_IsDeleted]  DEFAULT ((0)),
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_User_1] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserRatings]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserRatings](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NOT NULL,
	[MealID] [int] NOT NULL,
	[Rating] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UsersInRoles]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UsersInRoles](
	[RoleID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
 CONSTRAINT [PK_UsersInRoles_1] PRIMARY KEY CLUSTERED 
(
	[RoleID] ASC,
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[VacationHoldHistory]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[VacationHoldHistory](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NOT NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL DEFAULT (getdate()),
	[HoldId] [varchar](255) NULL,
	[EventId] [varchar](255) NULL,
	[TaskId] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  UserDefinedFunction [dbo].[GetCustomer_ApprovedMealList]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION[dbo].[GetCustomer_ApprovedMealList] (@CustomerID int) 
RETURNS TABLE 
AS
RETURN 
(
SELECT b.MealID,B.MealTypeID FROM (
SELECT     
  Meal.MealID  ,ISNULL(a.Approved  ,1)as Approved,ISNULL(a.IngredientStatus,1)as IngredientStatus,MealTypeID
  FROM    
   ( SELECT     
    CustomerMeal.MealID,     
    CustomerMeal.Approved,
    CustomerMeal.IngredientStatus      
     FROM     
     CustomerMeal WITH(NOLOCK)     
     INNER JOIN     
     Customer WITH(NOLOCK)     
     ON          
     Customer.CustomerID = CustomerMeal.CustomerID    
     
              WHERE     
              Customer.CustomerID=@customerID    
             
   )a     
  RIGHT JOIN    
  Meal WITH(NOLOCK)    
  ON     
  a.MealID=Meal.MealID  and Meal.MealTypeID != 4   
  --WHERE   (a.IngredientStatus=1 OR a.IngredientStatus=3) AND
  --Meal.IsDeleted = 0 AND Meal.Active=1 
  INNER JOIN MealPlanDetails WITH(NOLOCK) ON Meal.MealID = MealPlanDetails.MealID
  WHERE (a.IngredientStatus=1 OR a.IngredientStatus=3) AND Meal.IsDeleted = 0 AND Meal.Active=1 
  --AND cutoffquantity < quantity  
  AND MealPlanDetails.PlanID = (SELECT TOP 1 PlanID FROM CustomerPlan WHERE CustomerID = @customerID AND IsDeleted = 0)   
  )b
)


GO
/****** Object:  UserDefinedFunction [dbo].[GetCustomer_RemovedMealList]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[GetCustomer_RemovedMealList] (@CustomerID int)

RETURNS TABLE 
AS
RETURN 
(
SELECT     
  Meal.MealID ,   
  Meal.MealTypeID
  FROM    
   ( SELECT     
    CustomerMeal.MealID,     
    CustomerMeal.Approved,
    CustomerMeal.IngredientStatus 
   
     FROM     
     CustomerMeal WITH(NOLOCK)     
     INNER JOIN     
     Customer WITH(NOLOCK)     
     ON          
     Customer.CustomerID = CustomerMeal.CustomerID    
     
              WHERE     
              Customer.CustomerID=@customerID     
              AND (IngredientStatus=2 OR IngredientStatus=4 )
   )a     
  INNER JOIN    
  Meal WITH(NOLOCK)    
  ON     
  a.MealID=Meal.MealID AND Meal.MealTypeID != 4 
  --WHERE Meal.IsDeleted = 0 AND Meal.Active=1
  INNER JOIN MealPlanDetails WITH(NOLOCK) ON Meal.MealID = MealPlanDetails.MealID
  WHERE Meal.IsDeleted = 0 AND Meal.Active=1 
  --AND cutoffquantity < quantity  
  AND MealPlanDetails.PlanID = (SELECT TOP 1 PlanID FROM CustomerPlan WHERE CustomerID = @customerID AND IsDeleted = 0)  
)


GO
/****** Object:  UserDefinedFunction [dbo].[GetCustomer_SelectMealIDList]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[GetCustomer_SelectMealIDList] (@CustomerID int)
RETURNS TABLE 
AS
RETURN 
(
  SELECT 
	Meal.MealID,
	Meal.MealTypeID,   
  CASE WHEN (a.IngredientStatus=4 or a.IngredientStatus=2) THEN CONVERT(BIT,0) ELSE CONVERT(BIT,1) END AS Approved        
  FROM        
  (
      SELECT CustomerMeal.Approved,CustomerMeal.IngredientStatus,Meal.MealID        
       FROM        
       CustomerMeal WITH(NOLOCK)        
       inner join Meal WITH(NOLOCK)         
       ON         
       CustomerMeal.MealID=Meal.MealID        
       inner join Customer WITH(NOLOCK)         
       ON         
       CustomerMeal.CustomerID=Customer.CustomerID        
       WHERE         
       Customer.CustomerID=@customerID    
   ) a         
	 right outer join Meal with(nolock)        
	 on         
	 a.MealID=Meal.MealID and Meal.MealTypeID != 4
	 -- where Meal.IsDeleted = 0  and Meal.Active=1
	 INNER JOIN MealPlanDetails WITH(NOLOCK) ON Meal.MealID = MealPlanDetails.MealID
	 WHERE Meal.IsDeleted = 0 AND Meal.Active=1 AND Meal.MealTypeID != 4
	 --AND cutoffquantity < quantity  
	 AND MealPlanDetails.PlanID = (SELECT TOP 1 PlanID FROM CustomerPlan WHERE CustomerID = @customerID AND IsDeleted = 0)
)


GO
/****** Object:  UserDefinedFunction [dbo].[GetCustomerMeals]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetCustomerMeals] (@OrderDayID int)
RETURNS TABLE
AS
RETURN
(
  SELECT 
                MealID = dbo.Meal.MealID,
                SKU = dbo.Meal.SKU,
                MealName = dbo.Meal.Name,
                MealTypename = dbo.MealType.Name,
                MealTyped = dbo.Meal.MealTypeID,
                Quantity=dbo.Meal.Quantity
                FROM dbo.CustomerMeal
                INNER JOIN
                dbo.Meal
                ON
                dbo.CustomerMeal.MealID = dbo.Meal.MealID
                INNER JOIN
                dbo.MealType
                ON
                dbo.MealType.MealTypeID = dbo.Meal.MealTypeID
                WHERE
                dbo.CustomerMeal.CustomerID = (	SELECT TOP 1 CustomerID FROM dbo.[Order] INNER JOIN
												ORDERDay ON OrderDay.OrderID = [Order].OrderID 
                                                WHERE dbo.OrderDay.OrderDayID  = (@OrderDayID)
                                              )  AND 
                                                dbo.CustomerMeal.Approved = 1 AND  (dbo.Meal.Quantity > dbo.Meal.CutoffQuantity) 
                                              )

GO
/****** Object:  UserDefinedFunction [dbo].[GetCustomerPlan]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GetCustomerPlan] (@CustomerID int,@StartDate DATETIME)
RETURNS TABLE

AS
RETURN
(
        SELECT 
				pdm.MealID,
				m.Name AS MealName,
				m.LongDescription AS MealDescription,
				pdm.MealTypeID,
				mt.Name AS MealTypeName,
				m.MyBistroMDActive,
				Day,
				cp.PlanID,
				pw.Week,
				CAST(0 AS BIT) as IsSubstitute,
				pdm.PlanDayMealID AS DayMealID,
				GETDATE() AS CurrentDate,
				pdm.[Priority],
				cm.Approved,
				CASE WHEN m.Quantity > m.QuantityInProcess + m.AllocatedQuantity + (SELECT COALESCE(SUM(ChangedAllocatedQuantity),0) FROM [TempMealQuantity] WHERE MealID = pdm.MealID) AND Quantity > CutoffQuantity  THEN 1 ELSE 0 END AS MealQuantity,
				(SELECT TOP 1 CAST(Rating as INT) As Rating FROM UserRatings WHERE MealID = pdm.MealID AND CustomerID = @CustomerId ORDER BY CreatedDate DESC) AS Rating


   FROM PlanDayMeal pdm 

				INNER JOIN CustomerMeal cm on cm.CustomerID = @CustomerID AND CM.MealID = pdm.MealID  
				INNER JOIN Meal m ON m.MealID = pdm.MealID
				INNER JOIN MealType mt ON mt.MealTypeID = pdm.MealTypeID
				INNER JOIN PlanDay pd ON pd.PlanDayID = pdm.PlanDayID
				INNER JOIN PlanWeek pw ON pw.PlanWeekID = pd.PlanWeekID
				INNER JOIN CustomerPlan cp ON cp.PlanID = pw.PlanID AND cp.Week + 1 = pw.Week


   WHERE cp.CustomerID = @CustomerID AND StartDate = @StartDate AND cp.IsDeleted = 0 AND m.Active = 1 
)

GO
/****** Object:  UserDefinedFunction [dbo].[getIngredientNotInMeal]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[getIngredientNotInMeal] (@MealId int)
RETURNS TABLE
AS
RETURN
(
SELECT     
	Ingredient.IngredientID, Ingredient.Name AS ingredientName,
	dbo.udf_GetCategoryForIngredient(Ingredient.IngredientID,1)as IngredientCategoryName
	FROM         
	IngredientCategory WITH(NOLOCK)
	RIGHT OUTER JOIN
	IngredientIngredientCategory WITH(NOLOCK)
	ON 
	IngredientCategory.IngredientCategoryID = IngredientIngredientCategory.IngredientCategoryID 
	RIGHT OUTER JOIN
	Ingredient WITH(NOLOCK)
	ON 
	IngredientIngredientCategory.IngredientID = Ingredient.IngredientID
	WHERE     
	(Ingredient.IngredientID NOT IN (	SELECT MealIngredient.IngredientID
										FROM MealIngredient WITH(NOLOCK)
										WHERE      (MealID = @mealId))) 
	GROUP BY  Ingredient.IngredientID, Ingredient.Name 
	
)

GO
/****** Object:  UserDefinedFunction [dbo].[getSubstituteMeal]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[getSubstituteMeal] (@MealId int)
RETURNS TABLE
AS
RETURN
(

	SELECT     Meal.MealID, Meal.Active, Meal.SKU, Meal.Name, Meal.MealTypeID, Meal.ShortDescription, Meal.LongDescription, Meal.Calories, Meal.CaloriesFromFat, 
                      Meal.TotalFat, Meal.SaturatedFat, Meal.TransFat, Meal.Cholesterol, Meal.Protein, Meal.Carbohydrate, Meal.DietaryFiber, Meal.Sugars, Meal.Sodium, Meal.AddDate, 
                      Meal.UpdateDate, Meal.Status, Meal.Quantity, Meal.CutoffQuantity, MealType.Name AS MealTypeName
FROM         Meal WITH (NOLOCK) INNER JOIN
                      MealType ON Meal.MealTypeID = MealType.MealTypeID
	WHERE 
	MealID <> @mealId AND Meal.Active=1 AND MEAL.isDeleted=0 --AND
	--MealID NOT IN (Select SubstituteMealID From MealSubstitute WITH(NOLOCK)
	--where MealID=@mealId) 
	
	
)

GO
/****** Object:  View [dbo].[CustomersLoginLast]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[CustomersLoginLast]
AS
SELECT DISTINCT dbo.Customer.First, dbo.Customer.Last, dbo.Customer.Email, dbo.[Plan].Name, dbo.MembershipLogin.Password, dbo.MembershipLogin.LastLoginDate
FROM         dbo.Customer INNER JOIN
                      dbo.CustomerAccess ON dbo.Customer.CustomerID = dbo.CustomerAccess.CustomerID INNER JOIN
                      dbo.MembershipLogin ON dbo.Customer.CustomerID = dbo.MembershipLogin.CustomerID LEFT OUTER JOIN
                      dbo.CustomerPlan ON dbo.Customer.CustomerPlanID = dbo.CustomerPlan.CustomerPlanID AND 
                      dbo.Customer.CustomerID = dbo.CustomerPlan.CustomerID LEFT OUTER JOIN
                      dbo.[Plan] ON dbo.CustomerPlan.PlanID = dbo.[Plan].PlanID

GO
/****** Object:  View [dbo].[PreferenceVsOrder]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[PreferenceVsOrder]
AS
SELECT     TOP (100) PERCENT dbo.[Order].CustomerID, dbo.[Order].OrderID, dbo.OrderDayMeal.OrderDayMealID, dbo.OrderDayMeal.MealID, dbo.OrderDayMeal.IsSubstitute, 
                      dbo.OrderDayMeal.OrderDayID, dbo.OrderDayMeal.MealTypeID
FROM         dbo.[Order] INNER JOIN
                      dbo.OrderDay ON dbo.[Order].OrderID = dbo.OrderDay.OrderID INNER JOIN
                      dbo.OrderDayMeal ON dbo.OrderDay.OrderDayID = dbo.OrderDayMeal.OrderDayID INNER JOIN
                      dbo.CustomerMeal ON dbo.OrderDayMeal.MealID = dbo.CustomerMeal.MealID AND dbo.[Order].CustomerID = dbo.CustomerMeal.CustomerID
WHERE     (dbo.[Order].OrderStatusID <= 3) AND (dbo.CustomerMeal.Approved = 0) AND (dbo.CustomerMeal.IngredientStatus = 2) AND (dbo.CustomerMeal.CustomerStatus = 0) OR
                      (dbo.[Order].OrderStatusID <= 3) AND (dbo.CustomerMeal.Approved = 0) AND (dbo.CustomerMeal.IngredientStatus = 4) AND (dbo.CustomerMeal.CustomerStatus = 1)
ORDER BY dbo.[Order].OrderID

GO
/****** Object:  View [dbo].[vueBulkOrderHistory]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vueBulkOrderHistory]
AS
SELECT     dbo.BulkOrderHistory.BulkOrderID, dbo.BulkOrderHistory.BulkOrderDate, dbo.BulkOrderHistory.CustomerID, dbo.BulkOrderHistory.OrderID, 
                      dbo.BulkOrderHistory.Status, dbo.Customer.First, dbo.Customer.Last, dbo.[Order].BuildDate, dbo.[Order].ShipDate, dbo.[Plan].Name, dbo.[Order].Week
FROM         dbo.BulkOrderHistory INNER JOIN
                      dbo.[Order] ON dbo.BulkOrderHistory.OrderID = dbo.[Order].OrderID LEFT OUTER JOIN
                      dbo.[Plan] ON dbo.[Order].PlanID = dbo.[Plan].PlanID INNER JOIN
                      dbo.Customer ON dbo.BulkOrderHistory.CustomerID = dbo.Customer.CustomerID

GO
/****** Object:  View [dbo].[vueCancelledAndCreatedOrderFrommybistroMD]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vueCancelledAndCreatedOrderFrommybistroMD]
AS
SELECT     dbo.[Order].OrderID, dbo.[Order].BuildDate, dbo.Customer.CustomerID, dbo.Customer.First, dbo.Customer.Last, CASE WHEN UPPER(AgentNote.Subject) 
                      = UPPER('Order Cancelled From mybistroMD') THEN 'Cancelled' ELSE 'Created' END AS OrderStatus, dbo.[Order].Week
FROM         dbo.[Order] WITH (NOLOCK) INNER JOIN
                      dbo.Customer WITH (NOLOCK) ON dbo.[Order].CustomerID = dbo.Customer.CustomerID INNER JOIN
                      dbo.AgentNote WITH (NOLOCK) ON dbo.[Order].OrderID = dbo.AgentNote.OrderID
WHERE     (UPPER(dbo.AgentNote.Subject) = UPPER('Order Cancelled From mybistroMD')) OR
                      (UPPER(dbo.AgentNote.Subject) = UPPER('Order Created From mybistroMD'))

GO
/****** Object:  View [dbo].[vueCustomerList]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vueCustomerList]
AS
SELECT     Customer.CustomerID AS customerID, Customer.First, Customer.Last, C.CustomerAddressID, ISNULL(C.Address1, '') + ',' + ISNULL(C.Address2, '') AS Address1, 
                      ISNULL(Customer.Email, '') AS Email, ISNULL(C.City, '') AS City, ISNULL(C.Name, '') AS StateName, ISNULL(CustomerStatus.Status, '') AS CustomerStatus, 
                      ISNULL(Program.Name, '') AS ProgramName, ISNULL([Plan].Name, '') AS PlanName, ISNULL(Customer.PickListComments, '') AS PickListComments, 
                      ISNULL(Customer.MenuComments, '') AS MenuComments, ISNULL(CONVERT(VARCHAR(10), B.OrderID), 'N/A') AS OrderID, B.OrderStatusID, ISNULL(D .Status, 'N/A') 
                      AS OrderStatus
FROM         Customer WITH (NOLOCK) LEFT OUTER JOIN
                      CustomerPlan WITH (NOLOCK) ON Customer.CustomerID = CustomerPlan.CustomerID AND CustomerPlan.isDeleted = 0 LEFT OUTER JOIN
                      [Plan] WITH (NOLOCK) ON CustomerPlan.PlanID = [Plan].PlanID LEFT OUTER JOIN
                      Program WITH (NOLOCK) ON [Plan].ProgramID = Program.ProgramID LEFT OUTER JOIN
                      CustomerStatus WITH (NOLOCK) ON Customer.CustomerStatusID = CustomerStatus.CustomerStatusID LEFT OUTER JOIN
                          (SELECT     B1.OrderRowNo, B1.CustomerID, B1.OrderID, B1.OrderStatusID
                            FROM          (SELECT     ROW_NUMBER() OVER (PARTITION BY CustomerID
                                                    ORDER BY CustomerID, OrderID DESC) AS OrderRowNo, CustomerID, OrderID, OrderStatusID
                            FROM          [Order] WITH (NOLOCK)) AS B1
WHERE     B1.OrderRowNo = 1) AS B ON Customer.customerID = B.CustomerID LEFT OUTER JOIN
    (SELECT     C1.RowNo, C1.CustomerID, C1.CustomerAddressID, C1.Address1, C1.Address2, C1.City, C1.Name
      FROM          (SELECT     ROW_NUMBER() OVER (PARTITION BY CustomerID
                              ORDER BY CustomerID, CustomerAddressID DESC) AS RowNo, CustomerID, CustomerAddressID, CustomerAddress.Address1, CustomerAddress.Address2, 
                             CustomerAddress.City, dbo.[State].Name
      FROM          CustomerAddress WITH (NOLOCK) LEFT OUTER JOIN
                             dbo.[State] WITH (NOLOCK) ON CustomerAddress.StateID = State.StateID) AS C1
WHERE     C1.RowNo = 1) AS C ON Customer.CustomerID = C.CustomerID LEFT OUTER JOIN
OrderStatus D WITH (NOLOCK) ON B.OrderStatusID = D .OrderStatusID
WHERE     Customer.IsDeleted = 0

GO
/****** Object:  View [dbo].[vueCustomOrderList]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vueCustomOrderList]
AS
SELECT     dbo.Customer.First + ' ' + dbo.Customer.Last AS CustomerName, dbo.CustomOrder.CustomOrderID, dbo.CustomOrder.ShipDate, dbo.Customer.CustomerID, 
                      dbo.CustomOrder.PlanID, dbo.CustomOrder.Week, dbo.CustomOrder.MovedToOrder, dbo.[Plan].Name, ISNULL(dbo.[Order].OrderID, 0) AS OrderID
FROM         dbo.CustomOrder INNER JOIN
                      dbo.Customer ON dbo.CustomOrder.CustomerID = dbo.Customer.CustomerID INNER JOIN
                      dbo.[Plan] ON dbo.CustomOrder.PlanID = dbo.[Plan].PlanID LEFT OUTER JOIN
                      dbo.[Order] ON dbo.Customer.CustomerID = dbo.[Order].CustomerID AND CAST(dbo.CustomOrder.ShipDate AS Date) = CAST(dbo.[Order].ShipDate AS Date) AND 
                      dbo.[Order].OrderStatusID <> 6

GO
/****** Object:  View [dbo].[vueErrorLog]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vueErrorLog]
AS
SELECT     TOP (100) PERCENT ID, ErrorNo, Application, ISNULL([Function], '') AS [Function], ISNULL(ErrorDesc, '') AS ErrorDesc, ISNULL(DetailedDesc, '') AS DetailedDesc, 
                      ISNULL(CreatedDate, '') AS CreatedDate
FROM         dbo.ErrorLog
ORDER BY ID DESC

GO
/****** Object:  View [dbo].[vueExcludedMealsReport]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vueExcludedMealsReport]
AS
 select m.MealID, m.SKU, m.Name
,p.[1] [IngredientApproved]
,p.[2] [IngredientExcluded] 
,p.[3] [CustomerApproved] 
,p.[4] [CustomerExcluded] 
from(
select * from(
select cm.CustomerID,MealID,IngredientStatus
from CustomerMeal cm, Customer c
where cm.CustomerID=c.CustomerID
and c.IsDeleted=0
)p
PIVOT (count(customerid) for IngredientStatus in ([1],[2],[3],[4])) as pvt
)p, Meal m
where p.MealID=m.MealID
and m.Active=1
and m.IsDeleted=0


GO
/****** Object:  View [dbo].[vueGetCustomerMeals]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vueGetCustomerMeals]
AS
SELECT     dbo.Meal.MealID, dbo.Meal.SKU, dbo.Meal.Name, dbo.Meal.MealTypeID, dbo.CustomerMeal.CustomerID, dbo.[Order].OrderID, dbo.Meal.Quantity
FROM         dbo.CustomerMeal INNER JOIN
                      dbo.[Order] ON dbo.CustomerMeal.CustomerID = dbo.[Order].CustomerID INNER JOIN
                      dbo.Meal ON dbo.CustomerMeal.MealID = dbo.Meal.MealID
WHERE     (dbo.Meal.Quantity > dbo.Meal.CutoffQuantity) AND (dbo.CustomerMeal.Approved = 1) AND (dbo.Meal.IsDeleted = 0)


GO
/****** Object:  View [dbo].[vueGetMealListForPlan]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vueGetMealListForPlan]
AS
SELECT     MealID, SKU, Name, Active
FROM         dbo.Meal
WHERE     (Active = 1) AND (IsDeleted = 0)

GO
/****** Object:  View [dbo].[vueGetMealsInMenus]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vueGetMealsInMenus]
AS
SELECT DISTINCT 
                      TOP (100) PERCENT dbo.[Order].PlanID, dbo.[Plan].Name AS PlanName, dbo.OrderDayMeal.MealID, dbo.Meal.SKU, dbo.Meal.Name AS MealName, 
                      dbo.MealType.Name AS MealTypeName, dbo.Meal.MealTypeID, dbo.Meal.Quantity, ISNULL(A.HoldForReview, 0) AS HoldForReview, ISNULL(B.ReadytoPrint, 0) 
                      AS ReadytoPrint
FROM         dbo.[Order] INNER JOIN
                      dbo.OrderDay ON dbo.[Order].OrderID = dbo.OrderDay.OrderID INNER JOIN
                      dbo.OrderDayMeal ON dbo.OrderDay.OrderDayID = dbo.OrderDayMeal.OrderDayID INNER JOIN
                      dbo.Meal ON dbo.OrderDayMeal.MealID = dbo.Meal.MealID INNER JOIN
                      dbo.MealType ON dbo.Meal.MealTypeID = dbo.MealType.MealTypeID INNER JOIN
                      dbo.[Plan] ON dbo.[Order].PlanID = dbo.[Plan].PlanID LEFT OUTER JOIN
                          (SELECT     Order_2.PlanID, OrderDayMeal_2.MealID, COUNT(ISNULL(OrderDayMeal_2.MealID, 0)) AS HoldForReview
                            FROM          dbo.[Order] AS Order_2 INNER JOIN
                                                   dbo.OrderDay AS OrderDay_2 ON Order_2.OrderID = OrderDay_2.OrderID INNER JOIN
                                                   dbo.OrderDayMeal AS OrderDayMeal_2 ON OrderDay_2.OrderDayID = OrderDayMeal_2.OrderDayID
                            WHERE      (Order_2.OrderStatusID = 2)
                            GROUP BY Order_2.PlanID, OrderDayMeal_2.MealID) AS A ON dbo.[Order].PlanID = A.PlanID AND dbo.OrderDayMeal.MealID = A.MealID LEFT OUTER JOIN
                          (SELECT     Order_1.PlanID, OrderDayMeal_1.MealID, COUNT(ISNULL(OrderDayMeal_1.MealID, 0)) AS ReadytoPrint
                            FROM          dbo.[Order] AS Order_1 INNER JOIN
                                                   dbo.OrderDay AS OrderDay_1 ON Order_1.OrderID = OrderDay_1.OrderID INNER JOIN
                                                   dbo.OrderDayMeal AS OrderDayMeal_1 ON OrderDay_1.OrderDayID = OrderDayMeal_1.OrderDayID
                            WHERE      (Order_1.OrderStatusID = 3)
                            GROUP BY Order_1.PlanID, OrderDayMeal_1.MealID) AS B ON dbo.[Order].PlanID = B.PlanID AND dbo.OrderDayMeal.MealID = B.MealID
GROUP BY dbo.[Order].PlanID, dbo.[Plan].Name, dbo.OrderDayMeal.MealID, dbo.Meal.SKU, dbo.Meal.Name, dbo.MealType.Name, dbo.Meal.MealTypeID, dbo.Meal.Quantity, 
                      A.HoldForReview, B.ReadytoPrint
ORDER BY dbo.[Order].PlanID, PlanName, dbo.OrderDayMeal.MealID, dbo.Meal.SKU, MealName, MealTypeName

GO
/****** Object:  View [dbo].[vueIngredientCategoryEditList]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vueIngredientCategoryEditList]
AS
SELECT     IngredientID, Name, ISNULL(dbo.udf_GetCategoryForIngredient(IngredientID, 1), '') AS IngredientCategories
FROM         dbo.Ingredient

GO
/****** Object:  View [dbo].[vueIngredientCategoryList]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vueIngredientCategoryList]
AS
SELECT     IngredientCategoryID, Name, ISNULL(dbo.udf_GetIngredientForCategory(IngredientCategoryID, 1), '') AS IngredientNames, 
                      ISNULL(dbo.udf_GetIngredientForCategory(IngredientCategoryID, 2), '') AS DisplayIngredientNames
FROM         dbo.IngredientCategory WITH (NOLOCK)

GO
/****** Object:  View [dbo].[vueIngredientList]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vueIngredientList]
AS
SELECT     IngredientID, Name, ISNULL(dbo.udf_GetCategoryForIngredient(IngredientID, 1), '') AS IngredientCategories, ISNULL(dbo.udf_GetCategoryForIngredient(IngredientID, 
                      2), '') AS DisplayIngredientCategories
FROM         dbo.Ingredient WITH (NOLOCK)

GO
/****** Object:  View [dbo].[vueIngredientPreferencesReport]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vueIngredientPreferencesReport]
AS
SELECT     dbo.Ingredient.IngredientID, dbo.Ingredient.Name, ISNULL(SUM(a.DoNotInclude + a.OKSmallAMounts), 0) AS TOTAL, ISNULL(SUM(a.DoNotInclude), 0) AS DoNotInclude,
                       ISNULL(SUM(a.OKSmallAMounts), 0) AS OKSmallAMounts
FROM         (SELECT     IngredientID, (CASE WHEN IngredientLevelID = 1 THEN 1 ELSE 0 END) AS DoNotInclude, (CASE WHEN IngredientLevelID = 2 THEN 1 ELSE 0 END) 
                                              AS OKSmallAMounts
                       FROM          dbo.CustomerIngredientExclusion WITH (NOLOCK)) AS a RIGHT OUTER JOIN
                      dbo.Ingredient WITH (NOLOCK) ON a.IngredientID = dbo.Ingredient.IngredientID
GROUP BY dbo.Ingredient.IngredientID, dbo.Ingredient.Name

GO
/****** Object:  View [dbo].[vueIngredientsForCustomer]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vueIngredientsForCustomer]
AS
SELECT     dbo.CustomerIngredientExclusion.CustomerID, dbo.CustomerIngredientExclusion.IngredientID, dbo.CustomerIngredientExclusion.IngredientLevelID, 
                      dbo.Ingredient.Name, ISNULL(dbo.udf_GetCategoryForIngredient(dbo.CustomerIngredientExclusion.IngredientID, 1), '') AS Catagories
FROM         dbo.CustomerIngredientExclusion INNER JOIN
                      dbo.Ingredient ON dbo.CustomerIngredientExclusion.IngredientID = dbo.Ingredient.IngredientID

GO
/****** Object:  View [dbo].[vueIngredientsReport]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vueIngredientsReport]
AS
SELECT     ISNULL(dbo.IngredientCategory.IngredientCategoryID, 0) AS IngredientCategoryID, ISNULL(dbo.IngredientCategory.Name, '') AS CategoryName, 
                      ISNULL(dbo.Ingredient.IngredientID, 0) AS IngredientID, ISNULL(dbo.Ingredient.Name, '') AS Name
FROM         dbo.IngredientCategory WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.IngredientIngredientCategory WITH (NOLOCK) ON 
                      dbo.IngredientCategory.IngredientCategoryID = dbo.IngredientIngredientCategory.IngredientCategoryID RIGHT OUTER JOIN
                      dbo.Ingredient WITH (NOLOCK) ON dbo.IngredientIngredientCategory.IngredientID = dbo.Ingredient.IngredientID

GO
/****** Object:  View [dbo].[vueIPAccess]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vueIPAccess]
AS
SELECT     IPAccessID, IPAddress, ISNULL(AddedDate, '') AS AddedDate, Description
FROM         dbo.IPAccess

GO
/****** Object:  View [dbo].[vueMealAndIngredientPreferenceHistory]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vueMealAndIngredientPreferenceHistory]
AS
SELECT     TOP (100) PERCENT CustomerID, Type, Name, LastAction, Modification
FROM         (SELECT     dbo.CustomerIngredientExclusionHistory.CustomerID, 'Ingredient' AS Type, dbo.Ingredient.Name, dbo.CustomerIngredientExclusionHistory.LastAction, 
                                              CASE WHEN Status = 'Deleted' THEN 'Ingredient Deleted' ELSE CASE WHEN ingredientLevelID = 1 THEN 'Do Not Include' WHEN ingredientLevelID = 2 THEN
                                               'OK in Small Amounts' WHEN ingredientLevelID = 3 THEN 'Customer Likes' WHEN ingredientLevelID = 4 THEN 'Customer Dislikes' END END AS Modification
                       FROM          dbo.CustomerIngredientExclusionHistory WITH (NOLOCK) INNER JOIN
                                              dbo.Ingredient WITH (NOLOCK) ON dbo.CustomerIngredientExclusionHistory.IngredientID = dbo.Ingredient.IngredientID
                       UNION
                       SELECT     dbo.CustomerMealHistory.CustomerID, 'Meal' AS Type, dbo.Meal.Name, dbo.CustomerMealHistory.LastAction, 
                                             CASE WHEN IngredientStatus = 1 THEN 'Ingredient Approved' WHEN IngredientStatus = 2 THEN 'Ingredient Excluded' WHEN IngredientStatus = 3 THEN 'Customer Approved'
                                              WHEN IngredientStatus = 4 THEN 'Customer Excluded' END AS Modification
                       FROM         dbo.CustomerMealHistory WITH (NOLOCK) INNER JOIN
                                             dbo.Meal WITH (NOLOCK) ON dbo.CustomerMealHistory.MealID = dbo.Meal.MealID) AS a
ORDER BY LastAction DESC

GO
/****** Object:  View [dbo].[vueMealIngredientList]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vueMealIngredientList]
AS
SELECT     dbo.MealIngredient.IngredientID, dbo.Ingredient.Name AS IngredientName, ISNULL(dbo.udf_GetCategoryForIngredient(dbo.MealIngredient.IngredientID, 1), '') 
                      AS IngredientCategoryName, dbo.MealIngredient.MealIngredientID, dbo.Meal.MealID
FROM         dbo.Meal INNER JOIN
                      dbo.MealIngredient ON dbo.Meal.MealID = dbo.MealIngredient.MealID INNER JOIN
                      dbo.Ingredient ON dbo.MealIngredient.IngredientID = dbo.Ingredient.IngredientID
WHERE     (dbo.Meal.IsDeleted = 0)

GO
/****** Object:  View [dbo].[vueMealList]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vueMealList]
AS
SELECT     dbo.Meal.MealID, CASE WHEN dbo.Meal.Active = 1 THEN 'Yes' ELSE 'No' END AS ActiveStatus, dbo.Meal.SKU, dbo.Meal.Name, 
                      dbo.MealType.Name AS MealTypeName, ISNULL(A.mCount, 0) AS MealSubstitutesCount, dbo.Meal.Calories, dbo.Meal.CaloriesFromFat, dbo.Meal.TotalFat, 
                      dbo.Meal.SaturatedFat, dbo.Meal.TransFat, dbo.Meal.Cholesterol, dbo.Meal.Protein, dbo.Meal.Carbohydrate, dbo.Meal.DietaryFiber, dbo.Meal.Sugars, 
                      dbo.Meal.Sodium, dbo.Meal.Quantity, dbo.Meal.CutoffQuantity, ISNULL(dbo.udf_GetIngredientForMeal(dbo.Meal.MealID), '') AS IngredientName, 
                      dbo.Meal.QuantityInProcess, dbo.Meal.QuantityShipped, dbo.Meal.AlertLevelQuantity, dbo.Meal.ItemCount
FROM         dbo.Meal INNER JOIN
                      dbo.MealType ON dbo.Meal.MealTypeID = dbo.MealType.MealTypeID LEFT OUTER JOIN
                          (SELECT     MealID, COUNT(*) AS mCount
                            FROM          dbo.MealSubstitute
                            GROUP BY MealID) AS A ON dbo.Meal.MealID = A.MealID
WHERE     (dbo.Meal.IsDeleted = 0)

GO
/****** Object:  View [dbo].[vueMealQuantityReport]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vueMealQuantityReport]
AS
SELECT     dbo.Meal.MealID, dbo.Meal.SKU, dbo.Meal.Name, CASE WHEN Meal.Active = 1 THEN 'Yes' ELSE 'No' END AS Active, dbo.MealType.Name AS MealTypeName, 
                      ISNULL(SUM(a.ShippedQuantity), 0) + ISNULL(SUM(a.QuantityInProcess), 0) AS Quantity, ISNULL(SUM(a.ShippedQuantity), 0) AS ShippedQuantity, 
                      ISNULL(SUM(a.QuantityInProcess), 0) AS QuantityInProcess
FROM         dbo.MealType WITH (NOLOCK) INNER JOIN
                      dbo.Meal ON dbo.MealType.MealTypeID = dbo.Meal.MealTypeID LEFT OUTER JOIN
                          (SELECT     dbo.OrderDayMeal.MealID, (CASE WHEN [Order].OrderStatusID = 5 THEN 1 ELSE 0 END) AS ShippedQuantity, 
                                                   (CASE WHEN [Order].OrderStatusID < 5 THEN 1 ELSE 0 END) AS QuantityInProcess
                            FROM          dbo.[Order] WITH (NOLOCK) INNER JOIN
                                                   dbo.OrderDay ON dbo.[Order].OrderID = dbo.OrderDay.OrderID INNER JOIN
                                                   dbo.OrderDayMeal WITH (NOLOCK) ON dbo.OrderDay.OrderDayID = dbo.OrderDayMeal.OrderDayID) AS a ON dbo.Meal.MealID = a.MealID
WHERE     (dbo.Meal.IsDeleted = 0)
GROUP BY dbo.Meal.MealID, dbo.Meal.SKU, dbo.Meal.Name, dbo.Meal.Active, dbo.MealType.Name

GO
/****** Object:  View [dbo].[vueMealsByDate]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vueMealsByDate]
AS
SELECT     TOP (100) PERCENT dbo.Meal.MealID, dbo.Meal.SKU, dbo.Meal.Name, ISNULL(a.Quantity, 0) AS Quantity, dbo.MealType.Name AS MealTypeName
FROM         (SELECT     dbo.OrderDayMeal.MealID, ISNULL(COUNT(dbo.OrderDayMeal.OrderDayMealID), 0) AS Quantity
                       FROM          dbo.OrderDayMeal WITH (NOLOCK) INNER JOIN
                                              dbo.OrderDay WITH (NOLOCK) ON dbo.OrderDayMeal.OrderDayID = dbo.OrderDay.OrderDayID INNER JOIN
                                              dbo.[Order] WITH (NOLOCK) ON dbo.OrderDay.OrderID = dbo.[Order].OrderID
                       WHERE      (dbo.[Order].OrderStatusID <= 5)
                       GROUP BY dbo.OrderDayMeal.MealID) AS a INNER JOIN
                      dbo.Meal WITH (NOLOCK) ON a.MealID = dbo.Meal.MealID INNER JOIN
                      dbo.MealType WITH (NOLOCK) ON dbo.Meal.MealTypeID = dbo.MealType.MealTypeID
WHERE     (dbo.Meal.IsDeleted = 0)

GO
/****** Object:  View [dbo].[vueMealSubstituteList]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vueMealSubstituteList]
AS
SELECT     dbo.MealSubstitute.SubstituteMealID, dbo.MealSubstitute.MealSubstituteID, dbo.Meal.Active, dbo.Meal.SKU, dbo.Meal.Name, dbo.Meal.MealTypeID, 
                      dbo.Meal.ShortDescription, dbo.Meal.LongDescription, dbo.Meal.Calories, dbo.Meal.CaloriesFromFat, dbo.Meal.TotalFat, dbo.Meal.SaturatedFat, dbo.Meal.TransFat, 
                      dbo.Meal.Cholesterol, dbo.Meal.Protein, dbo.Meal.Carbohydrate, dbo.Meal.DietaryFiber, dbo.Meal.Sugars, dbo.Meal.Sodium, dbo.Meal.AddDate, 
                      dbo.Meal.UpdateDate, dbo.Meal.Status, dbo.Meal.Quantity, dbo.Meal.CutoffQuantity, dbo.Meal.QuantityInProcess, dbo.Meal.QuantityShipped, 
                      dbo.Meal.AlertLevelQuantity, dbo.Meal.ItemCount, dbo.MealSubstitute.MealID
FROM         dbo.MealSubstitute INNER JOIN
                      dbo.Meal ON dbo.MealSubstitute.SubstituteMealID = dbo.Meal.MealID
WHERE     (dbo.Meal.IsDeleted = 0)

GO
/****** Object:  View [dbo].[vueOrderForCustomer]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vueOrderForCustomer]
AS
SELECT     OrderID, ISNULL(BuildDate, '') AS BuildDate, ISNULL(PrintDate, '') AS PrintDate, Week, OrderStatusID, ISNULL(ShipDate, '') AS ShipDate, CustomerID
FROM         dbo.[Order]

GO
/****** Object:  View [dbo].[vueOrderList]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vueOrderList]
AS
SELECT     dbo.[Order].OrderID, CASE WHEN [order].OrderStatusID = 2 AND 
                      Customer.AlwaysReviewHold = 1 THEN OrderStatus.Status + ' (Always)' ELSE OrderStatus.Status END AS OrderStatus, dbo.[Plan].Name AS PlanName, 
                      dbo.Program.Name AS ProgramName, dbo.Customer.CustomerID, dbo.[Order].Week AS PlanWeek, dbo.CustomerStatus.Status AS CustomerStatus, 
                      dbo.Customer.First + ' ' + dbo.Customer.Last AS CustomerName, dbo.Customer.First AS CustomerFirstName, dbo.[Order].PlanID, 
                      dbo.Customer.Last AS CustomerLastName, dbo.[Order].BuildDate, dbo.[Order].ShipDate
FROM         dbo.[Order] WITH (NOLOCK) INNER JOIN
                      dbo.OrderStatus WITH (NOLOCK) ON dbo.[Order].OrderStatusID = dbo.OrderStatus.OrderStatusID INNER JOIN
                      dbo.[Plan] WITH (NOLOCK) ON dbo.[Order].PlanID = dbo.[Plan].PlanID INNER JOIN
                      dbo.Customer WITH (NOLOCK) ON dbo.[Order].CustomerID = dbo.Customer.CustomerID INNER JOIN
                      dbo.CustomerStatus WITH (NOLOCK) ON dbo.Customer.CustomerStatusID = dbo.CustomerStatus.CustomerStatusID INNER JOIN
                      dbo.Program WITH (NOLOCK) ON dbo.[Plan].ProgramID = dbo.Program.ProgramID

GO
/****** Object:  View [dbo].[vueOrderRegenerationReport]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vueOrderRegenerationReport]
AS
SELECT     TOP (100) PERCENT dbo.OrderRegeneration.OrderRegenerationID, dbo.OrderRegeneration.OrderID, dbo.OrderRegeneration.MyBistroRemarks, 
                      dbo.OrderRegeneration.OrdercreationRemarks, dbo.OrderRegeneration.UpdatedDate, dbo.[Order].BuildDate, dbo.[Order].ShippedWeight, dbo.[Order].Week, 
                      dbo.[Order].PlanID, dbo.Customer.CustomerID, dbo.Customer.First, dbo.Customer.Last, dbo.Customer.Email, dbo.[Plan].Name AS PlanName
FROM         dbo.OrderRegeneration INNER JOIN
                      dbo.[Order] ON dbo.OrderRegeneration.OrderID = dbo.[Order].OrderID INNER JOIN
                      dbo.Customer ON dbo.[Order].CustomerID = dbo.Customer.CustomerID INNER JOIN
                      dbo.[Plan] ON dbo.[Order].PlanID = dbo.[Plan].PlanID
ORDER BY dbo.OrderRegeneration.UpdatedDate DESC



GO
/****** Object:  View [dbo].[vuePlanForCustomer]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vuePlanForCustomer]
AS
SELECT     ISNULL(dbo.CustomerPlan.StartDate, '') AS StartDate, ISNULL(dbo.CustomerPlan.EndDate, '') AS EndDate, dbo.CustomerPlan.CustomerPlanID, 
                      dbo.CustomerPlan.Week, dbo.[Plan].PlanID, dbo.[Plan].Name, dbo.[Plan].DisplayName, dbo.[Plan].Description, dbo.[Plan].IsCustomPlan, dbo.[Plan].ProgramID, 
                      dbo.[Plan].Active, dbo.[Plan].Price, dbo.[Plan].CostPerDay, dbo.[Plan].Shipping, dbo.[Plan].DoNotSubstitute, dbo.[Plan].IsDeleted, dbo.[Plan].IsSnack, 
                      dbo.CustomerPlan.CustomerID
FROM         dbo.CustomerPlan INNER JOIN
                      dbo.[Plan] ON dbo.CustomerPlan.PlanID = dbo.[Plan].PlanID
WHERE     (dbo.[Plan].IsDeleted = 0) AND (dbo.[Plan].Active = 1)

GO
/****** Object:  View [dbo].[vuePlanList]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vuePlanList]
AS
SELECT     dbo.[Plan].PlanID, CASE WHEN dbo.[Plan].Active = 1 THEN 'Yes' ELSE 'No' END AS Active, dbo.[Plan].Name, ISNULL(dbo.[Plan].DisplayName, '') AS DisplayName, 
                      ISNULL(dbo.[Plan].Description, '') AS Description, CASE WHEN dbo.[Plan].IsCustomPlan = 1 THEN 'Yes' ELSE 'No' END AS IsCustomPlan, 
                      dbo.Program.Name AS Program
FROM         dbo.[Plan] INNER JOIN
                      dbo.Program ON dbo.[Plan].ProgramID = dbo.Program.ProgramID
WHERE     (dbo.[Plan].IsDeleted = 0)

GO
/****** Object:  View [dbo].[vueProgramList]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vueProgramList]
AS
SELECT     ProgramID, Name, CASE WHEN Active = 1 THEN 'Yes' ELSE 'No' END AS Active, IsDeleted
FROM         dbo.Program
WHERE     (IsDeleted = 0)

GO
/****** Object:  View [dbo].[vueSubstituteReport]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vueSubstituteReport]
AS
SELECT     TOP (100) PERCENT b.MealID, b.SKU, b.Name, b.Active, b.MealTypeName, b.Calories, b.Quantity, b.ShippedQuantity, b.QuantityInProcess, ISNULL(C.Childs, 0) 
                      AS Expr1, ISNULL(d.Parents, 0) AS Parents
FROM         (SELECT     dbo.Meal.MealID, dbo.Meal.SKU, dbo.Meal.Name, CASE WHEN Meal.Active = 1 THEN 'Yes' ELSE 'No' END AS Active, 
                                              dbo.MealType.Name AS MealTypeName, dbo.Meal.Calories, ISNULL(SUM(a.ShippedQuantity), 0) + ISNULL(SUM(a.QuantityInProcess), 0) AS Quantity, 
                                              ISNULL(SUM(a.ShippedQuantity), 0) AS ShippedQuantity, ISNULL(SUM(a.QuantityInProcess), 0) AS QuantityInProcess
                       FROM          dbo.MealType WITH (NOLOCK) INNER JOIN
                                              dbo.Meal ON dbo.MealType.MealTypeID = dbo.Meal.MealTypeID LEFT OUTER JOIN
                                                  (SELECT     dbo.OrderDayMeal.MealID, (CASE WHEN [Order].OrderStatusID = 5 THEN 1 ELSE 0 END) AS ShippedQuantity, 
                                                                           (CASE WHEN [Order].OrderStatusID < 5 THEN 1 ELSE 0 END) AS QuantityInProcess
                                                    FROM          dbo.[Order] WITH (NOLOCK) INNER JOIN
                                                                           dbo.OrderDay WITH (NOLOCK) ON dbo.[Order].OrderID = dbo.OrderDay.OrderID INNER JOIN
                                                                           dbo.OrderDayMeal WITH (NOLOCK) ON dbo.OrderDay.OrderDayID = dbo.OrderDayMeal.OrderDayID) AS a ON 
                                              dbo.Meal.MealID = a.MealID
                       WHERE      (dbo.Meal.IsDeleted = 0)
                       GROUP BY dbo.Meal.MealID, dbo.Meal.SKU, dbo.Meal.Name, dbo.Meal.Active, dbo.MealType.Name, dbo.Meal.Calories) AS b LEFT OUTER JOIN
                          (SELECT     MealID, COUNT(*) AS Childs
                            FROM          dbo.MealSubstitute WITH (NOLOCK)
                            GROUP BY MealID) AS C ON b.MealID = C.MealID LEFT OUTER JOIN
                          (SELECT     SubstituteMealID, COUNT(*) AS Parents
                            FROM          dbo.MealSubstitute AS MealSubstitute_1 WITH (NOLOCK)
                            GROUP BY SubstituteMealID) AS d ON b.MealID = d.SubstituteMealID
ORDER BY b.MealID

GO
/****** Object:  View [dbo].[vueUserList]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vueUserList]
AS
SELECT     UserID, ApplicationID, ISNULL(Name, '') AS Expr1, CreationDate, Username, FirstName, LastName, Email, Password, PasswordQuestion, PasswordAnswer, 
                      IsApproved, LastActivityDate, LastLoginDate, LastPasswordChangedDate, IsOnline, IsLockedOut, LastLockedOutDate, FailedPasswordAttemptCount, 
                      FailedPasswordAttemptWindowStart, FailedPasswordAnswerAttemptCount, FailedPasswordAnswerAttemptWindowStart, LastModified, Comment, IsAnonymous, 
                      CustomerID
FROM         dbo.[User]
WHERE     (IsDeleted = 0)

GO
/****** Object:  View [dbo].[vuSalesOrder]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vuSalesOrder]
AS
SELECT     dbo.[Order].ShipDate, AN.Notes, dbo.OrderDayMeal.OrderDayMealID, AN.AgentNoteID, dbo.OrderDay.OrderDayID, dbo.[Order].OrderID, Me.MealID AS MealId, 
                      Me.Name AS MealName, Me.SKU AS Meal
FROM         dbo.OrderDay INNER JOIN
                      dbo.[Order] ON dbo.OrderDay.OrderID = dbo.[Order].OrderID INNER JOIN
                      dbo.OrderDayMeal ON dbo.OrderDay.OrderDayID = dbo.OrderDayMeal.OrderDayID INNER JOIN
                      dbo.Meal AS Me ON dbo.OrderDayMeal.MealID = Me.MealID LEFT OUTER JOIN
                      dbo.AgentNote AS AN ON Me.MealID = AN.MealID AND dbo.[Order].OrderID = AN.OrderID

GO
/****** Object:  View [dbo].[vw_CustomerOrders]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_CustomerOrders] as
select First+' '+Last customer,builddate, orderid,  Status, shipdate, Name planname, [week] planweek
from [order] ord, [customer] cus, [orderstatus] ordsts, [Plan] pln
where ord.customerid=cus.customerid
and ord.orderstatusid=ordsts.orderstatusid
and ord.planid=pln.planid


GO
/****** Object:  View [dbo].[vw_OrdersHoldForReview]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_OrdersHoldForReview] as
select cus.CustomerID, cus.First, cus.Email, cus.Active 'Customer Active', cus.IsDeleted 'Customer Deleted'
		, pln.planid, pln.Name 'Plan Name', pln.Active 'Plan Active', pln.IsDeleted 'Plan Deleted'
		, ord.orderid, ord.BuildDate, ord.ShipDate, ordsts.Status 'Order Status'
		, plnwk.Week 'Plan Week', plndy.Day 'Plan Day' 
		, ml.MealID, ml.Name 'Meal Name', ml.Quantity 'Meal Quantity' ,ml.AlertLevelQuantity 'Meal Alert Level Quantity', ml.Status 'Meal Status' ,ml.Active 'Meal Active', ml.IsDeleted 'Meal Deleted'
		, mlsubml.Name 'Sub Meal Name', mlsubml.Quantity 'Sub Meal Quantity', mlsubml.AlertLevelQuantity 'Sub Meal Alert Level Quantity' , mlsubml.Status 'Sub Meal Status', mlsubml.Active 'Sub Meal Active', mlsubml.IsDeleted 'Sub Meal Deleted'
from [Customer] cus 
join [Order] ord 
	on cus.CustomerID=ord.CustomerID
join [OrderStatus] ordsts
	on ord.OrderStatusID=ordsts.OrderStatusID
join [Plan] pln 
	on ord.PlanID=pln.PlanID
join [PlanWeek] plnwk
	on pln.PlanID=plnwk.PlanID
join [PlanDay] plndy
	on plnwk.PlanWeekID=plndy.PlanWeekID
join [PlanDayMeal] plndyml
	on plndy.PlanDayID=plndyml.PlanDayID
join [Meal] ml
	on plndyml.MealID=ml.MealID
left outer join [MealSubstitute] mlsub
	on ml.MealID=mlsub.MealID 
	and mlsub.SubstitutePlanID=pln.PlanID
left outer join [Meal] mlsubml
	on mlsub.SubstituteMealID=mlsubml.MealID
where
	ordsts.Status='Hold for Review'
	and ord.orderid=109523


--,[PlanWeek],[PlanDay],[PlanDayMeal],[Meal]
GO
/****** Object:  View [dbo].[VwCustomerAccessReport]    Script Date: 8/20/2016 10:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VwCustomerAccessReport]
AS
SELECT     dbo.Customer.First, dbo.Customer.Last, dbo.Customer.Email, dbo.[Plan].Name, dbo.CustomerAccess.LoginDate, dbo.MembershipLogin.Password
FROM         dbo.Customer INNER JOIN
                      dbo.CustomerAccess ON dbo.Customer.CustomerID = dbo.CustomerAccess.CustomerID INNER JOIN
                      dbo.MembershipLogin ON dbo.Customer.CustomerID = dbo.MembershipLogin.CustomerID LEFT OUTER JOIN
                      dbo.CustomerPlan ON dbo.Customer.CustomerPlanID = dbo.CustomerPlan.CustomerPlanID AND 
                      dbo.Customer.CustomerID = dbo.CustomerPlan.CustomerID LEFT OUTER JOIN
                      dbo.[Plan] ON dbo.CustomerPlan.PlanID = dbo.[Plan].PlanID

GO
ALTER TABLE [dbo].[ControlChangePassword] ADD  CONSTRAINT [DF_ControlChangePassword_Title]  DEFAULT ('Change Password') FOR [Title]
GO
ALTER TABLE [dbo].[ControlLogin] ADD  CONSTRAINT [DF_ControlLogin_Title]  DEFAULT ('Login') FOR [Title]
GO
ALTER TABLE [dbo].[ControlLoginName] ADD  CONSTRAINT [DF_ControlLoginName_WelcomeText]  DEFAULT ('Welcome') FOR [WelcomeText]
GO
ALTER TABLE [dbo].[ControlLoginStatus] ADD  CONSTRAINT [DF_ControlLoginStatus_LoginText]  DEFAULT ('Login') FOR [LoginText]
GO
ALTER TABLE [dbo].[ControlLoginStatus] ADD  CONSTRAINT [DF_ControlLoginStatus_LogoutText]  DEFAULT ('Logout') FOR [LogoutText]
GO
ALTER TABLE [dbo].[ControlMarkup] ADD  CONSTRAINT [DF_ControlMarkup_Markup]  DEFAULT ('') FOR [Markup]
GO
ALTER TABLE [dbo].[ControlProfile] ADD  CONSTRAINT [DF_ControlProfile_Title]  DEFAULT ('Profile') FOR [Title]
GO
ALTER TABLE [dbo].[ControlRegister] ADD  CONSTRAINT [DF_ControlRegister_UsernameText]  DEFAULT ('Username') FOR [UsernameText]
GO
ALTER TABLE [dbo].[ControlRegister] ADD  CONSTRAINT [DF_ControlRegister_PasswordText]  DEFAULT ('Password') FOR [PasswordText]
GO
ALTER TABLE [dbo].[CustomerPayment] ADD  CONSTRAINT [DF_CustomerPayment_CardNumber]  DEFAULT ('') FOR [CardNumber]
GO
ALTER TABLE [dbo].[CustomerPayment] ADD  CONSTRAINT [DF_CustomerPayment_ExpMonth]  DEFAULT ((1)) FOR [ExpMonth]
GO
ALTER TABLE [dbo].[CustomerPayment] ADD  CONSTRAINT [DF_CustomerPayment_ExpYear]  DEFAULT ((11)) FOR [ExpYear]
GO
ALTER TABLE [dbo].[CustomerPayment] ADD  CONSTRAINT [DF_CustomerPayment_LastFour]  DEFAULT ('') FOR [LastFour]
GO
ALTER TABLE [dbo].[CustomerPayment] ADD  CONSTRAINT [DF_CustomerPayment_NameOnCard]  DEFAULT ('') FOR [NameOnCard]
GO
ALTER TABLE [dbo].[CustomerPayment] ADD  CONSTRAINT [DF_CustomerPayment_CardType]  DEFAULT ((1)) FOR [CardType]
GO
ALTER TABLE [dbo].[CustomerPayment] ADD  CONSTRAINT [DF_CustomerPayment_SecurityCode]  DEFAULT ('') FOR [SecurityCode]
GO
ALTER TABLE [dbo].[CustomerPayment] ADD  CONSTRAINT [DF_CustomerPayment_IsActive]  DEFAULT ((1)) FOR [DefaultPayment]
GO
ALTER TABLE [dbo].[InventoryItem] ADD  CONSTRAINT [DF_InventoryItem_Quantity]  DEFAULT ((0)) FOR [Quantity]
GO
ALTER TABLE [dbo].[InventoryItem] ADD  CONSTRAINT [DF_InventoryItem_CostPerUnit]  DEFAULT ((0)) FOR [CostPerUnit]
GO
ALTER TABLE [dbo].[InventoryItem] ADD  CONSTRAINT [DF_InventoryItem_CostPerCase]  DEFAULT ((0)) FOR [CostPerCase]
GO
ALTER TABLE [dbo].[InventoryItem] ADD  CONSTRAINT [DF_InventoryItem_UnitsPerCase]  DEFAULT ((0)) FOR [UnitsPerCase]
GO
ALTER TABLE [dbo].[InventoryItem] ADD  CONSTRAINT [DF_InventoryItem_OrderLeadDays]  DEFAULT ((0)) FOR [OrderLeadDays]
GO
ALTER TABLE [dbo].[InventoryItem] ADD  CONSTRAINT [DF_InventoryItem_QuantityInProcess]  DEFAULT ((0)) FOR [QuantityInProcess]
GO
ALTER TABLE [dbo].[InventoryItem] ADD  CONSTRAINT [DF_InventoryItem_QuantityShipped]  DEFAULT ((0)) FOR [QuantityShipped]
GO
ALTER TABLE [dbo].[InventoryItem] ADD  CONSTRAINT [DF_InventoryItem_QuantityLost]  DEFAULT ((0)) FOR [QuantityLost]
GO
ALTER TABLE [dbo].[InventoryItem] ADD  CONSTRAINT [DF_InventoryItem_LocatorBin]  DEFAULT ((1)) FOR [LocatorBin]
GO
ALTER TABLE [dbo].[InventoryItem] ADD  CONSTRAINT [DF_InventoryItem_LocatorLevel]  DEFAULT ('A') FOR [LocatorLevel]
GO
ALTER TABLE [dbo].[InventoryItem] ADD  CONSTRAINT [DF_InventoryItem_ItemType]  DEFAULT ((1)) FOR [ItemType]
GO
ALTER TABLE [dbo].[InventoryItemUsage] ADD  CONSTRAINT [DF_MealUsage_Count]  DEFAULT ((0)) FOR [Quantity]
GO
ALTER TABLE [dbo].[OrderPayment] ADD  CONSTRAINT [DF_OrderPayment_CardNumber]  DEFAULT ('') FOR [CardNumber]
GO
ALTER TABLE [dbo].[OrderPayment] ADD  CONSTRAINT [DF_OrderPayment_ExpMonth]  DEFAULT ((1)) FOR [ExpMonth]
GO
ALTER TABLE [dbo].[OrderPayment] ADD  CONSTRAINT [DF_OrderPayment_ExpYear]  DEFAULT ((11)) FOR [ExpYear]
GO
ALTER TABLE [dbo].[OrderPayment] ADD  CONSTRAINT [DF_OrderPayment_LastFour]  DEFAULT ('') FOR [LastFour]
GO
ALTER TABLE [dbo].[OrderPayment] ADD  CONSTRAINT [DF_OrderPayment_NameOnCard]  DEFAULT ('') FOR [NameOnCard]
GO
ALTER TABLE [dbo].[OrderPayment] ADD  CONSTRAINT [DF_OrderPayment_CardType]  DEFAULT ((1)) FOR [CardType]
GO
ALTER TABLE [dbo].[OrderPayment] ADD  CONSTRAINT [DF_OrderPayment_SecurityCode]  DEFAULT ('') FOR [SecurityCode]
GO
ALTER TABLE [dbo].[PageAlias] ADD  CONSTRAINT [DF_Table_1_Permanent]  DEFAULT ((0)) FOR [PermanentRedirect]
GO
ALTER TABLE [dbo].[PageControl] ADD  CONSTRAINT [DF_PageControl_PageID]  DEFAULT ((0)) FOR [PageID]
GO
ALTER TABLE [dbo].[PageControl] ADD  CONSTRAINT [DF_PageControl_SiteID]  DEFAULT ((1)) FOR [SiteID]
GO
ALTER TABLE [dbo].[PageControl] ADD  CONSTRAINT [DF_PageControl_PageContainerID]  DEFAULT ((1)) FOR [PageContainerID]
GO
ALTER TABLE [dbo].[PageControl] ADD  CONSTRAINT [DF_PageControl_ControlID]  DEFAULT ((0)) FOR [ControlID]
GO
ALTER TABLE [dbo].[PageControl] ADD  CONSTRAINT [DF_PageControl_ControlOptionID]  DEFAULT ((0)) FOR [ControlOptionID]
GO
ALTER TABLE [dbo].[PageControl] ADD  CONSTRAINT [DF_PageControl_ControlOrder]  DEFAULT ((0)) FOR [ControlOrder]
GO
ALTER TABLE [dbo].[PageControl] ADD  CONSTRAINT [DF_PageControl_ControlNickName]  DEFAULT ('') FOR [ControlNickname]
GO
ALTER TABLE [dbo].[PageControl] ADD  CONSTRAINT [DF_PageControl_ControlInheritID]  DEFAULT ((0)) FOR [ControlInheritID]
GO
ALTER TABLE [dbo].[Promo] ADD  CONSTRAINT [DF_Promo_PomoCode]  DEFAULT ('') FOR [PomoCode]
GO
ALTER TABLE [dbo].[Promo] ADD  CONSTRAINT [DF_Promo_Description]  DEFAULT ('') FOR [Description]
GO
ALTER TABLE [dbo].[Promo] ADD  CONSTRAINT [DF_Promo_DollarDiscount]  DEFAULT ((0)) FOR [DollarDiscount]
GO
ALTER TABLE [dbo].[Promo] ADD  CONSTRAINT [DF_Promo_PercentDiscount]  DEFAULT ((0)) FOR [PercentDiscount]
GO
ALTER TABLE [dbo].[Promo] ADD  CONSTRAINT [DF_Promo_AppliesToPrice]  DEFAULT ((0)) FOR [AppliesToPrice]
GO
ALTER TABLE [dbo].[Promo] ADD  CONSTRAINT [DF_Promo_AppliesToShipping]  DEFAULT ((0)) FOR [AppliesToShipping]
GO
ALTER TABLE [dbo].[Promo] ADD  CONSTRAINT [DF_Promo_DollarLimit]  DEFAULT ((100)) FOR [DollarLimit]
GO
ALTER TABLE [dbo].[Promo] ADD  CONSTRAINT [DF_Promo_OrderLimit]  DEFAULT ((1)) FOR [OrderLimit]
GO
ALTER TABLE [dbo].[Promo] ADD  CONSTRAINT [DF_Promo_NewCustomerOnly]  DEFAULT ((1)) FOR [NewCustomerOnly]
GO
ALTER TABLE [dbo].[AgentNote]  WITH CHECK ADD  CONSTRAINT [FK_AgentNote_Customer] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customer] ([CustomerID])
GO
ALTER TABLE [dbo].[AgentNote] CHECK CONSTRAINT [FK_AgentNote_Customer]
GO
ALTER TABLE [dbo].[AgentNote]  WITH CHECK ADD  CONSTRAINT [FK_AgentNote_InventoryItem] FOREIGN KEY([InventoryItemID])
REFERENCES [dbo].[InventoryItem] ([InventoryItemID])
GO
ALTER TABLE [dbo].[AgentNote] CHECK CONSTRAINT [FK_AgentNote_InventoryItem]
GO
ALTER TABLE [dbo].[AgentNote]  WITH CHECK ADD  CONSTRAINT [FK_AgentNote_Meal] FOREIGN KEY([MealID])
REFERENCES [dbo].[Meal] ([MealID])
GO
ALTER TABLE [dbo].[AgentNote] CHECK CONSTRAINT [FK_AgentNote_Meal]
GO
ALTER TABLE [dbo].[AgentNote]  WITH CHECK ADD  CONSTRAINT [FK_AgentNote_Order] FOREIGN KEY([OrderID])
REFERENCES [dbo].[Order] ([OrderID])
GO
ALTER TABLE [dbo].[AgentNote] CHECK CONSTRAINT [FK_AgentNote_Order]
GO
ALTER TABLE [dbo].[AgentNote]  WITH CHECK ADD  CONSTRAINT [FK_AgentNote_Plan] FOREIGN KEY([PlanID])
REFERENCES [dbo].[Plan] ([PlanID])
GO
ALTER TABLE [dbo].[AgentNote] CHECK CONSTRAINT [FK_AgentNote_Plan]
GO
ALTER TABLE [dbo].[AgentNote]  WITH CHECK ADD  CONSTRAINT [FK_AgentNote_PurchaseOrder] FOREIGN KEY([PurchaseOrderID])
REFERENCES [dbo].[PurchaseOrder] ([PurchaseOrderID])
GO
ALTER TABLE [dbo].[AgentNote] CHECK CONSTRAINT [FK_AgentNote_PurchaseOrder]
GO
ALTER TABLE [dbo].[AgentNote]  WITH CHECK ADD  CONSTRAINT [FK_AgentNote_User] FOREIGN KEY([AgentID])
REFERENCES [dbo].[User] ([UserID])
GO
ALTER TABLE [dbo].[AgentNote] CHECK CONSTRAINT [FK_AgentNote_User]
GO
ALTER TABLE [dbo].[Build]  WITH CHECK ADD  CONSTRAINT [FK_Build_Plan] FOREIGN KEY([PlanID])
REFERENCES [dbo].[Plan] ([PlanID])
GO
ALTER TABLE [dbo].[Build] CHECK CONSTRAINT [FK_Build_Plan]
GO
ALTER TABLE [dbo].[Build]  WITH CHECK ADD  CONSTRAINT [FK_Build_Program] FOREIGN KEY([ProgramID])
REFERENCES [dbo].[CustomerStatus] ([CustomerStatusID])
GO
ALTER TABLE [dbo].[Build] CHECK CONSTRAINT [FK_Build_Program]
GO
ALTER TABLE [dbo].[Build]  WITH NOCHECK ADD  CONSTRAINT [FK_Build_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[User] ([UserID])
GO
ALTER TABLE [dbo].[Build] CHECK CONSTRAINT [FK_Build_User]
GO
ALTER TABLE [dbo].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_Carrier] FOREIGN KEY([CarrierID])
REFERENCES [dbo].[Carrier] ([CarrierID])
GO
ALTER TABLE [dbo].[Customer] CHECK CONSTRAINT [FK_Customer_Carrier]
GO
ALTER TABLE [dbo].[Customer]  WITH NOCHECK ADD  CONSTRAINT [FK_Customer_CustomerAddress] FOREIGN KEY([BillingAddressID])
REFERENCES [dbo].[CustomerAddress] ([CustomerAddressID])
GO
ALTER TABLE [dbo].[Customer] CHECK CONSTRAINT [FK_Customer_CustomerAddress]
GO
ALTER TABLE [dbo].[Customer]  WITH NOCHECK ADD  CONSTRAINT [FK_Customer_CustomerAddress1] FOREIGN KEY([ShippingAddressID])
REFERENCES [dbo].[CustomerAddress] ([CustomerAddressID])
GO
ALTER TABLE [dbo].[Customer] CHECK CONSTRAINT [FK_Customer_CustomerAddress1]
GO
ALTER TABLE [dbo].[Customer]  WITH NOCHECK ADD  CONSTRAINT [FK_Customer_CustomerPlan] FOREIGN KEY([CustomerPlanID])
REFERENCES [dbo].[CustomerPlan] ([CustomerPlanID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Customer] NOCHECK CONSTRAINT [FK_Customer_CustomerPlan]
GO
ALTER TABLE [dbo].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_CustomerStatus] FOREIGN KEY([CustomerStatusID])
REFERENCES [dbo].[CustomerStatus] ([CustomerStatusID])
GO
ALTER TABLE [dbo].[Customer] CHECK CONSTRAINT [FK_Customer_CustomerStatus]
GO
ALTER TABLE [dbo].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_CustomerType] FOREIGN KEY([CustomerTypeId])
REFERENCES [dbo].[CustomerType] ([CustomerTypeId])
GO
ALTER TABLE [dbo].[Customer] CHECK CONSTRAINT [FK_Customer_CustomerType]
GO
ALTER TABLE [dbo].[CustomerAddress]  WITH NOCHECK ADD  CONSTRAINT [FK_CustomerAddress_Customer] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customer] ([CustomerID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CustomerAddress] CHECK CONSTRAINT [FK_CustomerAddress_Customer]
GO
ALTER TABLE [dbo].[CustomerAddress]  WITH CHECK ADD  CONSTRAINT [FK_CustomerAddress_State] FOREIGN KEY([StateID])
REFERENCES [dbo].[State] ([StateID])
GO
ALTER TABLE [dbo].[CustomerAddress] CHECK CONSTRAINT [FK_CustomerAddress_State]
GO
ALTER TABLE [dbo].[CustomerIngredientCategoryExclusion]  WITH NOCHECK ADD  CONSTRAINT [FK_CustomerIngredientCategoryExclusion_Customer] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customer] ([CustomerID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CustomerIngredientCategoryExclusion] CHECK CONSTRAINT [FK_CustomerIngredientCategoryExclusion_Customer]
GO
ALTER TABLE [dbo].[CustomerIngredientCategoryExclusion]  WITH NOCHECK ADD  CONSTRAINT [FK_CustomerIngredientCategoryExclusion_IngredientCategory] FOREIGN KEY([IngredientCategoryID])
REFERENCES [dbo].[IngredientCategory] ([IngredientCategoryID])
GO
ALTER TABLE [dbo].[CustomerIngredientCategoryExclusion] CHECK CONSTRAINT [FK_CustomerIngredientCategoryExclusion_IngredientCategory]
GO
ALTER TABLE [dbo].[CustomerIngredientExclusion]  WITH NOCHECK ADD  CONSTRAINT [FK_CustomerIngredientExclusion_Customer] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customer] ([CustomerID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CustomerIngredientExclusion] CHECK CONSTRAINT [FK_CustomerIngredientExclusion_Customer]
GO
ALTER TABLE [dbo].[CustomerIngredientExclusion]  WITH CHECK ADD  CONSTRAINT [FK_CustomerIngredientExclusion_Ingredient] FOREIGN KEY([IngredientID])
REFERENCES [dbo].[Ingredient] ([IngredientID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CustomerIngredientExclusion] CHECK CONSTRAINT [FK_CustomerIngredientExclusion_Ingredient]
GO
ALTER TABLE [dbo].[CustomerIngredientExclusion]  WITH CHECK ADD  CONSTRAINT [FK_CustomerIngredientExclusion_IngredientLevel] FOREIGN KEY([IngredientLevelID])
REFERENCES [dbo].[IngredientLevel] ([IngredientLevelID])
GO
ALTER TABLE [dbo].[CustomerIngredientExclusion] CHECK CONSTRAINT [FK_CustomerIngredientExclusion_IngredientLevel]
GO
ALTER TABLE [dbo].[CustomerMeal]  WITH NOCHECK ADD  CONSTRAINT [FK_CustomerMeal_Customer] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customer] ([CustomerID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CustomerMeal] CHECK CONSTRAINT [FK_CustomerMeal_Customer]
GO
ALTER TABLE [dbo].[CustomerMeal]  WITH NOCHECK ADD  CONSTRAINT [FK_CustomerMeal_Meal] FOREIGN KEY([MealID])
REFERENCES [dbo].[Meal] ([MealID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CustomerMeal] CHECK CONSTRAINT [FK_CustomerMeal_Meal]
GO
ALTER TABLE [dbo].[CustomerPayment]  WITH NOCHECK ADD  CONSTRAINT [FK_CustomerPayment_Customer] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customer] ([CustomerID])
GO
ALTER TABLE [dbo].[CustomerPayment] CHECK CONSTRAINT [FK_CustomerPayment_Customer]
GO
ALTER TABLE [dbo].[CustomerPlan]  WITH NOCHECK ADD  CONSTRAINT [FK_CustomerPlan_Customer] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customer] ([CustomerID])
GO
ALTER TABLE [dbo].[CustomerPlan] NOCHECK CONSTRAINT [FK_CustomerPlan_Customer]
GO
ALTER TABLE [dbo].[CustomerPlan]  WITH NOCHECK ADD  CONSTRAINT [FK_CustomerPlan_Plan] FOREIGN KEY([PlanID])
REFERENCES [dbo].[Plan] ([PlanID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CustomerPlan] NOCHECK CONSTRAINT [FK_CustomerPlan_Plan]
GO
ALTER TABLE [dbo].[CustomerPlan]  WITH NOCHECK ADD  CONSTRAINT [FK_CustomerPlan_Promo] FOREIGN KEY([PromoID])
REFERENCES [dbo].[Promo] ([PromoID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CustomerPlan] CHECK CONSTRAINT [FK_CustomerPlan_Promo]
GO
ALTER TABLE [dbo].[CustomerPlanHold]  WITH NOCHECK ADD  CONSTRAINT [FK_CustomerPlanHold_CustomerPlan] FOREIGN KEY([CustomerPlanID])
REFERENCES [dbo].[CustomerPlan] ([CustomerPlanID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CustomerPlanHold] NOCHECK CONSTRAINT [FK_CustomerPlanHold_CustomerPlan]
GO
ALTER TABLE [dbo].[CustomOrderDay]  WITH CHECK ADD  CONSTRAINT [FK_CustomOrderDay_CustomOrder_CustomOrderID] FOREIGN KEY([CustomOrderID])
REFERENCES [dbo].[CustomOrder] ([CustomOrderID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CustomOrderDay] CHECK CONSTRAINT [FK_CustomOrderDay_CustomOrder_CustomOrderID]
GO
ALTER TABLE [dbo].[CustomOrderDayMeal]  WITH CHECK ADD  CONSTRAINT [FK_CustomOrderDayMeal_CustomOrderDay_CustomOrderDayID] FOREIGN KEY([CustomOrderDayID])
REFERENCES [dbo].[CustomOrderDay] ([CustomOrderDayID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CustomOrderDayMeal] CHECK CONSTRAINT [FK_CustomOrderDayMeal_CustomOrderDay_CustomOrderDayID]
GO
ALTER TABLE [dbo].[IngredientIngredientCategory]  WITH NOCHECK ADD  CONSTRAINT [FK_IngredientIngredientCategory_Ingredient] FOREIGN KEY([IngredientID])
REFERENCES [dbo].[Ingredient] ([IngredientID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[IngredientIngredientCategory] CHECK CONSTRAINT [FK_IngredientIngredientCategory_Ingredient]
GO
ALTER TABLE [dbo].[IngredientIngredientCategory]  WITH CHECK ADD  CONSTRAINT [FK_IngredientIngredientCategory_IngredientCategory] FOREIGN KEY([IngredientCategoryID])
REFERENCES [dbo].[IngredientCategory] ([IngredientCategoryID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[IngredientIngredientCategory] CHECK CONSTRAINT [FK_IngredientIngredientCategory_IngredientCategory]
GO
ALTER TABLE [dbo].[InventoryItem]  WITH CHECK ADD  CONSTRAINT [FK_InventoryItem_Supplier] FOREIGN KEY([SupplierID])
REFERENCES [dbo].[Supplier] ([SupplierID])
GO
ALTER TABLE [dbo].[InventoryItem] CHECK CONSTRAINT [FK_InventoryItem_Supplier]
GO
ALTER TABLE [dbo].[InventoryItemUsage]  WITH CHECK ADD  CONSTRAINT [FK_InventoryItemUsage_InventoryItem] FOREIGN KEY([InventoryItemID])
REFERENCES [dbo].[InventoryItem] ([InventoryItemID])
GO
ALTER TABLE [dbo].[InventoryItemUsage] CHECK CONSTRAINT [FK_InventoryItemUsage_InventoryItem]
GO
ALTER TABLE [dbo].[Meal]  WITH CHECK ADD  CONSTRAINT [FK_Meal_MealType] FOREIGN KEY([MealTypeID])
REFERENCES [dbo].[MealType] ([MealTypeID])
GO
ALTER TABLE [dbo].[Meal] CHECK CONSTRAINT [FK_Meal_MealType]
GO
ALTER TABLE [dbo].[MealIngredient]  WITH CHECK ADD  CONSTRAINT [FK_MealIngredient_Ingredient] FOREIGN KEY([IngredientID])
REFERENCES [dbo].[Ingredient] ([IngredientID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MealIngredient] CHECK CONSTRAINT [FK_MealIngredient_Ingredient]
GO
ALTER TABLE [dbo].[MealIngredient]  WITH CHECK ADD  CONSTRAINT [FK_MealIngredient_IngredientLevel] FOREIGN KEY([IngredientLevelID])
REFERENCES [dbo].[IngredientLevel] ([IngredientLevelID])
GO
ALTER TABLE [dbo].[MealIngredient] CHECK CONSTRAINT [FK_MealIngredient_IngredientLevel]
GO
ALTER TABLE [dbo].[MealIngredient]  WITH NOCHECK ADD  CONSTRAINT [FK_MealIngredient_Meal] FOREIGN KEY([MealID])
REFERENCES [dbo].[Meal] ([MealID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MealIngredient] CHECK CONSTRAINT [FK_MealIngredient_Meal]
GO
ALTER TABLE [dbo].[MealInventoryItem]  WITH NOCHECK ADD  CONSTRAINT [FK_MealInventoryItem_InventoryItem] FOREIGN KEY([InventoryItemID])
REFERENCES [dbo].[InventoryItem] ([InventoryItemID])
GO
ALTER TABLE [dbo].[MealInventoryItem] CHECK CONSTRAINT [FK_MealInventoryItem_InventoryItem]
GO
ALTER TABLE [dbo].[MealInventoryItem]  WITH CHECK ADD  CONSTRAINT [FK_MealInventoryItem_Meal] FOREIGN KEY([MealID])
REFERENCES [dbo].[Meal] ([MealID])
GO
ALTER TABLE [dbo].[MealInventoryItem] CHECK CONSTRAINT [FK_MealInventoryItem_Meal]
GO
ALTER TABLE [dbo].[MealPlanDetails]  WITH CHECK ADD  CONSTRAINT [FK_MealPlanDetails_Meal] FOREIGN KEY([MealID])
REFERENCES [dbo].[Meal] ([MealID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MealPlanDetails] CHECK CONSTRAINT [FK_MealPlanDetails_Meal]
GO
ALTER TABLE [dbo].[MealSubstitute]  WITH NOCHECK ADD  CONSTRAINT [FK_MealSubstitute_Meal] FOREIGN KEY([MealID])
REFERENCES [dbo].[Meal] ([MealID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MealSubstitute] CHECK CONSTRAINT [FK_MealSubstitute_Meal]
GO
ALTER TABLE [dbo].[MealSubstitute]  WITH NOCHECK ADD  CONSTRAINT [FK_MealSubstitute_Meal2] FOREIGN KEY([SubstituteMealID])
REFERENCES [dbo].[Meal] ([MealID])
GO
ALTER TABLE [dbo].[MealSubstitute] CHECK CONSTRAINT [FK_MealSubstitute_Meal2]
GO
ALTER TABLE [dbo].[MealSubstitute]  WITH CHECK ADD  CONSTRAINT [FK_MealSubstitute_Plan] FOREIGN KEY([SubstitutePlanID])
REFERENCES [dbo].[Plan] ([PlanID])
GO
ALTER TABLE [dbo].[MealSubstitute] CHECK CONSTRAINT [FK_MealSubstitute_Plan]
GO
ALTER TABLE [dbo].[Order]  WITH CHECK ADD  CONSTRAINT [FK_Menu_Order_OrderPrint] FOREIGN KEY([MenuOrderPrintID])
REFERENCES [dbo].[OrderPrint] ([OrderPrintID])
GO
ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Menu_Order_OrderPrint]
GO
ALTER TABLE [dbo].[Order]  WITH CHECK ADD  CONSTRAINT [FK_Order_Customer] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customer] ([CustomerID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_Customer]
GO
ALTER TABLE [dbo].[Order]  WITH CHECK ADD  CONSTRAINT [FK_Order_OrderStatus] FOREIGN KEY([OrderStatusID])
REFERENCES [dbo].[OrderStatus] ([OrderStatusID])
GO
ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_OrderStatus]
GO
ALTER TABLE [dbo].[Order]  WITH CHECK ADD  CONSTRAINT [FK_Order_OrderTypes] FOREIGN KEY([OrderTypeId])
REFERENCES [dbo].[OrderTypes] ([OrderTypeId])
GO
ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_OrderTypes]
GO
ALTER TABLE [dbo].[Order]  WITH CHECK ADD  CONSTRAINT [FK_Order_Plan] FOREIGN KEY([PlanID])
REFERENCES [dbo].[Plan] ([PlanID])
GO
ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_Plan]
GO
ALTER TABLE [dbo].[Order]  WITH CHECK ADD  CONSTRAINT [FK_Order_State] FOREIGN KEY([StateID])
REFERENCES [dbo].[State] ([StateID])
GO
ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_State]
GO
ALTER TABLE [dbo].[Order]  WITH CHECK ADD  CONSTRAINT [FK_PickList_Order_OrderPrint] FOREIGN KEY([PickListOrderPrintID])
REFERENCES [dbo].[OrderPrint] ([OrderPrintID])
GO
ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_PickList_Order_OrderPrint]
GO
ALTER TABLE [dbo].[OrderDay]  WITH CHECK ADD  CONSTRAINT [FK_OrderDay_Order] FOREIGN KEY([OrderID])
REFERENCES [dbo].[Order] ([OrderID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[OrderDay] CHECK CONSTRAINT [FK_OrderDay_Order]
GO
ALTER TABLE [dbo].[OrderDayMeal]  WITH CHECK ADD  CONSTRAINT [FK_OrderDayMeal_Meal] FOREIGN KEY([MealID])
REFERENCES [dbo].[Meal] ([MealID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[OrderDayMeal] CHECK CONSTRAINT [FK_OrderDayMeal_Meal]
GO
ALTER TABLE [dbo].[OrderDayMeal]  WITH CHECK ADD  CONSTRAINT [FK_OrderDayMeal_MealType] FOREIGN KEY([MealTypeID])
REFERENCES [dbo].[MealType] ([MealTypeID])
GO
ALTER TABLE [dbo].[OrderDayMeal] CHECK CONSTRAINT [FK_OrderDayMeal_MealType]
GO
ALTER TABLE [dbo].[OrderDayMeal]  WITH CHECK ADD  CONSTRAINT [FK_OrderDayMeal_OrderDay] FOREIGN KEY([OrderDayID])
REFERENCES [dbo].[OrderDay] ([OrderDayID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[OrderDayMeal] CHECK CONSTRAINT [FK_OrderDayMeal_OrderDay]
GO
ALTER TABLE [dbo].[Page]  WITH CHECK ADD  CONSTRAINT [FK_Page_Site] FOREIGN KEY([SiteID])
REFERENCES [dbo].[Site] ([SiteID])
GO
ALTER TABLE [dbo].[Page] CHECK CONSTRAINT [FK_Page_Site]
GO
ALTER TABLE [dbo].[PageAlias]  WITH NOCHECK ADD  CONSTRAINT [FK_PageAlias_Page] FOREIGN KEY([PageID])
REFERENCES [dbo].[Page] ([PageID])
GO
ALTER TABLE [dbo].[PageAlias] CHECK CONSTRAINT [FK_PageAlias_Page]
GO
ALTER TABLE [dbo].[PageAlias]  WITH NOCHECK ADD  CONSTRAINT [FK_PageAlias_Site] FOREIGN KEY([SiteID])
REFERENCES [dbo].[Site] ([SiteID])
GO
ALTER TABLE [dbo].[PageAlias] CHECK CONSTRAINT [FK_PageAlias_Site]
GO
ALTER TABLE [dbo].[PageControl]  WITH NOCHECK ADD  CONSTRAINT [FK_PageControl_Control] FOREIGN KEY([ControlID])
REFERENCES [dbo].[Control] ([ControlID])
GO
ALTER TABLE [dbo].[PageControl] CHECK CONSTRAINT [FK_PageControl_Control]
GO
ALTER TABLE [dbo].[PageControl]  WITH NOCHECK ADD  CONSTRAINT [FK_PageControl_Page] FOREIGN KEY([PageID])
REFERENCES [dbo].[Page] ([PageID])
GO
ALTER TABLE [dbo].[PageControl] CHECK CONSTRAINT [FK_PageControl_Page]
GO
ALTER TABLE [dbo].[PageControl]  WITH NOCHECK ADD  CONSTRAINT [FK_PageControl_Site] FOREIGN KEY([SiteID])
REFERENCES [dbo].[Site] ([SiteID])
GO
ALTER TABLE [dbo].[PageControl] CHECK CONSTRAINT [FK_PageControl_Site]
GO
ALTER TABLE [dbo].[PdfTemplate]  WITH CHECK ADD  CONSTRAINT [FK_PdfTemplate_Program] FOREIGN KEY([ProgramID])
REFERENCES [dbo].[Program] ([ProgramID])
GO
ALTER TABLE [dbo].[PdfTemplate] CHECK CONSTRAINT [FK_PdfTemplate_Program]
GO
ALTER TABLE [dbo].[PermissionByRole]  WITH NOCHECK ADD  CONSTRAINT [FK_PermissionByRole_BistroKey_BistroKeyId] FOREIGN KEY([PageId])
REFERENCES [dbo].[BistroKey] ([BistroKeyId])
GO
ALTER TABLE [dbo].[PermissionByRole] CHECK CONSTRAINT [FK_PermissionByRole_BistroKey_BistroKeyId]
GO
ALTER TABLE [dbo].[PermissionByRole]  WITH CHECK ADD  CONSTRAINT [FK_PermissionByRole_Role_RoleId] FOREIGN KEY([RoleId])
REFERENCES [dbo].[Role] ([RoleID])
GO
ALTER TABLE [dbo].[PermissionByRole] CHECK CONSTRAINT [FK_PermissionByRole_Role_RoleId]
GO
ALTER TABLE [dbo].[PhysicalInventoryItem]  WITH NOCHECK ADD  CONSTRAINT [FK_PhysicalInventoryItem_InventoryItem] FOREIGN KEY([InventoryItemID])
REFERENCES [dbo].[InventoryItem] ([InventoryItemID])
GO
ALTER TABLE [dbo].[PhysicalInventoryItem] CHECK CONSTRAINT [FK_PhysicalInventoryItem_InventoryItem]
GO
ALTER TABLE [dbo].[PhysicalInventoryItem]  WITH CHECK ADD  CONSTRAINT [FK_PhysicalInventoryItem_Physical] FOREIGN KEY([PhysicalID])
REFERENCES [dbo].[Physical] ([PhysicalID])
GO
ALTER TABLE [dbo].[PhysicalInventoryItem] CHECK CONSTRAINT [FK_PhysicalInventoryItem_Physical]
GO
ALTER TABLE [dbo].[Plan]  WITH CHECK ADD  CONSTRAINT [FK_Plan_Program] FOREIGN KEY([ProgramID])
REFERENCES [dbo].[Program] ([ProgramID])
GO
ALTER TABLE [dbo].[Plan] CHECK CONSTRAINT [FK_Plan_Program]
GO
ALTER TABLE [dbo].[PlanDay]  WITH CHECK ADD  CONSTRAINT [FK_PlanDay_PlanWeek] FOREIGN KEY([PlanWeekID])
REFERENCES [dbo].[PlanWeek] ([PlanWeekID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PlanDay] CHECK CONSTRAINT [FK_PlanDay_PlanWeek]
GO
ALTER TABLE [dbo].[PlanDayMeal]  WITH NOCHECK ADD  CONSTRAINT [FK_PlanDayMeal_Meal] FOREIGN KEY([MealID])
REFERENCES [dbo].[Meal] ([MealID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PlanDayMeal] CHECK CONSTRAINT [FK_PlanDayMeal_Meal]
GO
ALTER TABLE [dbo].[PlanDayMeal]  WITH CHECK ADD  CONSTRAINT [FK_PlanDayMeal_MealType] FOREIGN KEY([MealTypeID])
REFERENCES [dbo].[MealType] ([MealTypeID])
GO
ALTER TABLE [dbo].[PlanDayMeal] CHECK CONSTRAINT [FK_PlanDayMeal_MealType]
GO
ALTER TABLE [dbo].[PlanDayMeal]  WITH CHECK ADD  CONSTRAINT [FK_PlanDayMeal_PlanDay] FOREIGN KEY([PlanDayID])
REFERENCES [dbo].[PlanDay] ([PlanDayID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PlanDayMeal] CHECK CONSTRAINT [FK_PlanDayMeal_PlanDay]
GO
ALTER TABLE [dbo].[PlanWeek]  WITH NOCHECK ADD  CONSTRAINT [FK_PlanWeek_Plan] FOREIGN KEY([PlanID])
REFERENCES [dbo].[Plan] ([PlanID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PlanWeek] CHECK CONSTRAINT [FK_PlanWeek_Plan]
GO
ALTER TABLE [dbo].[PurchaseOrder]  WITH NOCHECK ADD  CONSTRAINT [FK_PurchaseOrder_Supplier] FOREIGN KEY([SupplierID])
REFERENCES [dbo].[Supplier] ([SupplierID])
GO
ALTER TABLE [dbo].[PurchaseOrder] CHECK CONSTRAINT [FK_PurchaseOrder_Supplier]
GO
ALTER TABLE [dbo].[PurchaseOrderItem]  WITH NOCHECK ADD  CONSTRAINT [FK_PurchaseOrderItem_InventoryItem] FOREIGN KEY([InventoryItemID])
REFERENCES [dbo].[InventoryItem] ([InventoryItemID])
GO
ALTER TABLE [dbo].[PurchaseOrderItem] CHECK CONSTRAINT [FK_PurchaseOrderItem_InventoryItem]
GO
ALTER TABLE [dbo].[PurchaseOrderItem]  WITH CHECK ADD  CONSTRAINT [FK_PurchaseOrderItem_PurchaseOrder] FOREIGN KEY([PurchaseOrderID])
REFERENCES [dbo].[PurchaseOrder] ([PurchaseOrderID])
GO
ALTER TABLE [dbo].[PurchaseOrderItem] CHECK CONSTRAINT [FK_PurchaseOrderItem_PurchaseOrder]
GO
ALTER TABLE [dbo].[Role]  WITH CHECK ADD  CONSTRAINT [FK_Role_Application] FOREIGN KEY([ApplicationID])
REFERENCES [dbo].[Application] ([ApplicationID])
GO
ALTER TABLE [dbo].[Role] CHECK CONSTRAINT [FK_Role_Application]
GO
ALTER TABLE [dbo].[SiteURL]  WITH CHECK ADD  CONSTRAINT [FK_SiteURL_Site] FOREIGN KEY([SiteID])
REFERENCES [dbo].[Site] ([SiteID])
GO
ALTER TABLE [dbo].[SiteURL] CHECK CONSTRAINT [FK_SiteURL_Site]
GO
ALTER TABLE [dbo].[State]  WITH CHECK ADD  CONSTRAINT [FK_State_Country] FOREIGN KEY([CountryID])
REFERENCES [dbo].[Country] ([CountryID])
GO
ALTER TABLE [dbo].[State] CHECK CONSTRAINT [FK_State_Country]
GO
ALTER TABLE [dbo].[User]  WITH CHECK ADD  CONSTRAINT [FK_User_Application] FOREIGN KEY([ApplicationID])
REFERENCES [dbo].[Application] ([ApplicationID])
GO
ALTER TABLE [dbo].[User] CHECK CONSTRAINT [FK_User_Application]
GO
ALTER TABLE [dbo].[User]  WITH CHECK ADD  CONSTRAINT [FK_User_Customer] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customer] ([CustomerID])
GO
ALTER TABLE [dbo].[User] CHECK CONSTRAINT [FK_User_Customer]
GO
ALTER TABLE [dbo].[User]  WITH CHECK ADD  CONSTRAINT [FK_User_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[User] ([UserID])
GO
ALTER TABLE [dbo].[User] CHECK CONSTRAINT [FK_User_User]
GO
ALTER TABLE [dbo].[UsersInRoles]  WITH CHECK ADD  CONSTRAINT [FK_UsersInRoles_Role] FOREIGN KEY([RoleID])
REFERENCES [dbo].[Role] ([RoleID])
GO
ALTER TABLE [dbo].[UsersInRoles] CHECK CONSTRAINT [FK_UsersInRoles_Role]
GO
ALTER TABLE [dbo].[UsersInRoles]  WITH NOCHECK ADD  CONSTRAINT [FK_UsersInRoles_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[User] ([UserID])
GO
ALTER TABLE [dbo].[UsersInRoles] CHECK CONSTRAINT [FK_UsersInRoles_User]
GO
ALTER TABLE [dbo].[VacationHoldHistory]  WITH CHECK ADD  CONSTRAINT [FK_VacationHoldHistory_Customer_CustomerID] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customer] ([CustomerID])
GO
ALTER TABLE [dbo].[VacationHoldHistory] CHECK CONSTRAINT [FK_VacationHoldHistory_Customer_CustomerID]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Current week to be fulfilled.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerPlan', @level2type=N'COLUMN',@level2name=N'Week'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'''''' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Meal'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[20] 2[15] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Customer"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 247
               Right = 212
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CustomerAccess"
            Begin Extent = 
               Top = 6
               Left = 250
               Bottom = 99
               Right = 420
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "MembershipLogin"
            Begin Extent = 
               Top = 119
               Left = 393
               Bottom = 356
               Right = 689
            End
            DisplayFlags = 280
            TopColumn = 7
         End
         Begin Table = "CustomerPlan"
            Begin Extent = 
               Top = 6
               Left = 647
               Bottom = 114
               Right = 847
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Plan"
            Begin Extent = 
               Top = 252
               Left = 38
               Bottom = 360
               Right = 197
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 2940
         Width = 2070
         Width = 1500
         Width = 1500
         Width = 3105
         Width = 3195
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'CustomersLoginLast'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'= 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'CustomersLoginLast'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'CustomersLoginLast'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Order"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 214
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "OrderDay"
            Begin Extent = 
               Top = 6
               Left = 252
               Bottom = 99
               Right = 403
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "OrderDayMeal"
            Begin Extent = 
               Top = 6
               Left = 441
               Bottom = 114
               Right = 601
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CustomerMeal"
            Begin Extent = 
               Top = 6
               Left = 639
               Bottom = 114
               Right = 800
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      En' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'PreferenceVsOrder'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'd
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'PreferenceVsOrder'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'PreferenceVsOrder'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "BulkOrderHistory"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 190
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Order"
            Begin Extent = 
               Top = 6
               Left = 228
               Bottom = 114
               Right = 404
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Plan"
            Begin Extent = 
               Top = 114
               Left = 38
               Bottom = 222
               Right = 197
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Customer"
            Begin Extent = 
               Top = 114
               Left = 235
               Bottom = 222
               Right = 409
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vueBulkOrderHistory'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vueBulkOrderHistory'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Order"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 214
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Customer"
            Begin Extent = 
               Top = 6
               Left = 252
               Bottom = 114
               Right = 426
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "AgentNote"
            Begin Extent = 
               Top = 114
               Left = 38
               Bottom = 222
               Right = 201
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vueCancelledAndCreatedOrderFrommybistroMD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vueCancelledAndCreatedOrderFrommybistroMD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vueCustomerList'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vueCustomerList'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "CustomOrder"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 214
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Customer"
            Begin Extent = 
               Top = 91
               Left = 247
               Bottom = 199
               Right = 421
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Plan"
            Begin Extent = 
               Top = 185
               Left = 39
               Bottom = 293
               Right = 198
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Order"
            Begin Extent = 
               Top = 103
               Left = 640
               Bottom = 211
               Right = 816
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 10
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
        ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vueCustomOrderList'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N' Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vueCustomOrderList'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vueCustomOrderList'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "a"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 227
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Meal"
            Begin Extent = 
               Top = 6
               Left = 265
               Bottom = 114
               Right = 451
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vueExcludedMealsReport'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vueExcludedMealsReport'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "CustomerMeal"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 199
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Order"
            Begin Extent = 
               Top = 6
               Left = 237
               Bottom = 114
               Right = 413
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Meal"
            Begin Extent = 
               Top = 114
               Left = 38
               Bottom = 222
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vueGetCustomerMeals'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vueGetCustomerMeals'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[20] 2[29] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Order"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 230
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "OrderDay"
            Begin Extent = 
               Top = 6
               Left = 252
               Bottom = 99
               Right = 403
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "OrderDayMeal"
            Begin Extent = 
               Top = 6
               Left = 441
               Bottom = 114
               Right = 601
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Meal"
            Begin Extent = 
               Top = 210
               Left = 235
               Bottom = 318
               Right = 405
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "MealType"
            Begin Extent = 
               Top = 6
               Left = 1018
               Bottom = 84
               Right = 1169
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Plan"
            Begin Extent = 
               Top = 114
               Left = 38
               Bottom = 222
               Right = 213
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "A"
            Begin Extent = 
               Top = 6
               Left = 639
               Bottom = 99
               Right = 791
            End
            DisplayFlags = 280
            ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vueGetMealsInMenus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'TopColumn = 0
         End
         Begin Table = "B"
            Begin Extent = 
               Top = 6
               Left = 829
               Bottom = 99
               Right = 980
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vueGetMealsInMenus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vueGetMealsInMenus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "a"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 189
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vueMealAndIngredientPreferenceHistory'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vueMealAndIngredientPreferenceHistory'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Meal"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 272
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 13
         End
         Begin Table = "MealType"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 84
               Right = 397
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "A"
            Begin Extent = 
               Top = 84
               Left = 246
               Bottom = 162
               Right = 397
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vueMealList'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vueMealList'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "a"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 84
               Right = 189
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Meal"
            Begin Extent = 
               Top = 6
               Left = 227
               Bottom = 114
               Right = 397
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "MealType"
            Begin Extent = 
               Top = 6
               Left = 435
               Bottom = 84
               Right = 586
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vueMealsByDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vueMealsByDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Order"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 214
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "OrderStatus"
            Begin Extent = 
               Top = 6
               Left = 252
               Bottom = 84
               Right = 403
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Plan"
            Begin Extent = 
               Top = 84
               Left = 252
               Bottom = 192
               Right = 411
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Customer"
            Begin Extent = 
               Top = 114
               Left = 38
               Bottom = 222
               Right = 212
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CustomerStatus"
            Begin Extent = 
               Top = 192
               Left = 250
               Bottom = 270
               Right = 418
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Program"
            Begin Extent = 
               Top = 222
               Left = 38
               Bottom = 330
               Right = 189
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         A' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vueOrderList'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'lias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vueOrderList'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vueOrderList'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Plan"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 206
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Program"
            Begin Extent = 
               Top = 6
               Left = 244
               Bottom = 125
               Right = 404
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vuePlanList'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vuePlanList'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Program"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 198
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vueProgramList'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vueProgramList'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "User"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 329
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vueUserList'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vueUserList'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[49] 4[15] 2[23] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "OrderDay"
            Begin Extent = 
               Top = 30
               Left = 876
               Bottom = 182
               Right = 1036
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Order"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 223
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "OrderDayMeal"
            Begin Extent = 
               Top = 88
               Left = 474
               Bottom = 320
               Right = 643
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Me"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 206
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "AN"
            Begin Extent = 
               Top = 148
               Left = 263
               Bottom = 255
               Right = 435
            End
            DisplayFlags = 280
            TopColumn = 1
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vuSalesOrder'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'= 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vuSalesOrder'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vuSalesOrder'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[39] 4[20] 2[17] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Customer"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 370
               Right = 212
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CustomerAccess"
            Begin Extent = 
               Top = 10
               Left = 542
               Bottom = 169
               Right = 712
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "MembershipLogin"
            Begin Extent = 
               Top = 0
               Left = 720
               Bottom = 240
               Right = 1016
            End
            DisplayFlags = 280
            TopColumn = 2
         End
         Begin Table = "CustomerPlan"
            Begin Extent = 
               Top = 336
               Left = 788
               Bottom = 526
               Right = 988
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Plan"
            Begin Extent = 
               Top = 80
               Left = 1230
               Bottom = 188
               Right = 1389
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 12
         Width = 284
         Width = 2355
         Width = 2055
         Width = 2730
         Width = 1500
         Width = 3690
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VwCustomerAccessReport'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N' = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VwCustomerAccessReport'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VwCustomerAccessReport'
GO
