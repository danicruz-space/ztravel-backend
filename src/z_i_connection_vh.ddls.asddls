@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Fuzzy search para connection id'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
define view entity Z_I_CONNECTION_VH as select from /dmo/connection
{
  @ObjectModel.text.element: ['airportToId']
  @UI.textArrangement: #TEXT_ONLY
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.1
  key connection_id as ConnectionId,

  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.7
  @Semantics.text: true
  airport_to_id as airportToId,
  
  
  airport_from_id as airportFromId
    
}
