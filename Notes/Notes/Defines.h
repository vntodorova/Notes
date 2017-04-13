//
//  Defines.h
//  Notes
//
//  Created by Nemetschek A-Team on 3/30/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#ifndef Defines_h
#define Defines_h

#define BUTTONS_HEIGHT 25
#define BUTTONS_WIDTH 25

#define SMALL_BUTTONS_WIDTH 45
#define SMALL_BUTTONS_HEIGHT 45
#define SMALL_BUTTON_DISTANCE 60

#define TABLEVIEW_CELL_ID @"TableViewCell"
#define TABLEVIEW_CELL_HEIGHT 70

#define LEFT_PANEL_NIBNAME @"LeftPanelViewController"
#define SETTINGS_PANEL_NIBNAME @"SettingsPanelViewController"
#define NOTE_CELL_ID @"NoteCell"
#define NOTEBOOK_CELL_ID @"NotebookCell"
#define REMINDER_CELL_ID @"ReminderCell"

#define CELL_DRAG_ACTIVATION_DISTANCE 70

#define MOVE_DIRECTION_UP 1
#define MOVE_DIRECTION_DOWN 2

#define LEFT_PANEL_WIDTH 250

#define NOTEBOOKS_SECTION 0
#define REMINDERS_SECTION 1

#define NOTEBOOK_KEY @"Notebook"
#define REMINDER_KEY @"Reminder"

#define NOTEBOOK_SECTION_NAME @"Notebooks"
#define REMINDERS_SECTION_NAME @"Reminders"

#define TABLEVIEW_SECTIONS_NUMBER 2

#define NOTE_CREATED_EVENT @"NoteCreatedEvent"

#define NOTE_NOTEBOOKS_FOLDER @"Notebooks"
#define TEMP_FOLDER @"Temp"
#define EMPTY_FILE_NAME @"emptyfile.html"

#define NOTE_BODY_FILE @"body.html"
#define NOTE_TAGS_FILE @"tags.txt"
#define NOTE_DATE_FILE @"date.txt"

#define SEARCH_BAR @"SearchBar"
#define TABLEVIEW_BACKGROUND_COLOR @"TableViewBackgroundColor"
#define TABLEVIEW_CELL_COLOR @"TableViewCellColor"
#define BACKGROUND_COLOR @"BackgroundColor"
#define NAVIGATION_BAR_COLOR @"NavigationBarColor"
#define TINT @"Tint"
#define TEXTFIELDS_COLOR @"TextFieldsColor"
#define CAMERA_IMAGE @"CameraImage"
#define LIST_IMAGE @"ListImage"
#define DRAWING_IMAGE @"DrawingImage"

#define UNNAMED_NOTE @"Unnamed"
#define PUBLIC_IMAGE_IDENTIFIER @"public.image"
#define DEFAULT_IMAGE_HTML @"<img src=\"%@\" alt=\"\" style=\"width:150;height:150;\">"
#define START_OF_IMAGE_HTML @"<img src=\""
#define TIME_DATE_FORMAT @"HH:mm:ss, dd-MM-yyyy"

#define TAG_SEPARATION_INDICATORS @"# "

#define REDACTATION_BUTTON_NAME @"Save"

#define JS_COMMAND_GET_HTML @"document.documentElement.outerHTML"
#define JS_COMMAND_UNDERLINE @"document.execCommand(\"Underline\")"
#define JS_COMMAND_ITALIC @"document.execCommand(\"Italic\")"
#define JS_COMMAND_BOLD @"document.execCommand(\"Bold\")"
#define JS_COMMAND_CENTER @"document.execCommand(\"justifyCenter\")"

#define JS_COMMAND_INSERT @"document.execCommand(\"insertText\",false,\"ASD\")"

#define JS_COMMAND_FONT_TYPE @"document.execCommand('fontName', false, '%@')"
#define JS_COMMAND_FONT_SIZE @"document.execCommand('fontSize', false, '%@')"

#define ALERT_DIALOG_TITLE @"CHOOSE NOTEBOOK"
#define ALERT_DIALOG_CANCEL_BUTTON_NAME @"Cancel"

#define ALERT_INPUT_DIALOG_TITLE @"Create new"
#define ALERT_INPUT_DIALOG_MESSAGE @"Enter a name"
#define ALERT_INPUT_DIALOG_CONFIRM_BUTTON_NAME @"OK"
#endif /* Defines_h */
