@EndUserText.label: 'Confirmação'
define abstract entity Z_A_TRAVEL_CONFIRM
{
  @UI.hidden: true
  @EndUserText.label: 'Tem a certeza que pretende prosseguir com esta operação?'
  dummy : abap.char(1);
}
