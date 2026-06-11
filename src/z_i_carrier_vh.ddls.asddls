@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Fuzzy para carrier id'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
define view entity Z_I_CARRIER_VH as select from /dmo/carrier
{
  @ObjectModel.text.element: ['Name']
  @UI.textArrangement: #TEXT_ONLY
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.7
  key carrier_id as CarrierId,

  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.7
  @Semantics.text: true
  name as Name

}
