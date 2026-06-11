@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help para Agência'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true

define view entity Z_I_AGENCY_VH as select from /dmo/agency
{
  @ObjectModel.text.element: ['Name']
  @UI.textArrangement: #TEXT_ONLY
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.7
  key agency_id as AgencyId,

  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.7
  @Semantics.text: true
  name as Name,

  street as Street,
  city as City,
  country_code as CountryCode
}
