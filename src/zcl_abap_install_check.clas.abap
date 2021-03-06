CLASS zcl_abap_install_check DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS check_install
      IMPORTING
        !iv_class_name      TYPE clike
        !iv_error_text      TYPE clike OPTIONAL
      RETURNING
        VALUE(rv_installed) TYPE flag .
    CLASS-METHODS message
      IMPORTING
        !iv_error_text TYPE clike .
    CLASS-METHODS is_abap2xlsx_installed
      IMPORTING
        !iv_with_message    TYPE flag DEFAULT abap_true
      RETURNING
        VALUE(rv_installed) TYPE flag .
  PROTECTED SECTION.

    CLASS-METHODS readme .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ABAP_INSTALL_CHECK IMPLEMENTATION.


  METHOD check_install.
* https://github.com/boy0korea/ABAP_INSTALL_CHECK

    TRY.
        cl_abap_typedescr=>describe_by_name(
          EXPORTING
            p_name         = iv_class_name
          EXCEPTIONS
            type_not_found = 1
        ).
      CATCH cx_root.
        " error
        sy-subrc = 4.
    ENDTRY.

    IF sy-subrc EQ 0.
      " exist
      rv_installed = abap_true.
    ELSEIF iv_error_text IS NOT INITIAL.
      " not exist
      message( iv_error_text = iv_error_text ).
    ENDIF.
  ENDMETHOD.


  METHOD is_abap2xlsx_installed.
    DATA: lv_class_name TYPE string VALUE 'ZCL_EXCEL'.

    check_install(
      EXPORTING
        iv_class_name =  lv_class_name
      RECEIVING
        rv_installed  = rv_installed
    ).
    IF rv_installed EQ abap_false AND iv_with_message EQ abap_true.
      AUTHORITY-CHECK OBJECT 'S_DEVELOP' ID 'ACTVT' FIELD '03'.
      IF sy-subrc EQ 0.
        " for developer
        message( 'install abap2xlsx from https://github.com/sapmentors/abap2xlsx' ).
      ELSE.
        " for user
        message( 'abap2xlsx is not installed.' ).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD message.
    CHECK: iv_error_text IS NOT INITIAL.

    IF wdr_task=>application IS NOT INITIAL.
      " WD or FPM
      wdr_task=>application->component->if_wd_controller~get_message_manager( )->report_error_message(
        EXPORTING
          message_text = iv_error_text
      ).
    ELSE.
      " GUI
      MESSAGE iv_error_text TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.

  ENDMETHOD.


  METHOD readme.
* https://github.com/boy0korea/ABAP_INSTALL_CHECK
  ENDMETHOD.
ENDCLASS.
