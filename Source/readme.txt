Greetings!

Aquasoft joyfully offers to you the DROP, a framework developed to encourage developers to study and use the full potential of Delphi Object Orientation.

The DROP is open source. It means that, keeping the 
Aquasoft authoring, you can use the DROP for any type of project.

Description of DROP packages:
  - Core: contains generic libraries such as basic types, collections,
pattenrs, between other classes;
  - DB: contains generic classes wich provides the basic interface to communicate with DBMSs, such as connection classes, and ORM;
  - DBX: contains class specializations needed to comunicate with DBMSs using the DBX framework;
  - FD: contains class specializations needed to comunicate with DBMSs torugh FireDAC components;
  - Register: Design time package to register the Drop in the IDE.

To install the DROP:
  - Open the project group designed for your Delphi version (e.g. AqDrop.DXE5.groupproj is the group for Delphi XE5);
  - Add the folders containing the runtime units to your Library Path (Folders Core and DB);
  - Execute a 'Build All' command;
  - Install the Register package.

IMPORTANT NOTES:
  - The Drop is provided 'As Is', it means that Aquasoft is not responsible for any problems arising from the use of Drop, and has no obligations to implement / modify the tool to adapt it to any user scenario;
  - In theory, the source code is compatible with Delphi XE3, but we give official support (by unit tests) only to Delphi XE4 and newer versions; 
  - The Drop offers specialized classes for connections to MSSQL, MySQL, Firebird, Oracle and Postgres (the last one only by FireDAC). Our roadmap includes tasks to provide support to Interbase and SQLite;
  - Packages for using DROP in Delphi XE8 were included in version 1.2, but, we're having problems while compiling the packages (we have a QC opened to verify it). If you don't use BPLs to modularize your applications, this problem will not cause any effect, because the inclusion of the source code (in your project or library path) will provide the normal behavior of the framework (guaranteed by unit tests performed in XE8);
  - Stay up to date about the DROP checking our twitter and
facebook: AquasoftTI.

And, thank you for using DROP!

Aquasoft Team


Aquasoft IT
Embarcadero partner in south Brazil
drop@aquasoft.com.br
www.aquasoft.com.br
twitter.com/AquasoftTI
facebook.com/AquasoftTI
Phone: +55 (51) 3022-3188


VERSION HISTORY:
----------------------------------------
2015.07.14: Drop 1.2.0:
- Support to Delphi XE7 and XE8;
- Creation of specialized classes to comunicate trough FireDAC components;
- Support to Oracle (by DBX and FD);
- Support to Postgres (only by FD);
- Creation of basic structure to inherit and automatize ORM tasks (including object cache);
- Attributes to better handle of nullable fields;
- Hundresd of improvments and small bug fixes;
----------------------------------------
2014.04.16: Drop 1.0.1:
- Binding support for result lists;
- Some uints were revised and standardized;
- New methods in interfaces and it respectives classes;
- Small improvments and bug fixes;
- Added demo MappingAndBinding;
- Added packages to support Delphi XE6;
----------------------------------------
2014.04.02: Drop 1.0.1!
----------------------------------------