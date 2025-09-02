SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
peut-on faire mieux ?
1/ ce code est-il correct ?
2/ faites mieux pour SQL Server 2005
3/ faites mieux pour SQL Server 2008 et suivants
4/ améliorez la procédure autant que possible
*/

ALTER PROCEDURE [Contact].[AjouteContact]
    @Titre varchar(3) = 'M.',
    @Nom varchar(50),
    @Prenom varchar(50),
    @Email varchar(150),
    @Telephone varchar(15) = NULL,
    @Telecopie varchar(15) = NULL,
    @Sexe varchar(1) = NULL,
    @Portable varchar(15) = NULL
AS BEGIN
	SET NOCOUNT ON

	DECLARE @id int
	DECLARE @table TABLE (ContactId int)

    UPDATE Contact.Contact
    SET Titre = @Titre, 
        Nom = @Nom, 
        Prenom = @Prenom,  
        Telephone = 
			CASE 
				WHEN @Telephone = '' THEN Telephone 
				ELSE @Telephone 
			END, 
        Telecopie = @Telecopie,
        Sexe = @Sexe, 
        Portable = @Portable,
		@id = ContactId
    OUTPUT inserted.ContactId INTO @table
	WHERE Email = @Email
	

	IF @@ROWCOUNT = 0 BEGIN
        INSERT INTO Contact.Contact
		    (Titre, Nom, Prenom, Email, Telephone, Telecopie, Sexe, Portable)
        OUTPUT inserted.ContactId INTO @table
        VALUES
            (@Titre, @Nom, @Prenom, @Email, @Telephone, @Telecopie, @Sexe, @Portable)
	
		SET @id = SCOPE_IDENTITY()
	END

    RETURN @id
END
GO
