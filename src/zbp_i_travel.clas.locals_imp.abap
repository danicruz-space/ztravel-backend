CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Travel.

    METHODS setStatusInitial FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~setStatusInitial.

    METHODS calculateTotalPrice FOR DETERMINE ON SAVE
      IMPORTING keys FOR Travel~calculateTotalPrice.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDates.

    METHODS validateAgency FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateAgency.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.

    METHODS validateCurrency FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCurrency.

    METHODS validateBookingFee FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateBookingFee.

    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result.

    METHODS bookTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~bookTravel RESULT result.

    METHODS deductDiscount FOR MODIFY
      IMPORTING keys FOR ACTION Travel~deductDiscount RESULT result.

    METHODS cancelTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~cancelTravel RESULT result.

    METHODS setBookingFee FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~setBookingFee.

    METHODS earlynumbering_cba_Booking FOR NUMBERING
      IMPORTING entities FOR CREATE Travel\_Booking.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
    result = VALUE #( FOR key IN keys ( %tky = key-%tky
                                        %update = if_abap_behv=>auth-allowed
                                        %delete = if_abap_behv=>auth-allowed ) ).
  ENDMETHOD.

  METHOD earlynumbering_create.

    LOOP AT entities INTO DATA(entity).
      IF entity-TravelId IS NOT INITIAL.
        APPEND VALUE #( %cid = entity-%cid
                        %is_draft = entity-%is_draft
                        TravelId = entity-TravelId ) TO mapped-travel.
        CONTINUE.
      ENDIF.
      TRY.
          cl_numberrange_runtime=>number_get(
            EXPORTING
              nr_range_nr = '01'
              object      = '/DMO/TRAVL'
            IMPORTING
              number      = DATA(lv_new_id) ).

          APPEND VALUE #( %cid = entity-%cid
                          %is_draft = entity-%is_draft
                          TravelId = CONV #( lv_new_id ) ) TO mapped-travel.
        CATCH cx_number_ranges.
          APPEND VALUE #( %cid = entity-%cid
                          %fail-cause = if_abap_behv=>cause-unspecific ) TO failed-travel.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD setStatusInitial.
    MODIFY ENTITIES OF z_i_travel IN LOCAL MODE
        ENTITY Travel
        UPDATE FIELDS ( Status )
        WITH VALUE #( FOR key IN keys ( %tky = key-%tky
                                        Status = zif_travel_status=>new ) ).
  ENDMETHOD.

  METHOD calculateTotalPrice.

    DATA lt_travel_keys TYPE zcl_travel_calculations=>tt_travel_keys.

    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE #( %tky-TravelId = ls_key-TravelId
                      %tky-%is_draft = ls_key-%is_draft ) TO lt_travel_keys.
    ENDLOOP.

    zcl_travel_calculations=>recalculate_total_price( lt_travel_keys ).
  ENDMETHOD.

  METHOD validateDates.

    READ ENTITIES OF z_i_travel IN LOCAL MODE
        ENTITY Travel
        FIELDS ( BeginDate EndDate )
        WITH CORRESPONDING #( keys )
        RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).

      IF travel-BeginDate IS INITIAL.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = travel-%tky
                        %msg = new_message(
                                id = zif_travel_messages=>c_msgid
                                number = zif_travel_messages=>c_begin_date_required
                                severity = if_abap_behv_message=>severity-error ) ) TO reported-travel.
      ENDIF.

      IF travel-EndDate IS INITIAL.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = travel-%tky
                        %msg = new_message(
                                id = zif_travel_messages=>c_msgid
                                number = zif_travel_messages=>c_end_date_required
                                severity = if_abap_behv_message=>severity-error ) ) TO reported-travel.
      ENDIF.

      IF travel-BeginDate IS NOT INITIAL AND travel-EndDate IS NOT INITIAL AND travel-EndDate < travel-BeginDate.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = travel-%tky
                        %msg = new_message(
                                id = zif_travel_messages=>c_msgid
                                number = zif_travel_messages=>c_end_before_begin
                                severity = if_abap_behv_message=>severity-error ) ) TO reported-travel.
      ENDIF.

      IF travel-BeginDate IS NOT INITIAL AND travel-BeginDate < cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = travel-%tky
                        %msg = new_message(
                                id = zif_travel_messages=>c_msgid
                                number = zif_travel_messages=>c_begin_date_past
                                severity = if_abap_behv_message=>severity-error ) ) TO reported-travel.
      ENDIF.

      IF travel-EndDate IS NOT INITIAL AND travel-EndDate < cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = travel-%tky
                        %msg = new_message(
                                id = zif_travel_messages=>c_msgid
                                number = zif_travel_messages=>c_end_date_past
                                severity = if_abap_behv_message=>severity-error ) ) TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateAgency.
    READ ENTITIES OF z_i_travel IN LOCAL MODE
    ENTITY Travel
    FIELDS ( AgencyId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).


    DATA(lt_agencys_ids) = VALUE zcl_travel_validations=>tt_agency_id( FOR <travel> IN travels WHERE ( AgencyId IS NOT INITIAL ) ( <travel>-AgencyId ) ).
    DATA(lt_invalid_ids) = zcl_travel_validations=>find_invalid_agencys( lt_agencys_ids ).

    LOOP AT travels INTO DATA(travel).
      IF travel-AgencyId IS INITIAL.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = travel-%tky
                        %msg = new_message(
                                id = zif_travel_messages=>c_msgid
                                number = zif_travel_messages=>c_agency_required
                                severity = if_abap_behv_message=>severity-error ) ) TO reported-travel.
        CONTINUE.
      ENDIF.

      IF line_exists( lt_invalid_ids[ table_line = travel-AgencyId ] ).
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = travel-%tky
                        %msg = new_message(
                                id = zif_travel_messages=>c_msgid
                                number = zif_travel_messages=>c_agency_not_found
                                severity = if_abap_behv_message=>severity-error
                                v1 = travel-AgencyId ) ) TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateCustomer.

    READ ENTITIES OF z_i_travel IN LOCAL MODE
    ENTITY Travel
    FIELDS ( CustomerId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    DATA(lt_customers_ids) = VALUE zcl_travel_validations=>tt_customer_id( FOR <travel> IN travels WHERE ( CustomerId IS NOT INITIAL ) ( <travel>-CustomerId ) ).
    DATA(lt_invalid_ids) = zcl_travel_validations=>find_invalid_customers( lt_customers_ids ).

    LOOP AT travels INTO DATA(travel).
      IF travel-CustomerId IS INITIAL.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = travel-%tky
                        %msg = new_message(
                                id = zif_travel_messages=>c_msgid
                                number = zif_travel_messages=>c_customer_required
                                severity = if_abap_behv_message=>severity-error ) ) TO reported-travel.
        CONTINUE.
      ENDIF.
      IF line_exists( lt_invalid_ids[ table_line = travel-CustomerId ] ).
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = travel-%tky
                        %msg = new_message(
                                id = zif_travel_messages=>c_msgid
                                number = zif_travel_messages=>c_customer_not_found
                                severity = if_abap_behv_message=>severity-error
                                v1 = travel-CustomerId ) ) TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateCurrency.

    READ ENTITIES OF z_i_travel IN LOCAL MODE
    ENTITY Travel
    FIELDS ( CurrencyCode )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    DATA(lt_currencys_codes) = VALUE zcl_travel_validations=>tt_currency_code( FOR <travel> IN travels WHERE ( CurrencyCode IS NOT INITIAL ) ( <travel>-CurrencyCode ) ).
    DATA(lt_invalid_ids) = zcl_travel_validations=>find_invalid_currencys( lt_currencys_codes ).

    LOOP AT travels INTO DATA(travel).
      IF travel-CurrencyCode IS INITIAL.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = travel-%tky
                        %msg = new_message(
                                id = zif_travel_messages=>c_msgid
                                number = zif_travel_messages=>c_currency_required
                                severity = if_abap_behv_message=>severity-error ) ) TO reported-travel.
        CONTINUE.
      ENDIF.
      IF line_exists( lt_invalid_ids[ table_line = travel-CurrencyCode ] ).
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = travel-%tky
                        %msg = new_message(
                                id = zif_travel_messages=>c_msgid
                                number = zif_travel_messages=>c_currency_not_found
                                severity = if_abap_behv_message=>severity-error
                                v1 = travel-CurrencyCode ) ) TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateBookingFee.

    READ ENTITIES OF z_i_travel IN LOCAL MODE
    ENTITY Travel
    FIELDS ( BookingFee )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).
      IF travel-BookingFee IS INITIAL OR travel-BookingFee <= 0.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = travel-%tky
                        %msg = new_message(
                                id = zif_travel_messages=>c_msgid
                                number = zif_travel_messages=>c_booking_fee_invalid
                                severity = if_abap_behv_message=>severity-error ) ) TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  "Definir o side effects para booking fee atualizar logo"
  METHOD setBookingFee.

    READ ENTITIES OF z_i_travel IN LOCAL MODE
        ENTITY Travel
        FIELDS ( AgencyId )
        WITH CORRESPONDING #( keys )
        RESULT DATA(travels).

    DATA(lt_agencys_ids) = VALUE zcl_travel_validations=>tt_agency_id( FOR <travel> IN travels WHERE ( AgencyId IS NOT INITIAL ) ( <travel>-AgencyId ) ).

    IF lt_agencys_ids IS INITIAL.
      RETURN.
    ENDIF.

    SELECT a~AgencyID, c~booking_fee
        FROM /dmo/I_Agency AS a
        INNER JOIN zcountry_fees AS c ON a~CountryCode = c~country_code
        FOR ALL ENTRIES IN @lt_agencys_ids
        WHERE a~AgencyID = @lt_agencys_ids-table_line
        INTO TABLE @DATA(lt_agency_fees).

    MODIFY ENTITIES OF z_i_travel IN LOCAL MODE
        ENTITY Travel
        UPDATE FIELDS ( BookingFee )
        WITH VALUE #( FOR <travel> IN travels WHERE ( AgencyId IS NOT INITIAL )
                                                    ( %tky = <travel>-%tky
                                                      BookingFee = lt_agency_fees[ agencyid = <travel>-AgencyId ]-booking_fee ) ).

  ENDMETHOD.

  METHOD acceptTravel.

    READ ENTITIES OF z_i_travel IN LOCAL MODE
        ENTITY Travel
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).
      IF travel-Status <> zif_travel_status=>new AND travel-Status <> zif_travel_status=>planned.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = travel-%tky
                        %msg = new_message(
                                id = zif_travel_messages=>c_msgid
                                number = zif_travel_messages=>c_invalid_status_transition
                                severity = if_abap_behv_message=>severity-error
                                v1 = travel-Status
                                v2 = zif_travel_status=>booked ) ) TO reported-travel.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF z_i_travel IN LOCAL MODE
        ENTITY Travel
        UPDATE FIELDS ( Status )
        WITH VALUE #( FOR <t> IN travels
                      WHERE ( Status = zif_travel_status=>new OR Status = zif_travel_status=>planned )
                      ( %tky = <t>-%tky
                        Status = zif_travel_status=>booked ) ).

    READ ENTITIES OF z_i_travel IN LOCAL MODE
        ENTITY Travel
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(updated_travels).

    result = VALUE #( FOR <t> IN updated_travels
                      ( %tky = <t>-%tky
                        %param = <t> ) ).
  ENDMETHOD.

  METHOD bookTravel.

    READ ENTITIES OF z_i_travel IN LOCAL MODE
        ENTITY Travel
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).
      IF travel-Status <> zif_travel_status=>planned.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = travel-%tky
                        %msg = new_message(
                                id = zif_travel_messages=>c_msgid
                                number = zif_travel_messages=>c_invalid_status_transition
                                severity = if_abap_behv_message=>severity-error
                                v1 = travel-Status
                                v2 = zif_travel_status=>booked ) ) TO reported-travel.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF z_i_travel IN LOCAL MODE
        ENTITY Travel
        UPDATE FIELDS ( Status )
        WITH VALUE #( FOR <t> IN travels
                      WHERE ( Status = zif_travel_status=>planned )
                      ( %tky = <t>-%tky
                        Status = zif_travel_status=>booked ) ).

    READ ENTITIES OF z_i_travel IN LOCAL MODE
        ENTITY Travel
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(updated_travels).

    result = VALUE #( FOR <t> IN updated_travels
                      ( %tky = <t>-%tky
                        %param = <t> ) ).
  ENDMETHOD.

  METHOD cancelTravel.

    READ ENTITIES OF z_i_travel IN LOCAL MODE
        ENTITY Travel
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).
      IF travel-Status = zif_travel_status=>cancelled.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = travel-%tky
                        %msg = new_message(
                                id = zif_travel_messages=>c_msgid
                                number = zif_travel_messages=>c_booking_fee_invalid
                                severity = if_abap_behv_message=>severity-error ) ) TO reported-travel.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF z_i_travel IN LOCAL MODE
        ENTITY Travel
        UPDATE FIELDS ( Status )
        WITH VALUE #( FOR <t> IN travels
                      WHERE ( Status <> zif_travel_status=>cancelled )
                      ( %tky = <t>-%tky
                        Status = zif_travel_status=>cancelled ) ).

    READ ENTITIES OF z_i_travel IN LOCAL MODE
        ENTITY Travel
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(updated_travels).

    result = VALUE #( FOR <t> IN updated_travels
                      ( %tky = <t>-%tky
                        %param = <t> ) ).
  ENDMETHOD.

  METHOD deductDiscount.

    LOOP AT keys INTO DATA(key).
      IF key-%param-discount_percent IS INITIAL OR key-%param-discount_percent <= 0 OR key-%param-discount_percent > 100.
        APPEND VALUE #( %tky = key-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = key-%tky
                        %msg = new_message(
                                id = zif_travel_messages=>c_msgid
                                number = zif_travel_messages=>c_discount_error
                                severity = if_abap_behv_message=>severity-error ) ) TO reported-travel.
      ENDIF.
    ENDLOOP.

    READ ENTITIES OF z_i_travel IN LOCAL MODE
        ENTITY Travel
        FIELDS ( BookingFee )
        WITH CORRESPONDING #( keys )
        RESULT DATA(travels).

    DATA lt_updates TYPE TABLE FOR UPDATE z_i_travel\\Travel.

    LOOP AT travels INTO DATA(travel).

      READ TABLE keys INTO DATA(ls_key) WITH KEY %tky = travel-%tky.
      IF sy-subrc = 0.
        DATA(lv_new_fee) = travel-BookingFee * ( 1 - ls_key-%param-discount_percent / 100 ).

        APPEND VALUE #( %tky = travel-%tky
                        BookingFee = lv_new_fee ) TO lt_updates.
      ENDIF.
    ENDLOOP.

    IF lt_updates IS NOT INITIAL.
      MODIFY ENTITIES OF z_i_travel IN LOCAL MODE
         ENTITY Travel
         UPDATE FIELDS ( BookingFee )
         WITH lt_updates.
    ENDIF.

    READ ENTITIES OF z_i_travel IN LOCAL MODE
        ENTITY Travel
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(updated_travels).

    result = VALUE #( FOR <t> IN updated_travels ( %tky = <t>-%tky
                                                   %param = <t> ) ).
  ENDMETHOD.

  METHOD earlynumbering_cba_Booking.

    SELECT travel_id, booking_id
      FROM /dmo/booking
      FOR ALL ENTRIES IN @entities
      WHERE travel_id = @entities-TravelId
      INTO TABLE @DATA(lt_all_bookings).

    SORT lt_all_bookings BY travel_id ASCENDING booking_id DESCENDING.
    LOOP AT entities INTO DATA(entity).

      DATA(lv_max_booking_id) = CONV /dmo/booking_id( 0 ).
      READ TABLE lt_all_bookings INTO DATA(ls_max) WITH KEY travel_id = entity-TravelId.
      IF sy-subrc = 0.
        lv_max_booking_id = ls_max-booking_id.
      ENDIF.

      LOOP AT entity-%target ASSIGNING FIELD-SYMBOL(<new_booking>).
        IF <new_booking>-BookingId IS NOT INITIAL.
          APPEND VALUE #( %cid = <new_booking>-%cid
                          %is_draft = <new_booking>-%is_draft
                          TravelId  = entity-TravelId
                          BookingId = <new_booking>-BookingId ) TO mapped-booking.
          CONTINUE.
        ENDIF.
        lv_max_booking_id += 1.

        APPEND VALUE #( %cid = <new_booking>-%cid
                        %is_draft = <new_booking>-%is_draft
                        TravelId  = entity-TravelId
                        BookingId = lv_max_booking_id ) TO mapped-booking.
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_Z_I_TRAVEL DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    TYPES tt_travel_update TYPE TABLE FOR UPDATE z_i_travel\\Travel.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

    METHODS handle_create
      IMPORTING
        is_create TYPE z_i_travel
      RETURNING
        VALUE(rs_travel) TYPE /dmo/travel.

    METHODS handle_delete
      IMPORTING
        is_delete TYPE z_i_travel
      RETURNING
        VALUE(rs_travel) TYPE /dmo/travel.

