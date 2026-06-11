@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help para Cliente'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true

define view entity Z_I_CUSTOMER_VH as select from /dmo/customer
{
  @ObjectModel.text.element: ['FirstName']
  @UI.textArrangement: #TEXT_ONLY
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.7
  key customer_id as CustomerId,

  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.7
  @Semantics.text: true
  first_name as FirstName,

  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.7
  @Semantics.text: true
  last_name as LastName,

  country_code as CountryCode,
  city as City
}
