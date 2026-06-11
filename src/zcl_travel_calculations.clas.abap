CLASS zcl_travel_calculations DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    TYPES tt_travel_keys TYPE TABLE FOR READ IMPORT z_i_travel\\Travel.

    CLASS-METHODS recalculate_total_price
      IMPORTING it_travel_keys TYPE tt_travel_keys.
ENDCLASS.


CLASS zcl_travel_calculations IMPLEMENTATION.

  METHOD recalculate_total_price.

    DATA lt_travel_keys LIKE it_travel_keys.
    lt_travel_keys = it_travel_keys.

    SORT lt_travel_keys BY %tky.
    DELETE ADJACENT DUPLICATES FROM lt_travel_keys COMPARING %tky.

    IF lt_travel_keys IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF z_i_travel IN LOCAL MODE
      ENTITY Travel
      FIELDS ( BookingFee )
      WITH CORRESPONDING #( lt_travel_keys )
      RESULT DATA(lt_travels).

    READ ENTITIES OF z_i_travel IN LOCAL MODE
      ENTITY Travel BY \_Booking
      FIELDS ( FlightPrice )
      WITH CORRESPONDING #( lt_travels )
      LINK DATA(lt_link_booking)
      RESULT DATA(lt_all_bookings).

    READ ENTITIES OF z_i_travel IN LOCAL MODE
      ENTITY Booking BY \_BookSupplement
      FIELDS ( Price )
      WITH CORRESPONDING #( lt_all_bookings )
      LINK DATA(lt_link_suppl)
      RESULT DATA(lt_all_suppls).

    DATA lt_updates TYPE TABLE FOR UPDATE z_i_travel\\Travel.

    LOOP AT lt_travels INTO DATA(ls_travel).
      DATA(lv_total_price) = ls_travel-BookingFee.

      LOOP AT lt_link_booking INTO DATA(ls_lb) WHERE source-%tky = ls_travel-%tky.
        READ TABLE lt_all_bookings INTO DATA(ls_booking) WITH KEY %tky = ls_lb-target-%tky.

        IF sy-subrc = 0.
          lv_total_price += ls_booking-FlightPrice.

          LOOP AT lt_link_suppl INTO DATA(ls_ls) WHERE source-%tky = ls_booking-%tky.
            READ TABLE lt_all_suppls INTO DATA(ls_suppl) WITH KEY %tky = ls_ls-target-%tky.
            IF sy-subrc = 0.
              lv_total_price += ls_suppl-Price.
            ENDIF.
          ENDLOOP.

        ENDIF.
      ENDLOOP.

      APPEND VALUE #( %tky = ls_travel-%tky
                      TotalPrice = lv_total_price ) TO lt_updates.
    ENDLOOP.

    IF lt_updates IS NOT INITIAL.
      MODIFY ENTITIES OF z_i_travel IN LOCAL MODE
        ENTITY Travel
        UPDATE FIELDS ( TotalPrice )
        WITH lt_updates.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
