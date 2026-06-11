@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Fuzzy search para supplement id'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
define view entity Z_I_BOOKSUPP_VH as select from /dmo/suppl_text
{
  @ObjectModel.text.element: ['Description']
  @UI.textArrangement: #TEXT_ONLY
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.7
  key supplement_id as SupplementId,

  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.7
  @Semantics.text: true
  description as Description
      
}
