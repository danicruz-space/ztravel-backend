@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Connection com coordenadas geográficas'
@Metadata.ignorePropagatedAnnotations: true

define view entity Z_I_CONN_GEO as select from /dmo/connection as Connection
  association [0..1] to Z_I_AIRPORT_GEO as _OriginAirport on $projection.AirportFromId = _OriginAirport.AirportID
  association [0..1] to Z_I_AIRPORT_GEO as _DestinationAirport on $projection.AirportToId   = _DestinationAirport.AirportID
{
  key Connection.carrier_id      as CarrierId,
  key Connection.connection_id   as ConnectionId,
      Connection.airport_from_id as AirportFromId,
      Connection.airport_to_id   as AirportToId,
      Connection.departure_time  as DepartureTime,
      Connection.arrival_time    as ArrivalTime,

      _OriginAirport,
      _DestinationAirport
}
