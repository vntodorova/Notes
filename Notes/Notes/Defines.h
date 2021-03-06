//
//  Defines.h
//  Notes
//
//  Created by Nemetschek A-Team on 3/30/17.
//  Copyright © 2017 Nemetschek DreamTeam. All rights reserved.
//

#ifndef Defines_h
#define Defines_h

#pragma mark -
#pragma mark DrawingViewController
#define BUTTONS_HEIGHT 25
#define BUTTONS_WIDTH 25

#pragma mark -
#pragma mark LayoutProvider
#define HEADER_HEIGHT 30
#define HEADER_WIDTH 230
#define MARGIN 10
#define TABLEVIEW_CELL_ID @"TableViewCell"
#define NOTEBOOK_CELL_ID @"NotebookCell"
#define EDITABLE_NOTEBOOK_CELL_ID @"EditableNotebookCell"
#define REMINDER_CELL_ID @"ReminderCell"
#define SEARCH_RESULT_CELL_ID @"SearchResultCell"
#define NOTEBOOK_SECTION_NAME @"Notebooks"
#define REMINDERS_SECTION_NAME @"Reminders"
#define EDIT_BUTTON_NAME @"Edit"
#define CLOSE_IMAGE @"close"

#pragma mark -
#pragma mark ExpandingButton
#define SMALL_BUTTONS_WIDTH 45
#define SMALL_BUTTONS_HEIGHT 45
#define SMALL_BUTTON_DISTANCE 60

#pragma mark -
#pragma mark ViewController
#define TABLEVIEW_CELL_HEIGHT 70
#define LEFT_PANEL_NIBNAME @"LeftPanelViewController"
#define SETTINGS_PANEL_NIBNAME @"SettingsPanelViewController"
#define GENERAL_NOTEBOOK_NAME @"General"
#define THEME_CHANGED_EVENT @"ThemeChangedEvent"
#define NOTEBOOK_LIST_CHANGED @"NotebooksChanged"
#define NOTE_LIST_CHANGED @"NotelistChanged"
#define LEFT_PANEL_WIDTH 250

#pragma mark -
#pragma mark TableViewCell
#define CELL_DRAG_ACTIVATION_DISTANCE 70

#pragma mark -
#pragma mark LeftPanelViewController
#define NOTEBOOKS_SECTION 0
#define REMINDERS_SECTION 1
#define NOTEBOOK_KEY @"Notebook"
#define REMINDER_KEY @"Reminder"
#define SMALL_MARGIN 0.5

#pragma mark -
#pragma mark LocalNoteManager
#define NOTE_NOTEBOOKS_FOLDER @"Notebooks"
#define TEMP_FOLDER @"Temp"
#define NOTE_BODY_FILE @"body.html"
#define NOTE_TAGS_FILE @"tags.txt"
#define NOTE_TRIGGER_DATE_FILE @"triggerDate.txt"
#define PUBLIC_IMAGE_IDENTIFIER @"public.image"

#pragma mark -
#pragma mark ThemeManager
#define SEARCH_BAR @"SearchBar"
#define TABLEVIEW_BACKGROUND_COLOR @"TableViewBackgroundColor"
#define TABLEVIEW_CELL_COLOR @"TableViewCellColor"
#define BACKGROUND_COLOR @"BackgroundColor"
#define NAVIGATION_BAR_COLOR @"NavigationBarColor"
#define BUTTONS_BACKGROUND_COLOR @"ButtonsBackgroundColor"
#define TINT @"Tint"
#define ALERTCONTROLLER_TINT @"AlertControllerTint"
#define CAMERA_IMAGE @"camera"
#define LIST_IMAGE @"list"
#define DRAWING_IMAGE @"drawing"
#define LIGHT_THEME @"light"
#define DARK_THEME @"dark"
#define GREEN_THEME @"jorko's doom"
#define THEME_KEY @"theme"
#define REMINDER_IMAGE @"reminder"

#pragma mark -
#pragma mark NoteCreationController
#define TIMES_NEW_ROMAN @"Times New Roman"
#define ARIAL @"Arial"
#define FUTURA @"Futura"
#define VERDANA @"Verdana"
#define UNNAMED_NOTE @"Unnamed"
#define DEFAULT_IMAGE_HTML @"<img src=\"%@\" alt=\"\" style=\"width:150;height:150;\">"
#define SAVE_BUTTON_NAME @"Save"
#define JS_COMMAND_GET_HTML @"document.documentElement.outerHTML"
#define JS_COMMAND_UNDERLINE @"document.execCommand(\"Underline\")"
#define JS_COMMAND_ITALIC @"document.execCommand(\"Italic\")"
#define JS_COMMAND_BOLD @"document.execCommand(\"Bold\")"
#define JS_COMMAND_ALIGN_CENTER @"document.execCommand(\"justifyCenter\")"
#define JS_COMMAND_ALIGN_RIGHT @"document.execCommand(\"justifyRight\")"
#define JS_COMMAND_ALIGN_LEFT @"document.execCommand(\"justifyLeft\")"
#define JS_COMMAND_FONT_TYPE @"document.execCommand('fontName', false, '%@')"
#define JS_COMMAND_CHECKBOX @"document.execCommand('insertHTML', false, ' <input type=\"checkbox\"> <br><br> ')"
#define JS_COMMAND_FONT_SIZE @"document.execCommand('fontSize', false, '%@')"
#define ALERT_DIALOG_TITLE @"CHOOSE NOTEBOOK"
#define ALERT_DIALOG_CANCEL_BUTTON_NAME @"Cancel"
#define TOOLBAR_ALIGN_CENTER_IMAGE @"alignCenter"
#define TOOLBAR_ALIGN_RIGHT_IMAGE @"alignLeft"
#define TOOLBAR_ALIGN_LEFT_IMAGE @"alignRight"
#define ALERT_INPUT_DIALOG_TITLE @"Create new"
#define ALERT_INPUT_DIALOG_MESSAGE @"Enter a name"
#define ALERT_INPUT_DIALOG_CONFIRM_BUTTON_NAME @"OK"
#define TEMPLATE_CONTENTS @"<html><body><div id=\"content\" contenteditable=\"true\" style=\"font-family: Helvetica\"></div></body></html>"

#define FILE_NOT_FOUND_EXCEPTION @"FileNotFoundException"
#define DIRECTORY_NOT_FOUND_EXCEPTION @"DirectoryNotFoundException"
#define NOT_IMPLEMENTED_EXCEPTION @"NotImplementedException"

#define NOTE_DOWNLOADED @"NoteDownloaded"
#define SYSTEM_DATE_FORMAT @"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"

#define DROPBOX_SERVER_MODIFED_KEY @"server_modified"
#define DROPBOX_ROOT_DIRECTORY @"/Notebooks"

#define CHECK_IMAGE_NAME @"check"

#define CONFRIM_TITLE @"Confirm"

#endif /* Defines_h */
