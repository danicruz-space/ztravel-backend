INTERFACE zif_travel_status
  PUBLIC.

  CONSTANTS:
    new       TYPE /dmo/travel_status VALUE 'N',
    planned   TYPE /dmo/travel_status VALUE 'P',
    booked    TYPE /dmo/travel_status VALUE 'B',
    cancelled TYPE /dmo/travel_status VALUE 'X'.

ENDINTERFACE.
