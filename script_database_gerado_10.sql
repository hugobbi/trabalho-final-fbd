-- Matheus Henrique Sabadin – 00228729
-- Henrique Uhlmann Gobbi – 00334932


-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE Language (
	LangCode uuid PRIMARY KEY,
    LangLabel varchar(80) NOT NULL
);

CREATE TABLE Publisher (
	PubCode uuid PRIMARY KEY,
    PubLabel varchar(80) NOT NULL
);

CREATE TABLE Country (
    CtryCode uuid PRIMARY KEY,
	CtryLabel varchar(80) NOT NULL
);

CREATE TABLE Author (
    AuthorCode uuid PRIMARY KEY,
	AuthorLabel varchar(500) NOT NULL
);

CREATE TABLE Gender (
	GendCode uuid PRIMARY KEY,
    GendLabel varchar(80) NOT NULL
);

CREATE TABLE Book (
    ISBN13 bigint PRIMARY KEY NOT NULL,
    Title varchar(500) NOT NULL,
    PageCount smallint NOT NULL,
    RatingCount int NOT NULL,
    ReviewCount int NOT NULL,
    PublishingDate date NOT NULL,
    CtryCode uuid NOT NULL,
    PubCode uuid NOT NULL,
    LangCode uuid NOT NULL,
	FOREIGN KEY (CtryCode) REFERENCES Country(CtryCode) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (PubCode) REFERENCES Publisher(PubCode) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (LangCode) REFERENCES Language(LangCode) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE GoodreadsUser (
    UserCode uuid PRIMARY KEY,
    UserName varchar(80) NOT NULL,
    Age smallint,
    Sex char,
    Email varchar(80) NOT NULL
);

CREATE TABLE Follows (
    FlwCode uuid PRIMARY KEY,
	UserACode uuid NOT NULL,
	UserBCode uuid NOT NULL
);

CREATE TABLE Rating (
    RtgCode uuid PRIMARY KEY,
    NumberOfStars smallint NOT NULL,
	UserCode uuid NOT NULL,
	ISBN13 bigint NOT NULL,
	FOREIGN KEY (UserCode) REFERENCES GoodreadsUser(UserCode) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (ISBN13) REFERENCES Book(ISBN13) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Review (
    RvwCode uuid PRIMARY KEY,
    Text text NOT NULL,
    UserCode uuid NOT NULL,
	ISBN13 bigint NOT NULL,
	FOREIGN KEY (UserCode) REFERENCES GoodreadsUser(UserCode) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (ISBN13) REFERENCES Book(ISBN13) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE HasGender (
	HasGendCode uuid,
    ISBN13 bigint NOT NULL,
    GendCode uuid NOT NULL,
	FOREIGN KEY (ISBN13) REFERENCES Book(ISBN13) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (GendCode) REFERENCES Gender(GendCode) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE WrittenBy (
	WrittenByCode uuid,
	ISBN13 bigint NOT NULL,
    AuthorCode uuid NOT NULL,
	FOREIGN KEY (ISBN13) REFERENCES Book(ISBN13) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (AuthorCode) REFERENCES Author(AuthorCode) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE BookshelfBook (
    BookshelfBookCode uuid PRIMARY KEY,
    BookStatus varchar(20) NOT NULL,
	UserCode uuid NOT NULL,
	ISBN13 bigint NOT NULL,
	FOREIGN KEY (UserCode) REFERENCES GoodreadsUser(UserCode) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (ISBN13) REFERENCES Book(ISBN13) ON UPDATE CASCADE ON DELETE CASCADE
);

INSERT INTO Language (LangLabel, LangCode) VALUES
('eng', '34e689b9-1d3f-4618-b0ae-def52417eb1f'),
('en-US', '2c7a6703-5264-41d3-be52-f0d37022a02c'),
('eng', '44a2df69-64b4-49a2-b272-b10105073391'),
('eng', 'eaa940b1-1c52-45c4-9610-d7911e10f34b'),
('en-US', '28ce28bc-e6a4-4761-b662-5b980ad3e186'),
('eng', '1b0db30c-2438-48c3-b331-3269bdca41c3'),
('en-GB', '601a0e28-b561-45c8-b6f5-dc41dc491b7d'),
('eng', '111706d4-0d2a-481e-8362-638c895c9bd3'),
('en-CA', '9470f474-d929-43c3-9f59-9a122eecda72'),
('en-US', '1d735cf6-74e9-406f-9c51-b3362db9a8ca');

INSERT INTO Publisher (PubLabel, PubCode) VALUES
('Ecco', '44fd84da-c499-4d00-a703-a8427956f025'),
('Speak', '5773813f-d6b8-418c-a82b-df6e009b057a'),
('Trine Day', '4805ed54-3b5c-4d9f-b777-c99eeee4e928'),
('McGraw-Hill Education', '7e84a37e-f144-4db0-9f64-d699582f285f'),
('William Morrow Paperbacks', '807b2165-b0bc-4755-b5d1-35d33f543502'),
('Little  Brown Books for Young Readers', '7128ab2b-2704-4576-9b62-8888a552d74e'),
('Penguin Books', '00d23545-8cbb-4852-afab-2e1ed24e9a21'),
('DC Comics', 'e84cfb44-2a91-48f2-ae9c-c0aed6b51a7c'),
('CDS Books', '414cf695-6961-4b39-a898-5ddc70b6e615'),
('Holiday House', '455bfb1e-06f1-4d6c-8753-bd202ee492bb');

INSERT INTO Country (CtryLabel, CtryCode) VALUES
('eng', 'ce7a50bc-236c-4b4e-93a5-13671674b154'),
('en-US', '7c0dd409-db1c-4e65-b4c5-097e5c26b712'),
('eng', '57b38b9f-696c-424e-bbef-76fe9ce23095'),
('eng', 'ef235b71-9a61-42b2-a14c-239ebc55f480'),
('en-US', '0ee86bf4-f569-40c0-b4cd-215a6eb4d78b'),
('eng', '848209c6-fe30-4bef-aa8e-78a1ac09fbed'),
('en-GB', '478f7cbd-0716-4fa4-9276-9e8007bbf003'),
('eng', '04b7b978-b53d-499d-82af-567771805310'),
('en-CA', 'e9d96708-d2ba-46b1-b966-6586373cf611'),
('en-US', '0dc567f9-acf8-489e-a845-8e091fadb14d');

INSERT INTO Author (AuthorLabel, AuthorCode) VALUES
('Paul Bowles/Francine Prose', '58436e1c-474d-4936-970f-f15d87e5bc54'),
('S.E. Hinton', '48c44d01-fcf0-47a8-9c0e-0882c15d8ff5'),
('Edward T. Haslam/Jim Marrs', 'fe13c91d-00a5-46d4-9088-8d18247fd57f'),
('Bill   Phillips', '7a55aff5-70c4-437a-a09d-90f824b65527'),
('Karin Slaughter/Peter Robinson/John Connolly/Denise Mina/Mark Billingham', '45e21d76-b027-4517-8362-39c70df4caf9'),
('Mary Pope Osborne/Troy Howell', 'fa194d73-12bc-489f-b748-f02031c687e5'),
('H.P. Lovecraft', '7dc7d769-0392-4f1f-9519-635669f9d52f'),
('Robert Kanigher/Bob Haney/Joe Kubert/Jerry Grandinetti', 'd547246d-be64-49f7-96f2-b2f8ac21aaf6'),
('David Morrell', '20736f49-ef60-4844-b971-5aaa7bd130c3'),
('Tomie dePaola', '22872424-daaa-460b-a959-87bdc8ba06b9');

INSERT INTO Gender (GendLabel, GendCode) VALUES
('Contemporary Fiction', '93db4695-dd32-43f6-ab92-94e40c13331c'),
('Romance', 'cb8a0197-1525-4d76-b3ff-99122dff2bf3'),
('Non-Fiction', 'cb5b1da1-46ab-428e-9614-1a437e758bc0'),
('Cookbook/Culinary', '8674ea4a-12f5-40cc-88db-992f12a148ec'),
('Graphic Novel/Comic', '7756aa79-81b0-4331-b072-a8a22ec2b6e0'),
('Memoir', 'ddb5277b-2900-45c8-875b-2e74fa8de7d6'),
('Self-Help', '736cf25e-2ee7-4e5d-936c-c07f17763aa4'),
('Young Adult', 'f13cb27e-5f40-4559-9057-be9a40d2f6e3'),
('Historical Fiction', '962d3d71-39ad-4e35-b775-826b8ea66ed5'),
('Steampunk', '5308566e-9ddb-40fd-b003-2f4961691a8c');

INSERT INTO Book (ISBN13, Title, PageCount, RatingCount, ReviewCount, PublishingDate, CtryCode, PubCode, LangCode) VALUES
(9780061137037, 'The Spiders House', 432, 1123, 99, '31/10/2006', 'ce7a50bc-236c-4b4e-93a5-13671674b154', '44fd84da-c499-4d00-a703-a8427956f025', '34e689b9-1d3f-4618-b0ae-def52417eb1f'),
(9780140389661, 'That Was Then  This Is Now', 159, 26776, 1630, '1/4/1998', '7c0dd409-db1c-4e65-b4c5-097e5c26b712', '5773813f-d6b8-418c-a82b-df6e009b057a', '2c7a6703-5264-41d3-be52-f0d37022a02c'),
(9780977795306, 'Dr. Marys Monkey: How the Unsolved Murder of a Doctor  a Secret Laboratory in New Orleans and Cancer-Causing Monkey Viruses are Linked to Lee Harvey Oswald  the JFK Assassination and Emerging Global Epidemics', 374, 1023, 164, '1/4/2007', '57b38b9f-696c-424e-bbef-76fe9ce23095', '4805ed54-3b5c-4d9f-b777-c99eeee4e928', '44a2df69-64b4-49a2-b272-b10105073391'),
(9780071467445, 'The Complete Book of Home  Site and Office Security: Selecting  Installing and Troubleshooting Systems and Devices', 309, 2, 0, '1/8/2006', 'ef235b71-9a61-42b2-a14c-239ebc55f480', '7e84a37e-f144-4db0-9f64-d699582f285f', 'eaa940b1-1c52-45c4-9610-d7911e10f34b'),
(9780060583316, 'Like A Charm', 384, 22, 4, '26/5/2015', '0ee86bf4-f569-40c0-b4cd-215a6eb4d78b', '807b2165-b0bc-4755-b5d1-35d33f543502', '28ce28bc-e6a4-4761-b662-5b980ad3e186'),
(9780786809936, 'Return to Ithaca (Tales from the Odyssey  #5)', 112, 280, 19, '1/10/2004', '848209c6-fe30-4bef-aa8e-78a1ac09fbed', '7128ab2b-2704-4576-9b62-8888a552d74e', '1b0db30c-2438-48c3-b331-3269bdca41c3'),
(9780141187068, 'The Call of Cthulhu and Other Weird Stories', 420, 809, 74, '25/7/2002', '478f7cbd-0716-4fa4-9276-9e8007bbf003', '00d23545-8cbb-4852-afab-2e1ed24e9a21', '601a0e28-b561-45c8-b6f5-dc41dc491b7d'),
(9781563898419, 'The Sgt. Rock Archives  Vol. 1', 240, 47, 1, '1/5/2002', '04b7b978-b53d-499d-82af-567771805310', 'e84cfb44-2a91-48f2-ae9c-c0aed6b51a7c', '111706d4-0d2a-481e-8362-638c895c9bd3'),
(9781593153571, 'Creepers', 388, 4513, 515, '26/9/2005', 'e9d96708-d2ba-46b1-b966-6586373cf611', '414cf695-6961-4b39-a898-5ddc70b6e615', '9470f474-d929-43c3-9f59-9a122eecda72'),
(9780823410774, 'Patrick: Patron Saint of Ireland', 30, 89, 5, '1/1/1992', '0dc567f9-acf8-489e-a845-8e091fadb14d', '455bfb1e-06f1-4d6c-8753-bd202ee492bb', '1d735cf6-74e9-406f-9c51-b3362db9a8ca');

INSERT INTO HasGender (HasGendCode, ISBN13, GendCode) VALUES
('0c28a1c2-0f6c-44f4-b496-e000e2975bb1', 9780061137037, '93db4695-dd32-43f6-ab92-94e40c13331c'),
('7140efe5-0daa-426c-aa84-c4cbc3b776b2', 9780140389661, 'cb8a0197-1525-4d76-b3ff-99122dff2bf3'),
('4809c0bd-169f-4447-9434-d663b3823557', 9780977795306, 'cb5b1da1-46ab-428e-9614-1a437e758bc0'),
('c5d61bbb-9988-47d7-b672-bdcf5e5b3571', 9780071467445, '8674ea4a-12f5-40cc-88db-992f12a148ec'),
('fa023b28-028e-4b85-a7dc-2833151cbc86', 9780060583316, '7756aa79-81b0-4331-b072-a8a22ec2b6e0'),
('d2e5bd37-2600-481d-a41f-63a6748147c6', 9780786809936, 'ddb5277b-2900-45c8-875b-2e74fa8de7d6'),
('e9453c6a-37df-44bf-86fa-9262dee5b955', 9780141187068, '736cf25e-2ee7-4e5d-936c-c07f17763aa4'),
('5ac623c2-bead-4830-b63c-56b54898e761', 9781563898419, 'f13cb27e-5f40-4559-9057-be9a40d2f6e3'),
('7c9014be-25bf-4cab-a73c-96d5ffca260c', 9781593153571, '962d3d71-39ad-4e35-b775-826b8ea66ed5'),
('1afba6b8-e845-48eb-83d8-047723cb1087', 9780823410774, '5308566e-9ddb-40fd-b003-2f4961691a8c');

INSERT INTO WrittenBy (WrittenByCode, ISBN13, AuthorCode) VALUES
('aef09761-cb26-4ca3-888d-22d8879652bd', 9780061137037, '58436e1c-474d-4936-970f-f15d87e5bc54'),
('68bd30a6-ea6e-4af6-a23c-2dd430f454c3', 9780140389661, '48c44d01-fcf0-47a8-9c0e-0882c15d8ff5'),
('75dd110e-b429-481f-98e1-338611c7426a', 9780977795306, 'fe13c91d-00a5-46d4-9088-8d18247fd57f'),
('5118e2ab-2764-48b7-93ef-51a88051c271', 9780071467445, '7a55aff5-70c4-437a-a09d-90f824b65527'),
('d11cf1dc-b57c-498f-81c9-2564c23beec7', 9780060583316, '45e21d76-b027-4517-8362-39c70df4caf9'),
('4950e988-73c7-4abc-973a-7851dadc56df', 9780786809936, 'fa194d73-12bc-489f-b748-f02031c687e5'),
('a51ed999-6b5f-45ac-aec9-39001f9e6164', 9780141187068, '7dc7d769-0392-4f1f-9519-635669f9d52f'),
('1e9aef43-a7ef-4389-a110-dd3ffd2ae614', 9781563898419, 'd547246d-be64-49f7-96f2-b2f8ac21aaf6'),
('a3b3303e-d018-4c35-bd87-3489abffdd90', 9781593153571, '20736f49-ef60-4844-b971-5aaa7bd130c3'),
('48d2af2c-6dfc-4854-95a8-9a0fe20f0fec', 9780823410774, '22872424-daaa-460b-a959-87bdc8ba06b9');

INSERT INTO GoodreadsUser (UserCode, Age, UserName, Sex, Email) VALUES
('cc9a201f-d042-4e05-9c45-a0dbcde6154c', 84, 'miamitchell67', 'M', 'miamitchell63@gmail.com'),
('16361ee3-294d-4a6a-93da-1e7fe93f9165', 90, 'wendywilliams23', 'M', 'wendywilliams87@gmail.com'),
('f0a9ade6-81d5-4fd7-a8b2-b9fb22bb51e5', 97, 'jackjohnson43', 'F', 'jackjohnson98@gmail.com'),
('56a543cf-3c9c-4ea8-bcb0-a3c6f91c3fe0', 100, 'tinataylor85', 'F', 'tinataylor48@gmail.com'),
('0abcbe33-d00f-427e-aec6-a99783a68f3f', 62, 'nathannguyen38', 'F', 'nathannguyen6@gmail.com'),
('f99bc944-c10e-4ca4-8bab-bfca3ed01185', 85, 'charliechen27', 'F', 'charliechen46@gmail.com'),
('ace782b9-f45d-4981-9ac8-b2ac72549cd7', 25, 'samsmith87', 'M', 'samsmith37@gmail.com'),
('ac09eda3-f4e3-42c1-b771-2e7659a9a4ed', 83, 'daviddavis53', 'F', 'daviddavis59@gmail.com'),
('7525e1f9-8e1a-45ac-815f-2a1018b06fe3', 93, 'tinataylor53', 'F', 'tinataylor56@gmail.com'),
('e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8', 85, 'yarayoung2', 'F', 'yarayoung14@gmail.com');

INSERT INTO Rating (RtgCode, NumberOfStars, UserCode, ISBN13) VALUES
('884510ed-2362-4a33-a20b-adb575027a1a', 2, 'cc9a201f-d042-4e05-9c45-a0dbcde6154c', '9780977795306'),
('92a3325b-b1c6-4406-a27a-d33b6fe681d2', 3, '16361ee3-294d-4a6a-93da-1e7fe93f9165', '9780823410774'),
('62825e98-8636-481b-a2a1-8423b57c0612', 0, '16361ee3-294d-4a6a-93da-1e7fe93f9165', '9780061137037'),
('fc6bcf8a-8613-4e77-943f-8c9d357abe62', 4, '16361ee3-294d-4a6a-93da-1e7fe93f9165', '9780060583316'),
('9a73c342-6306-406b-b94f-471d573c25c9', 1, '16361ee3-294d-4a6a-93da-1e7fe93f9165', '9780140389661'),
('25172a01-56b7-4acd-86fb-7ecb343ee5d1', 4, '16361ee3-294d-4a6a-93da-1e7fe93f9165', '9780140389661'),
('dcc462b4-a078-4380-9c43-bed560633583', 5, '16361ee3-294d-4a6a-93da-1e7fe93f9165', '9780140389661'),
('1d830f34-d6dc-4392-8800-c6c73133f912', 2, '16361ee3-294d-4a6a-93da-1e7fe93f9165', '9780071467445'),
('32fe0897-b160-4954-8cab-d04432a6da9e', 3, '16361ee3-294d-4a6a-93da-1e7fe93f9165', '9780141187068'),
('eb5686d3-bf5d-49f4-8fa4-1857ec0b9a30', 1, '16361ee3-294d-4a6a-93da-1e7fe93f9165', '9780060583316'),
('3cc086b2-af0f-4eb1-b767-450574c14555', 0, '16361ee3-294d-4a6a-93da-1e7fe93f9165', '9780977795306'),
('86bc9ce4-f801-4860-a231-47bba95d1224', 5, '16361ee3-294d-4a6a-93da-1e7fe93f9165', '9780061137037'),
('7d0282b9-205e-4400-b73d-9cff3e187c7c', 4, '16361ee3-294d-4a6a-93da-1e7fe93f9165', '9780786809936'),
('9cf566b5-ac09-46a1-958e-9715ebaf1196', 1, '16361ee3-294d-4a6a-93da-1e7fe93f9165', '9780060583316'),
('be61d9b2-76cd-42f1-91c4-b1f26eeff180', 4, '16361ee3-294d-4a6a-93da-1e7fe93f9165', '9780786809936'),
('fd5be266-0d1e-421b-bf71-d335ac61d3bd', 2, '16361ee3-294d-4a6a-93da-1e7fe93f9165', '9780141187068'),
('2d59a5bb-bcae-4d46-a70c-4fba857cad2a', 0, '16361ee3-294d-4a6a-93da-1e7fe93f9165', '9780977795306'),
('4e71a9cd-24b7-4be1-a933-89116f097012', 3, '16361ee3-294d-4a6a-93da-1e7fe93f9165', '9780060583316'),
('118ba50f-82a4-4579-86f3-1342608045d2', 2, '16361ee3-294d-4a6a-93da-1e7fe93f9165', '9780140389661'),
('ba761b55-1a02-43f8-a758-87ce445edc13', 3, 'f0a9ade6-81d5-4fd7-a8b2-b9fb22bb51e5', '9780977795306'),
('a0ef0af6-526c-40bf-bca7-ca4e14aac547', 0, 'f0a9ade6-81d5-4fd7-a8b2-b9fb22bb51e5', '9780140389661'),
('cfa2d33e-3a9b-4880-8720-eceb792cd3c0', 5, 'f0a9ade6-81d5-4fd7-a8b2-b9fb22bb51e5', '9781563898419'),
('90b7ef4d-bf10-4c0e-8470-5a8b606516ff', 4, 'f0a9ade6-81d5-4fd7-a8b2-b9fb22bb51e5', '9780141187068'),
('995a638b-d460-4aac-bd7b-059f4086d091', 2, 'f0a9ade6-81d5-4fd7-a8b2-b9fb22bb51e5', '9780786809936'),
('96e1bce5-776f-4d36-a04d-347fd5e94199', 2, 'f0a9ade6-81d5-4fd7-a8b2-b9fb22bb51e5', '9781593153571'),
('0c076a61-0b0d-4975-9f37-21dd166f6da1', 4, 'f0a9ade6-81d5-4fd7-a8b2-b9fb22bb51e5', '9780786809936'),
('831fee98-7238-44ea-84ef-a408f942d822', 3, 'f0a9ade6-81d5-4fd7-a8b2-b9fb22bb51e5', '9780823410774'),
('78c76235-4950-4da1-904e-29466e6afaca', 1, 'f0a9ade6-81d5-4fd7-a8b2-b9fb22bb51e5', '9780060583316'),
('39cc6fce-108a-425f-b7cb-9c2633b27581', 0, 'f0a9ade6-81d5-4fd7-a8b2-b9fb22bb51e5', '9780061137037'),
('33cb1740-e96b-430c-a155-6051b1db181f', 3, '56a543cf-3c9c-4ea8-bcb0-a3c6f91c3fe0', '9780977795306'),
('7c831690-9f9e-49ce-82f1-a28628007f8a', 4, '0abcbe33-d00f-427e-aec6-a99783a68f3f', '9780977795306'),
('629a52aa-d2fc-4e69-813d-1f03848d43ba', 3, '0abcbe33-d00f-427e-aec6-a99783a68f3f', '9780061137037'),
('4d11d300-ba30-4480-b815-8cdb207daa4d', 3, '0abcbe33-d00f-427e-aec6-a99783a68f3f', '9780823410774'),
('458670aa-01b6-4aec-b949-ca3d8970a3ad', 3, '0abcbe33-d00f-427e-aec6-a99783a68f3f', '9780977795306'),
('bc3321db-791e-47df-b649-ea6c9ef5922d', 2, '0abcbe33-d00f-427e-aec6-a99783a68f3f', '9780141187068'),
('8c06c2a2-c6b4-43ab-a886-c7b54161ad79', 2, '0abcbe33-d00f-427e-aec6-a99783a68f3f', '9780823410774'),
('48bd2b0b-ce2f-40a3-96c7-396da0002840', 3, '0abcbe33-d00f-427e-aec6-a99783a68f3f', '9780060583316'),
('1ab68600-a74b-4a15-9aa4-6d1dc0f5e2cf', 4, '0abcbe33-d00f-427e-aec6-a99783a68f3f', '9781563898419'),
('1caa4a82-aa61-48e0-be70-90240c747e3d', 3, '0abcbe33-d00f-427e-aec6-a99783a68f3f', '9780061137037'),
('e4997df0-89c2-4c1f-a8b7-14c2e82a51b7', 2, '0abcbe33-d00f-427e-aec6-a99783a68f3f', '9780141187068'),
('721942fb-4b98-4110-8022-97a7e54057a4', 0, '0abcbe33-d00f-427e-aec6-a99783a68f3f', '9780823410774'),
('f505c1b8-ba87-4495-9ca2-c6c03bef1b18', 4, '0abcbe33-d00f-427e-aec6-a99783a68f3f', '9780823410774'),
('295e0645-bf8a-4283-91bc-5336590a7269', 0, '0abcbe33-d00f-427e-aec6-a99783a68f3f', '9780061137037'),
('f40eb69b-ecbe-431e-b8ec-94e6a75fbc75', 4, '0abcbe33-d00f-427e-aec6-a99783a68f3f', '9780140389661'),
('cec782d2-ebd5-4626-a775-2d2fdcda1aa5', 4, '0abcbe33-d00f-427e-aec6-a99783a68f3f', '9780141187068'),
('e79d94dc-7896-4088-968f-aa067fe8ed3a', 0, '0abcbe33-d00f-427e-aec6-a99783a68f3f', '9781593153571'),
('83b493cc-92b4-4f9e-940c-c253a5344806', 1, '0abcbe33-d00f-427e-aec6-a99783a68f3f', '9780786809936'),
('28d0b24b-3f37-44e6-92cc-9d4d9d0e5309', 2, '0abcbe33-d00f-427e-aec6-a99783a68f3f', '9780977795306'),
('4ec9a3a6-909e-4160-9cd4-efe06acb8b58', 5, '0abcbe33-d00f-427e-aec6-a99783a68f3f', '9780786809936'),
('0d868b6f-0ce4-4c3a-8121-69f8ae77d0c2', 5, '0abcbe33-d00f-427e-aec6-a99783a68f3f', '9780823410774'),
('110158fe-dd21-4df4-82c3-7f7267d51454', 5, '0abcbe33-d00f-427e-aec6-a99783a68f3f', '9780061137037'),
('98a6e1b8-4c38-46bf-9ea2-f42f8a1e195d', 4, 'f99bc944-c10e-4ca4-8bab-bfca3ed01185', '9781563898419'),
('2af0caa4-afb9-4cae-97e4-54b414aa3023', 3, 'f99bc944-c10e-4ca4-8bab-bfca3ed01185', '9781593153571'),
('9afe8a05-15c9-4ecf-9a5b-a48095f25e46', 2, 'f99bc944-c10e-4ca4-8bab-bfca3ed01185', '9780977795306'),
('043f86dc-7821-4bee-9bf2-7a7bba6fd91a', 4, 'f99bc944-c10e-4ca4-8bab-bfca3ed01185', '9780823410774'),
('c371a2f9-46b3-4a4f-8e9c-d0e648eba9c4', 1, 'f99bc944-c10e-4ca4-8bab-bfca3ed01185', '9780140389661'),
('0644e96f-b942-4787-a254-848b8056c1c4', 2, 'f99bc944-c10e-4ca4-8bab-bfca3ed01185', '9780140389661'),
('d89b9814-8799-4c12-aac7-d076ad03ddab', 2, 'f99bc944-c10e-4ca4-8bab-bfca3ed01185', '9781593153571'),
('c538480f-6f67-436d-b1b4-46adc7afcd93', 3, 'f99bc944-c10e-4ca4-8bab-bfca3ed01185', '9780061137037'),
('855cb48a-f20e-450c-9172-170a1d5dbba8', 5, 'f99bc944-c10e-4ca4-8bab-bfca3ed01185', '9781563898419'),
('ea155e91-ca35-4ffc-af19-945882ae0b50', 3, 'f99bc944-c10e-4ca4-8bab-bfca3ed01185', '9780786809936'),
('a60e84ef-75fa-4620-af0d-65fb1f84bfbb', 5, 'f99bc944-c10e-4ca4-8bab-bfca3ed01185', '9780977795306'),
('61b60bf2-4c71-4498-a457-8e031be2bc8e', 0, 'f99bc944-c10e-4ca4-8bab-bfca3ed01185', '9780823410774'),
('ef136e33-1ee4-44d0-afae-349a9bb54da6', 5, 'f99bc944-c10e-4ca4-8bab-bfca3ed01185', '9780061137037'),
('bf2de9b6-0b04-4251-8686-c59cb8e629b1', 5, 'f99bc944-c10e-4ca4-8bab-bfca3ed01185', '9781593153571'),
('41a13dc9-9fd4-4529-9f37-114921cb35f4', 0, 'f99bc944-c10e-4ca4-8bab-bfca3ed01185', '9780071467445'),
('881dad09-0327-4eae-b1c6-7ab1d960294c', 4, 'f99bc944-c10e-4ca4-8bab-bfca3ed01185', '9780786809936'),
('717c3b7a-8420-43fd-b986-02ca3fb4a005', 0, 'f99bc944-c10e-4ca4-8bab-bfca3ed01185', '9780977795306'),
('6a56734e-02e5-49cb-b7e1-80854633978f', 2, 'f99bc944-c10e-4ca4-8bab-bfca3ed01185', '9780823410774'),
('86968d90-1830-4f9b-9cf4-d343236d426f', 0, 'f99bc944-c10e-4ca4-8bab-bfca3ed01185', '9780141187068'),
('f8a48a1f-2ff8-466e-8b25-7c817d06dd54', 5, 'f99bc944-c10e-4ca4-8bab-bfca3ed01185', '9780061137037'),
('06ed1efc-6ab6-4d4f-9493-30ee07427be4', 0, 'f99bc944-c10e-4ca4-8bab-bfca3ed01185', '9780060583316'),
('8c227095-03e7-435f-90c5-338a63620c52', 3, 'f99bc944-c10e-4ca4-8bab-bfca3ed01185', '9780071467445'),
('3f6b3a5b-f980-4dca-bb0d-2aabd29280c1', 0, 'f99bc944-c10e-4ca4-8bab-bfca3ed01185', '9780977795306'),
('810e2ac3-ba5c-420e-a707-d55e1947ef63', 3, 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', '9780140389661'),
('7887df41-87cc-4694-bee8-d6f2308248d4', 2, 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', '9780786809936'),
('4c7835b9-827e-4b9c-8d7e-320f9d1f6639', 5, 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', '9780977795306'),
('af420a99-eee7-48d0-b197-f1a36222ae7a', 5, 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', '9780071467445'),
('d38ec64b-8c56-4a3c-8bfa-f76aba4aa0c3', 3, 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', '9780061137037'),
('3f85cab3-ca3b-4611-8b88-b77911f99ce1', 5, 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', '9780060583316'),
('21b2badb-43e4-4ea1-8d05-207234dbf5d6', 1, 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', '9781593153571'),
('b616345f-c817-473e-9b8d-9d7a449e24b0', 0, 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', '9781593153571'),
('e59a5efb-2952-4ca8-b046-afc506249dea', 5, 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', '9780071467445'),
('94b9bd8f-bc32-43e4-9143-536112485c87', 2, 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', '9780823410774'),
('1cbb7aa7-0aa1-445c-984e-c502a82de724', 2, 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', '9781593153571'),
('2978a7ca-21eb-412e-b011-2ce02051c3fa', 1, 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', '9780823410774'),
('f8344d8b-7de6-4bfb-9021-a71e99cde209', 1, 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', '9780823410774'),
('c6ebddd3-5157-4832-bbbc-5c6c5eb426a0', 1, 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', '9780061137037'),
('f43e8c5c-e5bb-46bb-ac77-5927c4f99236', 2, 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', '9780786809936'),
('3b033c15-06ae-49b8-8126-2b37920d1117', 5, 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', '9780141187068'),
('195e12d7-3e37-4128-a1f0-be06fb4dc0a6', 3, 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', '9780977795306'),
('1728a5a2-b65b-49da-b2a3-fd66be01576f', 2, 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', '9780977795306'),
('d0b64657-9782-45b1-9799-0adb6d61ad62', 1, 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', '9780071467445'),
('4f22a3ad-e931-4fbc-8d61-d5918d78f465', 0, 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', '9780060583316'),
('c9d5e450-4ac2-456d-8781-980648f73b18', 2, 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', '9780071467445'),
('2b46686d-f61e-4350-8c83-48113b9db078', 0, 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', '9781563898419'),
('da74b60b-6d1b-4900-b0be-ecdbc45e4c91', 2, 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', '9780140389661'),
('b7ca73c6-232c-46bb-b0a1-6046b76a4e2f', 0, 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', '9780140389661'),
('381799ca-91e0-4fe1-8bbc-8fc3ab8e63d1', 5, 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', '9780786809936'),
('18c55723-520e-4ad2-aa6f-d95dc377c6df', 1, 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', '9780060583316'),
('0751c49f-767e-4d82-b50d-013a69f3afdd', 5, 'ac09eda3-f4e3-42c1-b771-2e7659a9a4ed', '9780071467445'),
('9ed6b01e-fb6a-41c1-83eb-97b78fce6a32', 4, 'ac09eda3-f4e3-42c1-b771-2e7659a9a4ed', '9780823410774'),
('5a68ec3d-1685-4c00-982d-c1d5f79b8297', 5, 'ac09eda3-f4e3-42c1-b771-2e7659a9a4ed', '9780140389661'),
('12e0a5c1-6e04-42ff-9ba9-6ae83baefed0', 2, 'ac09eda3-f4e3-42c1-b771-2e7659a9a4ed', '9780140389661'),
('848a7a83-6b0e-44ec-9db9-aa9d0549dd95', 1, 'ac09eda3-f4e3-42c1-b771-2e7659a9a4ed', '9780823410774'),
('5f3e507f-ad89-4dae-8957-46123852b3fa', 3, 'ac09eda3-f4e3-42c1-b771-2e7659a9a4ed', '9780977795306'),
('97be3d98-8ea1-40bc-a978-fdcc1b5cee4f', 3, 'ac09eda3-f4e3-42c1-b771-2e7659a9a4ed', '9781563898419'),
('d90bbf93-0ab0-4c78-a5df-3f6a8610d74a', 5, 'ac09eda3-f4e3-42c1-b771-2e7659a9a4ed', '9780140389661'),
('af5fe33d-de67-4b0c-b950-f053f13da400', 2, 'ac09eda3-f4e3-42c1-b771-2e7659a9a4ed', '9780060583316'),
('3352fbc6-ebc5-4a15-8646-c77ce5761eb7', 1, 'ac09eda3-f4e3-42c1-b771-2e7659a9a4ed', '9781593153571'),
('30214078-461c-48fe-9a1b-f606b0e7ccb0', 3, 'ac09eda3-f4e3-42c1-b771-2e7659a9a4ed', '9780977795306'),
('0261bf49-2a95-4351-8475-8f26c9779b65', 3, 'ac09eda3-f4e3-42c1-b771-2e7659a9a4ed', '9780060583316'),
('329e401f-84b3-4a1d-a819-9ac34cf898a7', 3, 'ac09eda3-f4e3-42c1-b771-2e7659a9a4ed', '9780141187068'),
('e4ba5252-3ce4-4bb5-a100-99de5b4ee381', 1, 'ac09eda3-f4e3-42c1-b771-2e7659a9a4ed', '9780071467445'),
('99d746db-3bb9-47a0-9e3e-f64a88d9b8d4', 2, 'ac09eda3-f4e3-42c1-b771-2e7659a9a4ed', '9780071467445'),
('eb4448c4-ac6e-47f3-a912-c7ac6a816374', 0, 'ac09eda3-f4e3-42c1-b771-2e7659a9a4ed', '9780060583316'),
('b0cffb4e-e7dc-4534-8aed-763b7620aa26', 2, 'ac09eda3-f4e3-42c1-b771-2e7659a9a4ed', '9780977795306'),
('458cc258-fd9a-4480-a3d0-5c53dea860c4', 2, 'ac09eda3-f4e3-42c1-b771-2e7659a9a4ed', '9780140389661'),
('1b35e023-1620-44e8-9c8f-b2bd84518b10', 3, 'ac09eda3-f4e3-42c1-b771-2e7659a9a4ed', '9780823410774'),
('234478d4-bcb6-48fc-9c1a-20d1b88567c4', 2, '7525e1f9-8e1a-45ac-815f-2a1018b06fe3', '9781593153571'),
('a494d9e9-a636-4005-90e3-b52540bc17c7', 3, '7525e1f9-8e1a-45ac-815f-2a1018b06fe3', '9780140389661'),
('9ca3488e-82bf-43ba-aef6-82a7ff576736', 5, '7525e1f9-8e1a-45ac-815f-2a1018b06fe3', '9780141187068'),
('caab0e89-4a27-458e-8ffd-fdfd024446de', 2, '7525e1f9-8e1a-45ac-815f-2a1018b06fe3', '9780140389661'),
('74cebd83-af3c-467a-842c-dcd1b86ee2cd', 2, '7525e1f9-8e1a-45ac-815f-2a1018b06fe3', '9780071467445'),
('fdbfa8b6-e1cf-4409-8f30-d187fa438d18', 4, '7525e1f9-8e1a-45ac-815f-2a1018b06fe3', '9781593153571'),
('c218082d-7f33-4e7b-83ef-3968fe5487e7', 2, '7525e1f9-8e1a-45ac-815f-2a1018b06fe3', '9780061137037'),
('0bbe1cf0-2780-462e-a52a-58673a0b74b1', 2, '7525e1f9-8e1a-45ac-815f-2a1018b06fe3', '9781563898419'),
('696b053a-0879-4f3f-8385-86bc3bb1525b', 1, '7525e1f9-8e1a-45ac-815f-2a1018b06fe3', '9780071467445'),
('88d2d771-4539-49fc-9c40-9dbf45dfff00', 0, '7525e1f9-8e1a-45ac-815f-2a1018b06fe3', '9780060583316'),
('fdc8b702-a412-453a-9150-00be513aa681', 2, '7525e1f9-8e1a-45ac-815f-2a1018b06fe3', '9780977795306'),
('323f48f2-57c4-4b9e-bd1b-1e5c5da3e632', 5, '7525e1f9-8e1a-45ac-815f-2a1018b06fe3', '9780141187068'),
('7cb36635-b07f-4967-a505-d03b2ddb387e', 4, '7525e1f9-8e1a-45ac-815f-2a1018b06fe3', '9780140389661'),
('44b6148d-aa2d-49ed-bd65-2dcb07df16e4', 1, '7525e1f9-8e1a-45ac-815f-2a1018b06fe3', '9781563898419'),
('fbcaaefc-0c72-4ab6-9eb1-74dfcac31238', 0, '7525e1f9-8e1a-45ac-815f-2a1018b06fe3', '9781593153571'),
('689d5eea-761b-413d-bc5d-6eb280dbaf9a', 2, '7525e1f9-8e1a-45ac-815f-2a1018b06fe3', '9781593153571'),
('79b31111-9669-442e-ba84-f318d89eea1d', 4, '7525e1f9-8e1a-45ac-815f-2a1018b06fe3', '9780071467445'),
('2c72f6bf-a09f-48ab-bd35-9f38b01086ee', 5, '7525e1f9-8e1a-45ac-815f-2a1018b06fe3', '9780141187068'),
('02dddde4-65e8-4c48-8e4b-8a698121fcf5', 2, '7525e1f9-8e1a-45ac-815f-2a1018b06fe3', '9780071467445'),
('ed1758a3-3ca7-4711-8c7e-b556ac4f501a', 4, '7525e1f9-8e1a-45ac-815f-2a1018b06fe3', '9780071467445'),
('c60ac05a-2981-494e-870b-6eb5f28f3d3e', 2, '7525e1f9-8e1a-45ac-815f-2a1018b06fe3', '9780060583316'),
('62b10221-f7ab-467e-bf0e-7dc5ef6cf0fc', 3, '7525e1f9-8e1a-45ac-815f-2a1018b06fe3', '9780060583316'),
('5612d6dc-0430-4a75-8b4f-3be7d33ee16e', 3, '7525e1f9-8e1a-45ac-815f-2a1018b06fe3', '9780823410774'),
('3f00eeb4-2544-4f5f-a0ce-e22981bc3bf8', 5, 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8', '9780141187068'),
('fac806fe-552b-429b-82a6-3a355d8e0c97', 4, 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8', '9781563898419'),
('7559a66d-ec31-4f74-b185-56d3d24639e9', 0, 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8', '9781593153571'),
('8e1852c4-406e-4ef1-a17c-bafbc40e6e64', 4, 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8', '9780977795306'),
('918044a5-f30a-4720-8329-748faa198030', 2, 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8', '9780977795306'),
('84990bba-e2a2-4029-a861-f129fdc45a52', 3, 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8', '9780061137037'),
('35e889d3-acca-4164-843d-a448a9ae1c82', 4, 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8', '9780060583316'),
('27785e65-52ba-44eb-b023-83e7b9d165be', 1, 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8', '9780786809936'),
('69411cfc-9530-42b4-928a-183c7bbf831a', 4, 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8', '9780977795306'),
('47090ae9-dcdf-4f45-a7b5-bb312ac25718', 3, 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8', '9780823410774'),
('e0e2917c-d245-44eb-8fda-0cfe6267261b', 1, 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8', '9781593153571'),
('d0d80e31-cfd2-4e86-85d2-de2cfedccd3e', 5, 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8', '9780060583316'),
('6749df12-106e-4e2d-b394-f31469097e5e', 4, 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8', '9780977795306'),
('4105e419-6495-41e5-85b3-c5fcc71eabc8', 5, 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8', '9780141187068'),
('2ced3986-1d16-4ebb-813b-0976d9b328db', 5, 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8', '9781563898419'),
('792a53c4-5149-4b43-9a38-8e7f8bf508b2', 1, 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8', '9780977795306'),
('d698dc10-8f36-4d8d-9314-e43edefee9ac', 4, 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8', '9781563898419'),
('b5ebd860-ba78-4cc3-8512-436edc9057d9', 0, 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8', '9780061137037'),
('5093f016-edc8-4267-943d-f98c22627454', 4, 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8', '9780060583316'),
('ea51e15d-4771-4adf-97c6-861f724322af', 5, 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8', '9780071467445');

INSERT INTO Review (RvwCode, Text, UserCode, ISBN13) VALUES
('f268e1b3-469d-48c9-9d6e-87a7dacfb7fb', 'An intriguing and thought-provoking read that kept me hooked from start to finish.', 'cc9a201f-d042-4e05-9c45-a0dbcde6154c', '9780061137037'),
('3f90ba82-a054-4993-b3ee-8f6358012616', 'A heartwarming and uplifting tale of resilience and hope. A celebration of the human spirit.', 'cc9a201f-d042-4e05-9c45-a0dbcde6154c', '9780061137037'),
('4ede1926-c99e-4790-a81b-c165002e8137', 'A haunting and atmospheric story that lingers in the mind long after the last page. A literary masterpiece.', '16361ee3-294d-4a6a-93da-1e7fe93f9165', '9780141187068'),
('44532749-cacc-4b0a-945c-95351ae070eb', 'A haunting and atmospheric story that lingers in the mind long after the last page. A literary masterpiece.', 'f0a9ade6-81d5-4fd7-a8b2-b9fb22bb51e5', '9780060583316'),
('d557ba47-62dd-422f-a339-041717bdf767', 'A mesmerizing and lyrical novel that transports readers to a different time and place. I was captivated by the prose.', '56a543cf-3c9c-4ea8-bcb0-a3c6f91c3fe0', '9780786809936'),
('9479425e-9e81-4a80-9911-eb5f53ae2079', 'A beautifully written book that tugs at the heartstrings. A must-read for any book lover.', '0abcbe33-d00f-427e-aec6-a99783a68f3f', '9780823410774'),
('2d64663a-5ae0-4c70-85e9-f550e73d0e75', 'A thrilling and suspenseful mystery with well-drawn characters and a cleverly crafted plot. Highly recommended for fans of the genre.', '0abcbe33-d00f-427e-aec6-a99783a68f3f', '9780823410774'),
('2ce73ff8-daaa-4c77-b17b-bc954ca35313', 'An epic and sweeping saga that spans generations. A masterful work of historical fiction.', 'f99bc944-c10e-4ca4-8bab-bfca3ed01185', '9780060583316'),
('133eb05c-0650-49de-acea-a6b8709ffe5d', 'An enchanting and magical book that swept me away to a different world. A true gem.', 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', '9780141187068'),
('5ee5dfc3-829f-4624-a360-abffc3097cb9', 'A beautifully written and emotionally resonant tale that will stay with me for a long time.', 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', '9780071467445'),
('93a8979a-86b8-47d1-b108-6671cef6f7cd', 'A thrilling and suspenseful mystery with well-drawn characters and a cleverly crafted plot. Highly recommended for fans of the genre.', 'ac09eda3-f4e3-42c1-b771-2e7659a9a4ed', '9780141187068'),
('0c967600-0f9c-46f2-8985-7fe45cbddc16', 'A heartwarming story of love, loss, and redemption. Poignant and beautifully written.', 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8', '9781563898419'),
('c39124d6-5902-4b9d-860c-fd0aa59f842e', 'A thrilling and suspenseful mystery with well-drawn characters and a cleverly crafted plot. Highly recommended for fans of the genre.', 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8', '9780060583316');

INSERT INTO BookshelfBook (BookshelfBookCode, BookStatus, UserCode, ISBN13) VALUES
('b3ae75d6-8ba5-4c7f-b630-82b547a8b86e', 'Reading', 'cc9a201f-d042-4e05-9c45-a0dbcde6154c', '9780141187068'),
('bf34a6f5-ab33-4862-bc2a-f21f6cef1c5e', 'Read', 'cc9a201f-d042-4e05-9c45-a0dbcde6154c', '9780061137037'),
('fc718337-dba7-45d6-a7db-0c93a10e82b3', 'Want To Read', '16361ee3-294d-4a6a-93da-1e7fe93f9165', '9781563898419'),
('2796f3a1-a938-4926-9574-fac573aa8c1a', 'Want To Read', 'f0a9ade6-81d5-4fd7-a8b2-b9fb22bb51e5', '9780823410774'),
('a1a2e2ea-7006-4d0a-85b6-23f7eff0143e', 'Read', 'f0a9ade6-81d5-4fd7-a8b2-b9fb22bb51e5', '9780140389661'),
('d81eca3e-dcc9-45e6-97be-bcaa97ba752b', 'Want To Read', 'f0a9ade6-81d5-4fd7-a8b2-b9fb22bb51e5', '9780061137037'),
('aa1d0940-d694-4a7a-be87-161895886e9e', 'Want To Read', '56a543cf-3c9c-4ea8-bcb0-a3c6f91c3fe0', '9780061137037'),
('5166647d-6c85-441c-b596-52e943c049dc', 'Read', '56a543cf-3c9c-4ea8-bcb0-a3c6f91c3fe0', '9781563898419'),
('a4413401-e01a-4fa9-b812-f3a4c2ce03e8', 'Read', '56a543cf-3c9c-4ea8-bcb0-a3c6f91c3fe0', '9780060583316'),
('eb6a1208-5af3-45ed-b5df-cd88e175c632', 'Read', '0abcbe33-d00f-427e-aec6-a99783a68f3f', '9781563898419'),
('88d41c0a-c139-4f29-978f-e3cb3fe0c82c', 'Reading', '0abcbe33-d00f-427e-aec6-a99783a68f3f', '9780786809936'),
('c46b9b20-e64b-4ce3-a98a-0436a08ff89a', 'Read', '0abcbe33-d00f-427e-aec6-a99783a68f3f', '9780060583316'),
('32c6da7e-37b4-4761-a54f-92d8e649e03f', 'Reading', '0abcbe33-d00f-427e-aec6-a99783a68f3f', '9780060583316'),
('72632514-939d-499a-a7a1-b060c01fb20f', 'Reading', '0abcbe33-d00f-427e-aec6-a99783a68f3f', '9780061137037'),
('feef4e01-1744-47f4-aa7a-52ce7b7f963b', 'Want To Read', 'f99bc944-c10e-4ca4-8bab-bfca3ed01185', '9780060583316'),
('be147eed-106f-4819-8030-939c2645afd3', 'Read', 'f99bc944-c10e-4ca4-8bab-bfca3ed01185', '9780061137037'),
('739a57b9-0a32-4af4-9890-3f323ff87f48', 'Want To Read', 'ac09eda3-f4e3-42c1-b771-2e7659a9a4ed', '9780071467445'),
('0e4cfc7f-8ad0-46f1-93cb-a1e8522eec0e', 'Reading', 'ac09eda3-f4e3-42c1-b771-2e7659a9a4ed', '9781593153571'),
('dcc53020-e231-4e6e-8f9b-509edde320ef', 'Want To Read', 'ac09eda3-f4e3-42c1-b771-2e7659a9a4ed', '9780977795306'),
('128fdf26-d145-490a-bbae-282dc333acf0', 'Read', '7525e1f9-8e1a-45ac-815f-2a1018b06fe3', '9780140389661'),
('b760e71b-c052-4598-85b7-d5e86e62d15d', 'Reading', '7525e1f9-8e1a-45ac-815f-2a1018b06fe3', '9780061137037'),
('123dffbb-14f1-41ca-8fd1-d65be2264f09', 'Read', '7525e1f9-8e1a-45ac-815f-2a1018b06fe3', '9780140389661'),
('cc93fa8e-17b5-4079-ae3c-364327ffeac9', 'Want To Read', '7525e1f9-8e1a-45ac-815f-2a1018b06fe3', '9780141187068'),
('a6bfb309-8aa7-45b7-9885-13172a9ab8b5', 'Read', 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8', '9780823410774'),
('b5a0a38e-37dc-4ead-a427-a4c1ec0e9842', 'Reading', 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8', '9780977795306'),
('6d24885a-1b93-4714-8c20-e0b30c8deeca', 'Want To Read', 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8', '9780823410774');

INSERT INTO Follows (FlwCode, UserACode, UserBCode) VALUES
('838bd1e4-1e95-4f93-9ced-9af0139cdfc9', 'cc9a201f-d042-4e05-9c45-a0dbcde6154c', 'f0a9ade6-81d5-4fd7-a8b2-b9fb22bb51e5'),
('57ff00be-dca0-443e-b3e9-6aacc6fb7b4a', 'cc9a201f-d042-4e05-9c45-a0dbcde6154c', '0abcbe33-d00f-427e-aec6-a99783a68f3f'),
('7bb3e0ad-7026-4539-afb6-32ca0dea8563', 'cc9a201f-d042-4e05-9c45-a0dbcde6154c', 'f99bc944-c10e-4ca4-8bab-bfca3ed01185'),
('6a692ca4-3d82-4adc-b08e-2e73e969cd26', 'cc9a201f-d042-4e05-9c45-a0dbcde6154c', 'ace782b9-f45d-4981-9ac8-b2ac72549cd7'),
('1b06b5c5-193c-4a67-9c17-78b664a40c2b', 'cc9a201f-d042-4e05-9c45-a0dbcde6154c', 'ac09eda3-f4e3-42c1-b771-2e7659a9a4ed'),
('6daa88b8-f16c-4dee-841a-2dae413ce194', 'cc9a201f-d042-4e05-9c45-a0dbcde6154c', '7525e1f9-8e1a-45ac-815f-2a1018b06fe3'),
('fc9eca0d-fb7b-4816-b5f4-1f5829160b9f', '16361ee3-294d-4a6a-93da-1e7fe93f9165', 'cc9a201f-d042-4e05-9c45-a0dbcde6154c'),
('0bd1c576-e6a1-4c98-8b5a-ba73bfb6ab45', '16361ee3-294d-4a6a-93da-1e7fe93f9165', 'f0a9ade6-81d5-4fd7-a8b2-b9fb22bb51e5'),
('4048acf6-5a06-4987-b88d-c30717e732f8', '16361ee3-294d-4a6a-93da-1e7fe93f9165', '56a543cf-3c9c-4ea8-bcb0-a3c6f91c3fe0'),
('6321a2a3-d414-4c5b-adf2-eb536c9f77fa', '16361ee3-294d-4a6a-93da-1e7fe93f9165', 'ace782b9-f45d-4981-9ac8-b2ac72549cd7'),
('b2682887-da6c-47d9-878e-9a5a396532aa', '16361ee3-294d-4a6a-93da-1e7fe93f9165', '7525e1f9-8e1a-45ac-815f-2a1018b06fe3'),
('6e719d12-925a-4022-af80-e760539a6402', 'f0a9ade6-81d5-4fd7-a8b2-b9fb22bb51e5', 'cc9a201f-d042-4e05-9c45-a0dbcde6154c'),
('e6501b53-ccbd-411c-a78d-2cf9c0ff6367', 'f0a9ade6-81d5-4fd7-a8b2-b9fb22bb51e5', 'ace782b9-f45d-4981-9ac8-b2ac72549cd7'),
('b78d2875-f105-44b8-97b9-63c26c0ffc72', 'f0a9ade6-81d5-4fd7-a8b2-b9fb22bb51e5', '7525e1f9-8e1a-45ac-815f-2a1018b06fe3'),
('5e833c3c-68f9-4880-94ee-9c3cad609f5c', '56a543cf-3c9c-4ea8-bcb0-a3c6f91c3fe0', '16361ee3-294d-4a6a-93da-1e7fe93f9165'),
('5d6fe24b-a967-4156-aa86-d0282af91446', '56a543cf-3c9c-4ea8-bcb0-a3c6f91c3fe0', 'f0a9ade6-81d5-4fd7-a8b2-b9fb22bb51e5'),
('acdd3570-17fc-4d85-b45a-f9ed54f388aa', '0abcbe33-d00f-427e-aec6-a99783a68f3f', 'cc9a201f-d042-4e05-9c45-a0dbcde6154c'),
('08b49c36-72cb-4a12-80ce-112c2f2365e0', '0abcbe33-d00f-427e-aec6-a99783a68f3f', '56a543cf-3c9c-4ea8-bcb0-a3c6f91c3fe0'),
('bc8f664f-f077-4c89-b2fd-a6b9252cf6a4', '0abcbe33-d00f-427e-aec6-a99783a68f3f', 'f99bc944-c10e-4ca4-8bab-bfca3ed01185'),
('735b980b-ee60-497b-9a53-947d2febc4a7', '0abcbe33-d00f-427e-aec6-a99783a68f3f', 'ace782b9-f45d-4981-9ac8-b2ac72549cd7'),
('2d5d93d3-b1e3-464b-95a1-dc62c2cf6ff7', '0abcbe33-d00f-427e-aec6-a99783a68f3f', '7525e1f9-8e1a-45ac-815f-2a1018b06fe3'),
('72c1fbd0-6244-45b5-87b8-97f874f20d4c', '0abcbe33-d00f-427e-aec6-a99783a68f3f', 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8'),
('3bb14f08-21d8-4f13-aa0d-97f854c29f14', 'f99bc944-c10e-4ca4-8bab-bfca3ed01185', 'cc9a201f-d042-4e05-9c45-a0dbcde6154c'),
('403ba9e3-959e-4023-be18-3a9fa0464789', 'f99bc944-c10e-4ca4-8bab-bfca3ed01185', 'f0a9ade6-81d5-4fd7-a8b2-b9fb22bb51e5'),
('60bbb709-3324-4e55-9927-b80f9c475cbc', 'f99bc944-c10e-4ca4-8bab-bfca3ed01185', '0abcbe33-d00f-427e-aec6-a99783a68f3f'),
('29cd6255-26e8-4c50-ab37-db3458f2a8e0', 'f99bc944-c10e-4ca4-8bab-bfca3ed01185', '7525e1f9-8e1a-45ac-815f-2a1018b06fe3'),
('c1ef56cf-b591-4ec0-8ef8-21b654efc22e', 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', 'f99bc944-c10e-4ca4-8bab-bfca3ed01185'),
('d5a65ecf-f21d-46cb-b9e2-3f4907155752', 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', 'ac09eda3-f4e3-42c1-b771-2e7659a9a4ed'),
('3b44758b-79cb-44b5-927d-2061f7710369', 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', '7525e1f9-8e1a-45ac-815f-2a1018b06fe3'),
('cbbd1664-d5b2-4176-a813-1e7c99025b26', 'ace782b9-f45d-4981-9ac8-b2ac72549cd7', 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8'),
('eb638b48-5474-49e7-96b0-a2686e21b1b8', 'ac09eda3-f4e3-42c1-b771-2e7659a9a4ed', 'cc9a201f-d042-4e05-9c45-a0dbcde6154c'),
('885c7a27-de73-4f52-b90f-1f1d07f40f46', 'ac09eda3-f4e3-42c1-b771-2e7659a9a4ed', '0abcbe33-d00f-427e-aec6-a99783a68f3f'),
('abd1e0ef-1415-4a99-b7f6-38d1c48f0baa', 'ac09eda3-f4e3-42c1-b771-2e7659a9a4ed', 'f99bc944-c10e-4ca4-8bab-bfca3ed01185'),
('72d7aa1a-29ee-44f5-a101-9b2797948aa3', 'ac09eda3-f4e3-42c1-b771-2e7659a9a4ed', 'ace782b9-f45d-4981-9ac8-b2ac72549cd7'),
('57f19dac-62ab-422e-a416-43c9f2f00891', 'ac09eda3-f4e3-42c1-b771-2e7659a9a4ed', '7525e1f9-8e1a-45ac-815f-2a1018b06fe3'),
('156c0d90-4421-4954-ae12-fc13abdb82aa', '7525e1f9-8e1a-45ac-815f-2a1018b06fe3', 'f0a9ade6-81d5-4fd7-a8b2-b9fb22bb51e5'),
('6017d901-0691-4856-bbb6-22ca7cbec1da', '7525e1f9-8e1a-45ac-815f-2a1018b06fe3', 'ace782b9-f45d-4981-9ac8-b2ac72549cd7'),
('37cfbd27-6c74-4662-a838-cd902c45bc5a', '7525e1f9-8e1a-45ac-815f-2a1018b06fe3', 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8'),
('348dc87b-e9f4-4563-88b6-a5094df6c692', 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8', 'cc9a201f-d042-4e05-9c45-a0dbcde6154c'),
('94041de4-7eba-4f53-b592-88e1152967f6', 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8', '16361ee3-294d-4a6a-93da-1e7fe93f9165'),
('9e76adcc-5bc5-44f6-bc57-302869274d11', 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8', '0abcbe33-d00f-427e-aec6-a99783a68f3f'),
('702f617b-8ffa-494d-92b8-2997808ef92f', 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8', 'f99bc944-c10e-4ca4-8bab-bfca3ed01185'),
('93125340-8bf0-44de-85e1-0b44209937f2', 'e0bc0f2d-30d4-44d0-adcd-81a5ca5853f8', 'ace782b9-f45d-4981-9ac8-b2ac72549cd7');

