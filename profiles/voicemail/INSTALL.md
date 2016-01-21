Brief instructions for setting up the default 'voicemail' profile.  They
assume you already have Jester installed correctly:

1. Create a  database.

2. Use the included 'voicemail.sql' file to create the necessary tables in the
   new database.  Currently only MySQL tables are provided, patches welcome
   for other databases.

   NOTE: table structure is totally subject to change in future releases,
   you're on your own with that for now!

3. Create an ODBC resource to connect to the database.  See the data module's
   'Handlers -> odbc' section in the Jester help for more information.

4. If necessary, edit the database configuration settings in
   'profiles/voicemail/conf.lua'

5. Download the Asterisk core sounds and place them in a subdirectory of the
   FreeSWITCH 'sounds' directory.

6. From within the Asterisk sounds directory, create a symlink from the digits
   directory to 'time'.  If you're on a Linux/Unix system this should do it:

     ```
     ln -s digits time
     ```

   This step is necessary for FreeSWITCH's say engine to properly find the
   correct Asterisk sound files.

7. Edit the 'conf/lang/en/en.xml' file to point at the Asterisk sounds, and
   the 'phrases.xml' file found in this profile.  If your sounds are located at
   'sounds/asterisk', then the configuration would look something like this:
     ```xml
     <include>
       <language name="en" sound-path="$${sounds_dir}/asterisk">
         <phrases>
           <macros>
             <X-PRE-PROCESS cmd="include" data="$${base_dir}/scripts/jester/profiles/voicemail/phrases.xml"/>
           </macros>
         </phrases>
       </language>
     </include>
     ```

8. Call Jester from the dialplan, passing the voicemail profile as the first
   argument, the sequence to call as the second argument, and optional
   arguments for the sequence as the third argument -- see
   'Intro -> Running Jester' and 'Sequences -> Passing arguments'
   in the Jester help for more information. The 'example_dialplan.xml' included
   with the profile illustrates how to set up the extensions, check it out for
   usage info.

9. The voicemail profile fires three types of events:
     new_message:
       Fired when a new message is stored in a mailbox.
     mailbox_updated:
       Fired when the user updates mailbox settings (currently only password
       updates).
     messages_checked:
       Fired after a user checks their messages.

   You can register for these events as follows:

     event plain CUSTOM jester::new_message jester::mailbox_updated jester::messages_checked