ENDCLASS.

CLASS lsc_Z_I_TRAVEL IMPLEMENTATION.

  METHOD save_modified.
    IF create-travel IS NOT INITIAL.
      DATA lt_create_db TYPE STANDARD TABLE OF /dmo/travel.

      LOOP AT create-travel ASSIGNING FIELD-SYMBOL(<create>).
        APPEND handle_create( CORRESPONDING #( <create> ) ) TO lt_create_db.
      ENDLOOP.

      INSERT /dmo/travel FROM TABLE @lt_create_db.
    ENDIF.

    IF update-travel IS NOT INITIAL.
      LOOP AT update-travel ASSIGNING FIELD-SYMBOL(<entity>).
        SELECT SINGLE * FROM /dmo/travel
          WHERE travel_id = @<entity>-TravelId
          INTO @DATA(ls_db).

        IF sy-subrc = 0.
          IF <entity>-%control-AgencyId = if_abap_behv=>mk-on.
            ls_db-agency_id = <entity>-AgencyId.
          ENDIF.
          IF <entity>-%control-CustomerId = if_abap_behv=>mk-on.
            ls_db-customer_id = <entity>-CustomerId.
          ENDIF.
          IF <entity>-%control-BeginDate = if_abap_behv=>mk-on.
            ls_db-begin_date = <entity>-BeginDate.
          ENDIF.
          IF <entity>-%control-EndDate = if_abap_behv=>mk-on.
            ls_db-end_date = <entity>-EndDate.
          ENDIF.
          IF <entity>-%control-BookingFee = if_abap_behv=>mk-on.
            ls_db-booking_fee = <entity>-BookingFee.
          ENDIF.
          IF <entity>-%control-TotalPrice = if_abap_behv=>mk-on.
            ls_db-total_price = <entity>-TotalPrice.
          ENDIF.
          IF <entity>-%control-CurrencyCode = if_abap_behv=>mk-on.
            ls_db-currency_code = <entity>-CurrencyCode.
          ENDIF.
          IF <entity>-%control-Description = if_abap_behv=>mk-on.
            ls_db-description = <entity>-Description.
          ENDIF.
          IF <entity>-%control-Status = if_abap_behv=>mk-on.
            ls_db-status = <entity>-Status.
          ENDIF.

          ls_db-lastchangedby = cl_abap_context_info=>get_user_technical_name( ).
          ls_db-lastchangedat = cl_abap_tstmp=>utclong2tstmp( utclong_current( ) ).

          UPDATE /dmo/travel FROM @ls_db.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF delete-travel IS NOT INITIAL.
      LOOP AT delete-travel ASSIGNING FIELD-SYMBOL(<del_travel>).
        DELETE FROM /dmo/booking WHERE travel_id = @<del_travel>-TravelId.
        DELETE FROM /dmo/travel  WHERE travel_id = @<del_travel>-TravelId.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

  METHOD handle_create.

    GET TIME STAMP FIELD DATA(lv_timestamp).
    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).

    rs_travel = VALUE #(
      travel_id = is_create-TravelId
      agency_id = is_create-AgencyId
      customer_id = is_create-CustomerId
      begin_date = is_create-BeginDate
      end_date = is_create-EndDate
      booking_fee = is_create-BookingFee
      total_price = is_create-TotalPrice
      currency_code = is_create-CurrencyCode
      description = is_create-Description
      status = is_create-Status
      createdby = lv_user
      createdat = lv_timestamp
      lastchangedby = lv_user
      lastchangedat = lv_timestamp ).

  ENDMETHOD.

  METHOD handle_delete.
    rs_travel-travel_id = is_delete-TravelId.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS setBookingDate FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~setBookingDate.

    METHODS setFlightPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~setFlightPrice.

    METHODS setCurrencyFromTravel FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~setCurrencyFromTravel.

    METHODS calculateTotalPrice FOR DETERMINE ON SAVE
      IMPORTING keys FOR Booking~calculateTotalPrice.

    METHODS validateFlightPrice FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateFlightPrice.

    METHODS validateBookingDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateBookingDate.

    METHODS validateFlightDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateFlightDate.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateCustomer.

    METHODS validateCurrency FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateCurrency.

    METHODS validateFlight FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateFlight.

    METHODS validateTravelStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateTravelStatus.

    METHODS earlynumbering_cba_BookSuppl FOR NUMBERING
      IMPORTING entities FOR CREATE Booking\_BookSupplement.

ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD setBookingDate.

    READ ENTITIES OF z_i_travel IN LOCAL MODE
      ENTITY Booking
      FIELDS ( BookingDate )
      WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    MODIFY ENTITIES OF z_i_travel IN LOCAL MODE
      ENTITY Booking
      UPDATE FIELDS ( BookingDate )
      WITH VALUE #( FOR <b> IN bookings
                    ( %tky = <b>-%tky
                      BookingDate = lv_today ) ).
  ENDMETHOD.

  METHOD setflightprice.

    READ ENTITIES OF z_i_travel IN LOCAL MODE
    ENTITY Booking
    FIELDS ( CarrierId ConnectionId FlightDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(bookings).
    DELETE bookings WHERE CarrierId IS INITIAL OR ConnectionId IS INITIAL OR FlightDate IS INITIAL.


    IF bookings IS INITIAL.
      RETURN.
    ENDIF.

    SELECT carrier_id, connection_id, price, currency_code
      FROM /dmo/flight
      FOR ALL ENTRIES IN @bookings
      WHERE carrier_id = @bookings-CarrierId AND connection_id = @bookings-ConnectionId
    INTO TABLE @DATA(lt_flights).

    DATA lt_updates TYPE TABLE FOR UPDATE z_i_travel\\Booking.

    LOOP AT bookings INTO DATA(booking).
      READ TABLE lt_flights INTO DATA(ls_flight)
      WITH KEY carrier_id = booking-CarrierId
               connection_id = booking-ConnectionId.

      IF sy-subrc = 0.
        APPEND VALUE #( %tky = booking-%tky
                        FlightPrice = ls_flight-price
                        CurrencyCode = ls_flight-currency_code ) TO lt_updates.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF z_i_travel IN LOCAL MODE
      ENTITY Booking
      UPDATE FIELDS ( FlightPrice CurrencyCode )
      WITH lt_updates.

  ENDMETHOD.

  METHOD setCurrencyFromTravel.

    READ ENTITIES OF z_i_travel IN LOCAL MODE
      ENTITY Booking
        FIELDS ( CurrencyCode )
        WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    READ ENTITIES OF z_i_travel IN LOCAL MODE
      ENTITY Booking BY \_Travel
        FIELDS ( CurrencyCode )
        WITH CORRESPONDING #( keys )
      RESULT DATA(travels)
      LINK DATA(lt_link).

    DATA lt_updates TYPE TABLE FOR UPDATE z_i_travel\\Booking.

    LOOP AT bookings INTO DATA(booking).

      IF booking-CurrencyCode IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      READ TABLE lt_link INTO DATA(ls_link) WITH KEY source-%tky = booking-%tky.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      READ TABLE travels INTO DATA(travel) WITH KEY %tky = ls_link-target-%tky.
      IF sy-subrc <> 0 OR travel-CurrencyCode IS INITIAL.
        CONTINUE.
      ENDIF.

      APPEND VALUE #( %tky = booking-%tky
                      CurrencyCode = travel-CurrencyCode ) TO lt_updates.

    ENDLOOP.

    IF lt_updates IS NOT INITIAL.
      MODIFY ENTITIES OF z_i_travel IN LOCAL MODE
        ENTITY Booking
          UPDATE FIELDS ( CurrencyCode )
          WITH lt_updates.
    ENDIF.

  ENDMETHOD.

  METHOD validateflightprice.

    READ ENTITIES OF z_i_travel IN LOCAL MODE
    ENTITY Booking
    FIELDS ( FlightPrice )
    WITH CORRESPONDING #( keys )
    RESULT DATA(bookings).

    LOOP AT bookings INTO DATA(booking).
      IF booking-FlightPrice IS INITIAL OR booking-FlightPrice <= 0.
        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.
        APPEND VALUE #( %tky = booking-%tky
                        %msg = new_message(
                                id = zif_travel_messages=>c_msgid
                                number = zif_travel_messages=>c_flight_price_invalid
                                severity = if_abap_behv_message=>severity-error ) ) TO reported-booking.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validatebookingdate.

    READ ENTITIES OF z_i_travel IN LOCAL MODE
    ENTITY Booking
    FIELDS ( CarrierId ConnectionId FlightDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(bookings).

    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    LOOP AT bookings INTO DATA(booking).
      IF booking-BookingDate IS INITIAL.
        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.
        APPEND VALUE #( %tky = booking-%tky
                        %msg = new_message(
                                id = zif_travel_messages=>c_msgid
                                number = zif_travel_messages=>c_begin_date_required
                                severity = if_abap_behv_message=>severity-error ) ) TO reported-booking.
        CONTINUE.
      ENDIF.

      IF booking-BookingDate < lv_today.
        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.
        APPEND VALUE #( %tky = booking-%tky
                        %msg = new_message(
                                id = zif_travel_messages=>c_msgid
                                number = zif_travel_messages=>c_booking_date_past
                                severity = if_abap_behv_message=>severity-error ) ) TO reported-booking.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateflightdate.

    READ ENTITIES OF z_i_travel IN LOCAL MODE
    ENTITY Booking BY \_Travel
    FIELDS ( BeginDate EndDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels)
    LINK DATA(lt_link).

    READ ENTITIES OF z_i_travel IN LOCAL MODE
    ENTITY Booking
    FIELDS ( FlightDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(bookings).

    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    LOOP AT bookings INTO DATA(booking).
      IF booking-FlightDate IS INITIAL.
        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.
        APPEND VALUE #( %tky = booking-%tky
                        %msg = new_message(
                                id = zif_travel_messages=>c_msgid
                                number = zif_travel_messages=>c_flight_date_required
                                severity = if_abap_behv_message=>severity-error ) ) TO reported-booking.
        CONTINUE.
      ENDIF.

      IF booking-FlightDate < lv_today.
        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.
        APPEND VALUE #( %tky = booking-%tky
                        %msg = new_message(
                                id = zif_travel_messages=>c_msgid
                                number = zif_travel_messages=>c_flight_date_past
                                severity = if_abap_behv_message=>severity-error ) ) TO reported-booking.
        CONTINUE.
      ENDIF.

      DATA(ls_link) = lt_link[ source-%tky = booking-%tky ].
      DATA(travel)  = travels[ %tky = ls_link-target-%tky ].

      IF booking-FlightDate < travel-BeginDate OR booking-FlightDate > travel-EndDate.
        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.
        APPEND VALUE #( %tky = booking-%tky
                        %msg = new_message(
                                id = zif_travel_messages=>c_msgid
                                number = zif_travel_messages=>c_flight_date_outside_travel
                                severity = if_abap_behv_message=>severity-error
                                v1 = |{ booking-FlightDate DATE = USER }|
                                v2 = |{ travel-BeginDate DATE = USER }|
                                v3 = |{ travel-EndDate DATE = USER }| ) ) TO reported-booking.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validatecustomer.

    READ ENTITIES OF z_i_travel IN LOCAL MODE
    ENTITY Booking
    FIELDS ( CustomerId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(bookings).

    DATA(lt_customer_ids) = VALUE zcl_travel_validations=>tt_customer_id(
                             FOR <b> IN bookings
                             WHERE ( CustomerId IS NOT INITIAL )
                             ( <b>-CustomerId ) ).

    DATA(lt_invalid_ids) = zcl_travel_validations=>find_invalid_customers( lt_customer_ids ).

    LOOP AT bookings INTO DATA(booking).
      IF booking-CustomerId IS INITIAL.
        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.
        APPEND VALUE #( %tky = booking-%tky
                        %msg = new_message(
                                id = zif_travel_messages=>c_msgid
                                number = zif_travel_messages=>c_customer_required
                                severity = if_abap_behv_message=>severity-error ) ) TO reported-booking.
        CONTINUE.
      ENDIF.

      IF line_exists( lt_invalid_ids[ table_line = booking-CustomerId ] ).
        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.
        APPEND VALUE #( %tky = booking-%tky
                        %msg = new_message(
                                id = zif_travel_messages=>c_msgid
                                number = zif_travel_messages=>c_customer_not_found
                                severity = if_abap_behv_message=>severity-error
                                v1 = booking-CustomerId ) ) TO reported-booking.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validatecurrency.

    READ ENTITIES OF z_i_travel IN LOCAL MODE
    ENTITY Booking
    FIELDS ( CurrencyCode )
    WITH CORRESPONDING #( keys )
    RESULT DATA(bookings).

    DATA(lt_currency_codes) = VALUE zcl_travel_validations=>tt_currency_code(
                             FOR <b> IN bookings
                             WHERE ( CurrencyCode IS NOT INITIAL )
                             ( <b>-CurrencyCode ) ).

    DATA(lt_invalid_codes) = zcl_travel_validations=>find_invalid_currencys( lt_currency_codes ).

    LOOP AT bookings INTO DATA(booking).
      IF booking-CurrencyCode IS INITIAL.
        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.
        APPEND VALUE #( %tky = booking-%tky
                        %msg = new_message(
                                id = zif_travel_messages=>c_msgid
                                number = zif_travel_messages=>c_currency_required
                                severity = if_abap_behv_message=>severity-error ) ) TO reported-booking.
        CONTINUE.
      ENDIF.

      IF line_exists( lt_invalid_codes[ table_line = booking-CurrencyCode ] ).
        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.
        APPEND VALUE #( %tky = booking-%tky
                        %msg = new_message(
                                id = zif_travel_messages=>c_msgid
                                number = zif_travel_messages=>c_currency_not_found
                                severity = if_abap_behv_message=>severity-error
                                v1 = booking-CurrencyCode ) ) TO reported-booking.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateflight.

    READ ENTITIES OF z_i_travel IN LOCAL MODE
    ENTITY Booking
    FIELDS ( CarrierId ConnectionId FlightDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(bookings).

    DATA(lt_flight_keys) = VALUE zcl_travel_validations=>tt_flight_key(
                             FOR <b> IN bookings
                             WHERE ( CarrierId IS NOT INITIAL AND ConnectionId IS NOT INITIAL AND FlightDate IS NOT INITIAL )
                             ( carrier_id = <b>-CarrierId
                               connection_id = |{ <b>-ConnectionId ALPHA = IN }|
                               flight_date = <b>-FlightDate ) ).

    DATA(lt_invalid_flights) = zcl_travel_validations=>find_invalid_flights( lt_flight_keys ).

    LOOP AT bookings INTO DATA(booking).
      IF line_exists( lt_invalid_flights[ carrier_id = booking-CarrierId
                                          connection_id = booking-ConnectionId
                                          flight_date = booking-FlightDate ] ).

        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.
        APPEND VALUE #( %tky = booking-%tky
                        %msg = new_message(
                                id = zif_travel_messages=>c_msgid
                                number = zif_travel_messages=>c_flight_not_found
                                severity = if_abap_behv_message=>severity-error
                                v1 = booking-CarrierId
                                v2 = booking-ConnectionId
                                v3 = |{ booking-FlightDate DATE = USER }| ) ) TO reported-booking.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validatetravelstatus.

    READ ENTITIES OF z_i_travel IN LOCAL MODE
    ENTITY Booking BY \_Travel
    FIELDS ( Status )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travels)
    LINK DATA(lt_link).

    LOOP AT lt_link INTO DATA(ls_link).

      DATA(ls_travel) = lt_travels[ %tky = ls_link-target-%tky ].

      IF ls_travel-Status = zif_travel_status=>cancelled.
        APPEND VALUE #( %tky = ls_link-source-%tky ) TO failed-booking.
        APPEND VALUE #( %tky = ls_link-source-%tky
                        %msg = new_message(
                                id = zif_travel_messages=>c_msgid
                                number = zif_travel_messages=>c_already_cancelled
                                severity = if_abap_behv_message=>severity-error ) ) TO reported-booking.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD calculateTotalPrice.
    DATA lt_travel_keys TYPE zcl_travel_calculations=>tt_travel_keys.

    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE #( %tky-TravelId  = ls_key-TravelId
                      %tky-%is_draft = ls_key-%is_draft ) TO lt_travel_keys.
    ENDLOOP.

    zcl_travel_calculations=>recalculate_total_price( lt_travel_keys ).

  ENDMETHOD.

  METHOD earlynumbering_cba_BookSuppl.

    SELECT travel_id, booking_id, booking_supplement_id
      FROM /dmo/book_suppl
      FOR ALL ENTRIES IN @entities
      WHERE travel_id  = @entities-TravelId
        AND booking_id = @entities-BookingId
      INTO TABLE @DATA(lt_db_supplements).

    LOOP AT entities INTO DATA(ls_booking).
      DATA(lv_max_suppl_id) = CONV /dmo/booking_supplement_id( 0 ).


      LOOP AT lt_db_supplements INTO DATA(ls_db)
        WHERE travel_id = ls_booking-TravelId AND booking_id = ls_booking-BookingId.
        IF ls_db-booking_supplement_id > lv_max_suppl_id.
          lv_max_suppl_id = ls_db-booking_supplement_id.
        ENDIF.
      ENDLOOP.

      LOOP AT mapped-booksupplement INTO DATA(ls_map_suppl)
        WHERE TravelId = ls_booking-TravelId AND BookingId = ls_booking-BookingId.
        IF ls_map_suppl-BookingSupplementId > lv_max_suppl_id.
          lv_max_suppl_id = ls_map_suppl-BookingSupplementId.
        ENDIF.
      ENDLOOP.

      LOOP AT ls_booking-%target ASSIGNING FIELD-SYMBOL(<ls_new_suppl>).

        IF line_exists( mapped-booksupplement[ %cid = <ls_new_suppl>-%cid ] ).
          CONTINUE.
        ENDIF.

        IF <ls_new_suppl>-BookingSupplementId IS NOT INITIAL.
          APPEND VALUE #( %cid = <ls_new_suppl>-%cid
                          %is_draft = <ls_new_suppl>-%is_draft
                          TravelId  = ls_booking-TravelId
                          BookingId = ls_booking-BookingId
                          BookingSupplementId = <ls_new_suppl>-BookingSupplementId )
                 TO mapped-booksupplement.
          CONTINUE.
        ENDIF.

        lv_max_suppl_id += 1.

        APPEND VALUE #( %cid      = <ls_new_suppl>-%cid
                        %is_draft = <ls_new_suppl>-%is_draft
                        TravelId  = ls_booking-TravelId
                        BookingId = ls_booking-BookingId
                        BookingSupplementId = lv_max_suppl_id )
               TO mapped-booksupplement.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.


