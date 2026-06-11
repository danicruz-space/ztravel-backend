@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Coordenadas da tabela Airport'
@Metadata.ignorePropagatedAnnotations: true
define view entity Z_I_AIRPORT_GEO as select from /dmo/airport as Airport
left outer join zairport_geo as _Geo on Airport.airport_id = _Geo.airport_id
{
    key Airport.airport_id as AirportID,
    @Semantics.text: true
    Airport.name as Name,
    Airport.city as City,
    Airport.country as Country,
          
    @Semantics.geoLocation.latitude: true
    _Geo.latitude      as Latitude,
    @Semantics.geoLocation.latitude: true
    _Geo.longitude     as Longitude    
}
