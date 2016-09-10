Greetings!

The Aquasoft joyfully offers to you the DROP, a framework developed to
encourage developers to study and use the full potential of Delphi Object Orientation.

The DROP is open source. It means that, keeping the 
Aquasoft authoring, you can use the DROP for any type of project.

Description of DROP packages:
  - Core: Contains generic libraries such as basic types, collections,
pattenrs, between other classes;
  - DB: Contains specific classes to communicating with DBMSs, such as connection classes, and an ORM;
  - Register: Design time package to register the Drop in the IDE.

To install the DROP:
  - Open the project group designed for your Delphi version (e.g. AqDrop.DXE5.groupproj is the group for Delphi XE5);
  - Add the folders containing the runtime units to yout Library Path (Folders Core and DB);
  - Execute a build all;
  - Install the Register package.

IMPORTANT NOTES:
  - The Drop is provided 'As Is', it means that Aquasoft is not responsible for any problems arising from the use of Drop, and has no obligations to implement / modify the tool to adapt it to any user scenario;
  - The warnings raised during the compilation of the packages should be
disregarded, because it does not happen when the classes are used in DPRs;
  - The Drop is not compatible with earlier versions than Delphi XE3;
  - The Drop offers specialized classes for connections to MSSQL, MySQL and
Firebird. However, the Drop connects to any DBMS supported by DBX;
  - Our TODO list contains tasks such as creating specialized classes
for connecting to Oracle and create new classes based on FireDAC;
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