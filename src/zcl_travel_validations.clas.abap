CLASS zcl_travel_validations DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES tt_customer_id TYPE STANDARD TABLE OF /dmo/customer_id WITH EMPTY KEY.
    TYPES tt_agency_id TYPE STANDARD TABLE OF /dmo/agency_id WITH EMPTY KEY.
    TYPES tt_currency_code TYPE STANDARD TABLE OF /dmo/currency_code WITH EMPTY KEY.
    TYPES: BEGIN OF ts_flight_key,
         carrier_id    TYPE /dmo/carrier_id,
         connection_id TYPE /dmo/connection_id,
         flight_date   TYPE /dmo/flight_date,
       END OF ts_flight_key,
       tt_flight_key TYPE STANDARD TABLE OF ts_flight_key WITH EMPTY KEY.
    TYPES tt_supplement_id TYPE STANDARD TABLE OF /dmo/supplement_id WITH EMPTY KEY.

    CLASS-METHODS find_invalid_customers
        IMPORTING
            it_customers TYPE tt_customer_id
        RETURNING VALUE(rt_invalid) TYPE tt_customer_id.

    CLASS-METHODS find_invalid_agencys
        IMPORTING
            it_agencys TYPE tt_agency_id
        RETURNING VALUE(rt_invalid) TYPE tt_agency_id.

    CLASS-METHODS find_invalid_currencys
        IMPORTING
            it_currencys TYPE tt_currency_code
        RETURNING VALUE(rt_invalid) TYPE tt_currency_code.

    CLASS-METHODS find_invalid_flights
        IMPORTING
            it_flights TYPE tt_flight_key
        RETURNING VALUE(rt_invalid) TYPE tt_flight_key.

    CLASS-METHODS find_invalid_supplements
        IMPORTING
            it_supplement_ids TYPE tt_supplement_id
        RETURNING VALUE(rt_invalid) TYPE tt_supplement_id.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_travel_validations IMPLEMENTATION.

    METHOD find_invalid_customers.

        IF it_customers IS INITIAL.
            RETURN.
        ENDIF.

        SELECT CustomerID
            FROM /DMO/I_Customer
            FOR ALL ENTRIES IN @it_customers
            WHERE CustomerID = @it_customers-table_line
            INTO TABLE @DATA(lt_existing).


       rt_invalid = it_customers.
       LOOP AT lt_existing INTO DATA(lv_existing).
        DELETE rt_invalid WHERE table_line = lv_existing-CustomerID.
       ENDLOOP.

    ENDMETHOD.

    METHOD find_invalid_agencys.

        IF it_agencys IS INITIAL.
            RETURN.
        ENDIF.

        SELECT AgencyID
            FROM /DMO/I_Agency
            FOR ALL ENTRIES IN @it_agencys
            WHERE AgencyID = @it_agencys-table_line
            INTO TABLE @DATA(lt_existing).


       rt_invalid = it_agencys.
       LOOP AT lt_existing INTO DATA(lv_existing).
        DELETE rt_invalid WHERE table_line = lv_existing-AgencyID.
       ENDLOOP.

    ENDMETHOD.

    METHOD find_invalid_currencys.
        IF it_currencys IS INITIAL.
            RETURN.
        ENDIF.

        SELECT Currency
            FROM I_Currency
            FOR ALL ENTRIES IN @it_currencys
            WHERE Currency = @it_currencys-table_line
            INTO TABLE @DATA(lt_existing).


       rt_invalid = it_currencys.
       LOOP AT lt_existing INTO DATA(lv_existing).
        DELETE rt_invalid WHERE table_line = lv_existing-Currency.
       ENDLOOP.

    ENDMETHOD.

    METHOD find_invalid_flights.

        IF it_flights IS INITIAL.
            RETURN.
        ENDIF.

        SELECT carrier_id, connection_id
            FROM /dmo/flight
            FOR ALL ENTRIES IN @it_flights
            WHERE carrier_id = @it_flights-carrier_id
                AND connection_id = @it_flights-connection_id
            INTO TABLE @DATA(lt_existing).

        rt_invalid = it_flights.
        LOOP AT lt_existing INTO DATA(ls_exist).
            DELETE rt_invalid WHERE carrier_id = ls_exist-carrier_id AND connection_id = ls_exist-connection_id.
        ENDLOOP.
    ENDMETHOD.

    METHOD find_invalid_supplements.

        IF it_supplement_ids IS INITIAL.
            RETURN.
        ENDIF.

        SELECT supplement_id
            FROM /dmo/supplement
            FOR ALL ENTRIES IN @it_supplement_ids
            WHERE supplement_id = @it_supplement_ids-table_line
            INTO TABLE @DATA(lt_existing).

            rt_invalid = it_supplement_ids.
            LOOP AT lt_existing INTO DATA(lv_existing).
                DELETE rt_invalid WHERE table_line = lv_existing-supplement_id.
            ENDLOOP.

    ENDMETHOD.

ENDCLASS.
