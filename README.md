# ztravel-backend

Backend da aplicação **ztravel.app**, desenvolvida em **SAP ABAP RAP** durante o estágio curricular da Licenciatura em Engenharia de Sistemas Informáticos (IPCA), na empresa Lykosit.

## Descrição

O *ztravel.app* é uma aplicação de gestão de viagens construída sobre o modelo **ABAP RESTful Application Programming Model (RAP)** e exposta através de um serviço **OData V4**, com frontend em **SAP Fiori Elements**. Este repositório contém o **backend**: o modelo de dados, a lógica de negócio e a exposição do serviço.

## Tecnologias

- SAP S/4HANA
- ABAP e ABAP RAP (managed, com *save* unmanaged, *draft* e numeração antecipada)
- Core Data Services (CDS Views)
- OData V4

## Arquitetura

- **Tabelas:** ZTRAVEL_D, ZBOOKING_D, ZBOOKSUPPL_D, ZAIRPORT_GEO, ZCOUNTRY_FEES, ZSUPPL
- **CDS de interface:** Z_I_TRAVEL, Z_I_BOOKING, Z_I_BOOKSUPPLEMENT, Z_I_SUPPL_CAT, Z_I_AIRPORT_GEO
- **CDS de consumo:** Z_C_TRAVEL, Z_C_BOOKING, Z_C_BOOKSUPPLEMENT
- **Ajudas de pesquisa:** Z_I_AGENCY_VH, Z_I_CUSTOMER_VH, Z_I_CARRIER_VH, Z_I_CONNECTION_VH, Z_I_BOOKSUPP_VH, Z_I_STATUS_VH
- **Comportamento RAP:** Behavior Definitions Z_I_TRAVEL e Z_C_TRAVEL; classes ZBP_I_TRAVEL, ZCL_TRAVEL_CALCULATIONS, ZCL_TRAVEL_VALIDATIONS
- **Mensagens:** classe ZMSG_TRAVEL; interfaces ZIF_TRAVEL_MESSAGES e ZIF_TRAVEL_STATUS
- **Serviço:** Service Definition Z_UI_TRAVEL_V4 e Service Binding Z_UI_TRAVEL_V4_O4 (OData V4)

## Funcionalidades

- Ciclo de vida transacional completo, com *draft*
- Determinações, validações e ações (aceitar, reservar, cancelar e aplicar desconto)
- Arquitetura de mensagens e exceções centralizada
- Ajudas de pesquisa e internacionalização

## Estrutura

O código está serializado no formato **abapGit**, na pasta `src/`.

## Frontend

O frontend em SAP Fiori Elements encontra-se no repositório: [ztravel-app](https://github.com/danicruz-space/ztravel-frontend)

## Autor

Dani Carvalho da Cruz — Estágio curricular na Lykosit, Licenciatura em Engenharia de Sistemas Informáticos, IPCA, 2026.