CLASS lhc_BookingSupplement DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS setSupplementPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR BookSupplement~setSupplementPrice.

    METHODS validateSupplement FOR VALIDATE ON SAVE
      IMPORTING keys FOR BookSupplement~validateSupplement.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR BookSupplement~calculateTotalPrice.

ENDCLASS.

CLASS lhc_BookingSupplement IMPLEMENTATION.

  METHOD setsupplementprice.

    READ ENTITIES OF z_i_travel IN LOCAL MODE
        ENTITY BookSupplement
        FIELDS ( SupplementId )
        WITH CORRESPONDING #( keys )
        RESULT DATA(suppls).

    DELETE suppls WHERE SupplementId IS INITIAL.
    CHECK suppls IS NOT INITIAL.

    SELECT supplement_id, price, currency_code
        FROM /dmo/supplement
        FOR ALL ENTRIES IN @suppls
        WHERE supplement_id = @suppls-SupplementId
        INTO TABLE @DATA(lt_supplements).

    DATA lt_updates TYPE TABLE FOR UPDATE z_i_travel\\BookSupplement.

    LOOP AT suppls INTO DATA(suppl).
      READ TABLE lt_supplements INTO DATA(ls_master) WITH KEY supplement_id = suppl-SupplementId.
      IF sy-subrc = 0.
        APPEND VALUE #( %tky = suppl-%tky
                        Price = ls_master-price
                        CurrencyCode = ls_master-currency_code ) TO lt_updates.
      ENDIF.
    ENDLOOP.

    IF lt_updates IS NOT INITIAL.
      MODIFY ENTITIES OF z_i_travel IN LOCAL MODE
          ENTITY BookSupplement
          UPDATE FIELDS ( Price CurrencyCode )
          WITH VALUE #( FOR s IN suppls
                        FOR m IN lt_supplements WHERE ( supplement_id = s-SupplementId )
                                                      ( %tky = s-%tky
                                                        Price = m-price
                                                        CurrencyCode = m-currency_code ) ).
    ENDIF.

  ENDMETHOD.

  METHOD validatesupplement.

    READ ENTITIES OF z_i_travel IN LOCAL MODE
        ENTITY BookSupplement
        FIELDS ( SupplementId )
        WITH CORRESPONDING #( keys )
        RESULT DATA(suppls).

    DATA(lt_supplement_ids) = VALUE zcl_travel_validations=>tt_supplement_id(
                                FOR <s> IN suppls
                                WHERE ( SupplementId IS NOT INITIAL )
                                ( <s>-SupplementId ) ).

    DATA(lt_invalid_ids) = zcl_travel_validations=>find_invalid_supplements( lt_supplement_ids ).

    LOOP AT suppls INTO DATA(suppl).
      IF suppl-SupplementId IS INITIAL.
        APPEND VALUE #( %tky = suppl-%tky ) TO failed-booksupplement.
        APPEND VALUE #( %tky = suppl-%tky
                        %msg = new_message(
                            id = zif_travel_messages=>c_msgid
                            number = zif_travel_messages=>c_supplement_required
                            severity = if_abap_behv_message=>severity-error ) ) TO reported-booksupplement.
        CONTINUE.
      ENDIF.

      IF line_exists( lt_invalid_ids[ table_line = suppl-SupplementId ] ).
        APPEND VALUE #( %tky = suppl-%tky ) TO failed-booking.
        APPEND VALUE #( %tky = suppl-%tky
                        %msg = new_message(
                            id = zif_travel_messages=>c_msgid
                            number = zif_travel_messages=>c_supplement_not_found
                            severity = if_abap_behv_message=>severity-error
                            v1 = suppl-SupplementId ) ) TO reported-booksupplement.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD calculatetotalprice.

    DATA lt_travel_keys TYPE zcl_travel_calculations=>tt_travel_keys.

    LOOP AT keys INTO DATA(ls_key).

      APPEND VALUE #( %tky-TravelId = ls_key-TravelId
                      %tky-%is_draft = ls_key-%is_draft ) TO lt_travel_keys.

    ENDLOOP.

    zcl_travel_calculations=>recalculate_total_price( lt_travel_keys ).

  ENDMETHOD.

ENDCLASS.
