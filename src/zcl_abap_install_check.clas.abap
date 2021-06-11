CLASS zcl_abap_install_check DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS check
      IMPORTING
        !iv_class_name      TYPE clike
        !iv_error_text      TYPE clike OPTIONAL
      RETURNING
        VALUE(rv_installed) TYPE flag .
    CLASS-METHODS abap2xlsx
      IMPORTING
        !iv_with_message    TYPE flag DEFAULT abap_true
      RETURNING
        VALUE(rv_installed) TYPE flag .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ABAP_INSTALL_CHECK IMPLEMENTATION.


  METHOD abap2xlsx.
    DATA: lv_class_name TYPE string VALUE 'ZCL_EXCEL'.

    zcl_abap_install_check=>check(
      EXPORTING
        iv_class_name =  lv_class_name
      RECEIVING
        rv_installed  = rv_installed
    ).
    IF rv_installed EQ abap_false AND iv_with_message EQ abap_true.
      AUTHORITY-CHECK OBJECT 'S_DEVELOP' ID 'ACTVT' FIELD '03'.
      IF sy-subrc EQ 0.
        " for developer
        zcl_abap_install_check=>check(
          EXPORTING
            iv_class_name = lv_class_name
            iv_error_text = 'install abap2xlsx from https://github.com/sapmentors/abap2xlsx'
          RECEIVING
            rv_installed  = rv_installed
        ).
      ELSE.
        " for user
        zcl_abap_install_check=>check(
          EXPORTING
            iv_class_name = lv_class_name
            iv_error_text = 'abap2xlsx is not installed.'
          RECEIVING
            rv_installed  = rv_installed
        ).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD check.
* https://github.com/boy0korea/ABAP_INSTALL_CHECK

    cl_abap_typedescr=>describe_by_name(
      EXPORTING
        p_name         = iv_class_name
      EXCEPTIONS
        type_not_found = 1
    ).

    IF sy-subrc EQ 0.
      " exist
      rv_installed = abap_true.
    ELSEIF iv_error_text IS NOT INITIAL.
      " not exist
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
    ENDIF.
  ENDMETHOD.
ENDCLASS.
