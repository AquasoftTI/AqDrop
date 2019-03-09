Greetings!

We joyfully offers to you the Aquasoft DROP, a framework developed to encourage developers to study and use the full potential of Delphi Object Orientation.

The DROP is open source. It means that, keeping the 
Aquasoft authoring, you can use the DROP for any type of project.

Description of DROP packages:
  - Core: contains generic libraries such as basic types, collections,
pattenrs, between other classes;
  - DB: contains generic classes wich provides the basic interface to communicate with DBMSs, such as connection classes, and ORM;
  - DBX: contains class specializations needed to comunicate with DBMSs using the DBX framework;
  - FD: contains class specializations needed to comunicate with DBMSs torugh FireDAC components;
  - Register: Design time package to register the Drop in the IDE.

DROP doesn't need to be installed in the IDE, just add the DROP source codes to your project. But if you want to register the DROP in Delphi, just follow these steps: 
  - Add the folders containing the runtime units to your Library Path (Folders Core and DB);
  - Open the project group designed for your Delphi version (e.g. AqDrop.DXE5.groupproj is the group for Delphi XE5);
  - Execute a 'Build All' command;
  - Install the Register package.

IMPORTANT NOTES:
  - To speed up the release, the version 1.4 of DROP is being published without updating the RT and DT packages. We expecto to update the packages as soon as possible, as well to create the packages for Delphi Rio (10.3). If you don't use packages to modularize your apllication, you will not be affected. However, if youu need the updated packages for your projects, catact tatu@taturs.com and we will hurry up the process and deliver to you the necessary packages;
  - The Drop is provided 'As Is', it means that Aquasoft is not responsible for any problems arising from the use of Drop, and has no obligations to implement / modify the tool to adapt it to any user scenario;
  - In theory, the source code is compatible with Delphi XE3, but we give official support (by unit tests) only to Delphi XE4 and newer versions; 
  - The Drop offers specialized classes for connections to Interbase, MSSQL, MySQL, Firebird, Oracle, SQLite and Postgres (the last one only by FireDAC). Fell free to suggest any other type of Database;
  - Packages for using DROP in Delphi XE8 were included in version 1.2, but, a regression generetad a problem with it compilation, this regression was corrected in the newer versions. If you don't use BPLs to modularize your applications, this problem will not cause any effect, because the inclusion of the source code (in your project or library path) will provide the normal behavior of the framework (guaranteed by unit tests performed in XE8);
  - Stay up to date about the DROP checking our twitter and facebook: AquasoftTI.

SPECIAL THANKS TO:
  - The whole Aquasoft team and my former colleagues who helped put DROP in the right direction in ever discussion on "how can we do it better";
  - To Cesar Romero, who authorized that his REST request interfaces be copied and added to the DROP;
  - To Agros development team, which has helped a lot in the evolution of DROP;
  - And thank you for using DROP!

Carlos Agnes (Tatu) - DROP Creator
tatu@taturs.com
www.taturs.com
twitter.com/taturs


Aquasoft IT
Embarcadero partner in south Brazil
drop@aquasoft.com.br
www.aquasoft.com.br
twitter.com/AquasoftTI
facebook.com/AquasoftTI
Phone: +55 (51) 3022-3188


VERSION HISTORY:
----------------------------------------
2019.03.09: Drop 1.4:
- Improvements in automaton routines;
- Improvements in calendar / event routines;
- Several improvements in collections routines;
- New helpers, methdos and improvments to existing helpers;
- More performance in the object cloning routines, as well as control over them;
- Complete restructuring of object support routines with interfaces;
- Improvements in Tokenizer routines;
- Observer / observable pattern restructuring;
- Improvements in adapters and solvers of connections with DBMS;
- Restructuring of the base layer for ORM;
- Restructuring the connections pool;
- New: interfaces and classes to create data cursors in memory;
- New: task queues for synchronous and asynchronous execution;
- New: routines for generic data conversions;
- New: routines in fluent syntax for HTTP requests;
- New: simplified control for breaking recursive calls;
- New: more conditions supported by the SQLs abstraction layer;
- New: Select Offset support in the SQLs abstraction layer;
- New: SQLSelectSetup (Select patch) in the abstraction layer of SQLs;
- New: restructuring of the master x detail relationship support;
- Several other minor improvements and fixes!
----------------------------------------
2017.10.25: Drop 1.3.1:
- Support to Interbase;
- Small corrections and improvments;
- Hundreds of new tests implemented using the new (own) test platform;
----------------------------------------
2017.05.18: Drop 1.3.0:
- Support to Delphi 10 Berlin;
- Support to Delphi 10 Tokyo;
- Small corrections and improvments;
----------------------------------------
2015.12.28: Drop 1.2.1:
- Support to Delphi 10 Seattle;
- Support to iOS and Android;
----------------------------------------
2015.08.03: Drop 1.2.0:
- Support to Delphi XE7 and XE8;
- Creation of specialized classes to comunicate trough FireDAC components;
- Support to Oracle (by DBX and FD);
- Support to SQLite (by DBX and FD);
- Support to Postgres (only by FD);
- Creation of basic structure to inherit and automatize ORM tasks (including object cache);
- Attributes to better handle of nullable fields;
- Lots of improvments and small bug fixes;
----------------------------------------
2014.04.16: Drop 1.0.1:
- Binding support for result lists;
- Some uints were revised and standardized;
- New methods in interfaces and it respectives classes;
- Small improvments and bug fixes;
- Added demo MappingAndBinding;
- Added packages to support Delphi XE6;
----------------------------------------
2014.04.02: Drop 1.0.0!
----------------------------------------