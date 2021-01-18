create or replace package csf_own.pk_int_view_d100 is

-------------------------------------------------------------------------------------------------------------------
--
-- Especifica��o do pacote de procedimentos de integra��o e valida��o de Invent�rio
--
-- Em 28/12/2020   - Eduardo Linden
-- Redmine #74671  - Inclus�o do Flexfield UNID_ORG - VW_CSF_CONHEC_TRANSP_EFD_FF
-- Rotinas alteradas -pkb_conhec_transp => Inclus�o do novo parametro ev_cd_unid_org na rotina pk_csf_api_d100.pkb_integr_ct_d100
--
-- Em 18/09/2020   - Luis Marques - 2.9.5
-- Redmine #70848  - Implementar Diferencial de Al�quota para CTE - Aviva
-- Nova Rotina     - pkb_ct_dif_aliq - Rotina para integrar valores de diferencial de aliquota do conhecimento.
-- Rotina Alterada - pkb_conhec_transp - Incluida chamada para rotina "pkb_ct_dif_aliq".
--
-- Em 28/10/2019 - Renan Alves 
-- Redmine #59681 - Tela e Relat�rio CTE de Terceiro
-- Foi incluido a chamada da procedure pkb_ler_ct_inf_nfe na rotina que realizar a integra��o 
-- Rotina: pkb_conhec_transp
--
-- Em 24/10/2019 - Marcos Ferreira
-- Redmine #59724 - Erro de valida��o no CTe mesmo com os dados
-- Rotina Alterada: pkb_ler_conhec_transp_ff - Inclu�do TRIM na valida��o do valor do atributo da Flex-Field.
--
-- Em 25/08/2019 - Luis Marques
-- Redmine #59148 - Constru��o de inclus�o dos dados do emitente para Open Interface.
-- Rotina Incluida: pkb_conhec_transp_emit - Rotina para inclus�o dos dados do emitente do conhecimento.
-- Rotina alterada: pkb_conhec_transp - Incluida chamada da rotina pkb_conhec_transp_emit.
--
-- Em 07/08/2019 - Luis Marques
-- Redmine #56568 - Mensagem de erro de valida��o para CT-e sem origem e destino
-- Rotina Alterada: pkb_ler_conhec_transp_ff
--                  Verifica��o de dados do municipio origem/destino foram informados
--
-- Em 26/07/2019 - Luis Marques
-- Redmine #56729 - feed - CT-e e NFS-e ainda ficam com erro de valida��o
-- Rotina Alterada: pkb_conhec_transp
--                  Ajuistado para se contiver s� aviso er informa��o na deixa o conhecimento como n�o validado
--
-- Em 23/07/2019 - Luis Marques
-- Redmine #56565 - feed - Mensagem de ADVERTENCIA est� deixando documento com ERRO DE VALIDA��O
-- Rotina alterada: pkb_conhec_transp
--                  Alterado para colocar verifica��o de falta de Codigo de base de calculo de PIS/COFINS
--                  como advertencia.
--
-- Em 18/01/2012 - Angela In�s.
-- Acertar a vari�vel nas rotinas de pis e cofins para inicializa��o.
--
-- Em 19/12/2012 - Angela In�s.
-- Ficha HD 64591 - Implementar os campos flex field para a integra��o de Conhecimento de Transporte: ct_reg_anal.
--
-- Em 28/12/2012 - Angela In�s.
-- Ficha HD 65154 - Fechamento Fiscal por empresa.
-- Verificar a data de �ltimo fechamento fiscal, n�o permitindo integrar se a data estiver posterior ao per�odo em quest�o.
--
-- Em 26/07/2013 - Angela In�s.
-- Redmine #405 - Leiaute: Conhec. Transporte: Implementar no complemento de Pis/Cofins o c�digo da natureza de receita isenta - Campos Flex Field.
-- Rotinas: pkb_ct_comp_doc_pis_efd_ff e pkb_ct_comp_doc_cofins_efd_ff.
--
-- Em 26/02/2014 - Angela In�s.
-- Redmine #2087 - Passar a gerar log no agendamento quando a data do documento estiver no per�odo da data de fechamento.
-- Rotina: pkb_conhec_transp.
--
-- Em 05/11/2014 - Rog�rio Silva
-- Redmine #5020 - Processo de contagem de registros integrados do ERP (Agendamento de integra��o)
--
-- Em 12/10/2014 - Rog�rio Silva
-- Redmine #5508 - Desenvolver tratamento no processo de contagem de dados
--
-- Em 06/01/2015 - Angela In�s.
-- Redmine #5616 - Adequa��o dos objetos que utilizam dos novos conceitos de Mult-Org.
-- Corre��o na chamada da rotina de integra��o trocando o par�metro de entrada de CNPJ para EMPRESA_ID.
--
-- Em 01/06/2015 - Rog�rio Silva
-- Redmine #8230 - Processo de Registro de Log em Packages - Conhecimento de Transporte
--
-- Em 31/07/2015 - Angela In�s.
-- Redmine #9513 - Substituir a tabela de nota fiscal pela tabela de conhecimento de transporte, coluna dm_st_proc.
-- Rotina: pkb_conhec_transp.
--
-- Em 17/08/2015 - Angela In�s.
-- Redmine #10117 - Escritura��o de documentos fiscais - Processos.
-- Inclus�o do novo conceito de recupera��o de data dos documentos fiscais para retorno dos registros.
--
-- Em 22/02/2017 - F�bio Tavares
-- Redmine #28662 - Registros do Agendamento de Integra��o
-- Rotina: pkb_integr_periodo_geral.
--
-- Em 01/03/2017 - Leandro Savenhago
-- Redmine 28832- Implementar o "Par�metro de Formato de Data Global para o Sistema".
-- Implementar o "Par�metro de Formato de Data Global para o Sistema".
--
-- Em 16/06/2017 - Marcos Garcia
-- Redmine #30475 - Avalia��es nos Processos de Integra��o e Relat�rios de Inconsist�ncias - Processo de Fechamento Fiscal.
-- Atividade: Parametriza��o do log com o tipo 39-fechamento fiscal
--            referencia_id nula, obj_referencia = a tabela atual no momento da integra��o e a empresa solicitante da integra��o.
--            Log de fechamento fiscal aparecer� nos relat�rios de integra��o.
--
--  Em 30/06/2017 - Leandro Savenhago
-- Redmine #31839 - CRIA��O DOS OBJETOS DE INTEGRA��O - STAFE
-- Cria��o do Procedimento PKB_STAFE
--
-- Em 19/07/2017 - Marcos Garcia
-- Redmine# 30475 - Avalia��es nos Processos de Integra��o e Relat�rios de Inconsist�ncias - Processo de Fechamento Fiscal.
-- Cria��o da variavel global info_fechamento, que � alimentada antes do inicio das integra��es
-- com o identificador do fechamento fiscal.(csf_tipo_log).
--
-- Em 26/02/2018 - Angela In�s.
-- Redmine #39446 - Adequa��o de View X Tabela - CTe.
-- Alterado o tamanho da coluna COD_CTA de 30 caracteres para 60 caracteres.
-- Vari�vel global: vt_tab_csf_conhec_tranp_efd.cod_cta.
--
-- Em 25/08/2018 - Angela In�s.
-- Redmine #46371 - Agendamento de Integra��o cujo Tipo seja "Todas as Empresas".
-- Incluir o identificador do Mult-Org como par�metro de entrada (mult_org.id), para Agendamento de Integra��o como sendo do Tipo "Todas as Empresas".
-- Rotina: pkb_integr_periodo_geral.
--
-- Em 30/10/2018 - Karina de Paula
-- Redmine #47549 - Adaptar packages de integra��o
-- Rotina Criada: pkb_ct_imp_ret_efd e pkb_ct_imp_ret_efd_ff
-- Rotina Alterada: pkb_conhec_transp => Inclu�da a chamada da pkb_ct_imp_ret_efd
--
-------------------------------------------------------------------------------------------------------------------

-- Especifica��o de array

--| Informa��es do Registro D100
   type tab_csf_conhec_tranp_efd is record ( cpf_cnpj_emit  varchar2(14)
                                           , dm_ind_emit    number(1)
                                           , dm_ind_oper    number(1)
                                           , cod_part       varchar2(60)
                                           , cod_mod        varchar2(2)
                                           , serie          varchar2(3)
                                           , subserie       number(3)
                                           , nro_nf         number(9)
                                           , sit_docto      varchar2(2)
                                           , nro_chave_cte  varchar2(44)
                                           , dm_tp_cte      number(1)
                                           , chave_cte_ref  varchar2(44)
                                           , dt_emiss       date
                                           , dt_sai_ent     date
                                           , vl_doc         number(15,2)
                                           , vl_desc        number(15,2)
                                           , dm_ind_frt     number(1)
                                           , vl_serv        number(15,2)
                                           , vl_bc_icms     number(15,2)
                                           , vl_icms        number(15,2)
                                           , vl_nt          number(15,2)
                                           , cod_inf        varchar2(6)
                                           , cod_cta        varchar2(60)
                                           , cod_nat_oper   varchar2(10)
                                           );
--
   type t_tab_csf_conhec_tranp_efd is table of tab_csf_conhec_tranp_efd index by binary_integer;
   vt_tab_csf_conhec_tranp_efd t_tab_csf_conhec_tranp_efd;
--
--| Informa��o do Registro D190
   type tab_csf_reg_ct_efd is record ( cpf_cnpj_emit   varchar2(14)
                                     , dm_ind_emit     number(1)
                                     , dm_ind_oper     number(1)
                                     , cod_part        varchar2(60)
                                     , cod_mod         varchar2(2)
                                     , serie           varchar2(3)
                                     , subserie        number(3)
                                     , nro_nf          number(9)
                                     , cst_icms        varchar2(2)
                                     , dm_orig_merc    number(1)
                                     , cfop            number(4)
                                     , aliq_icms       number(5,2)
                                     , vl_operacao     number(15,2)
                                     , vl_bc_icms      number(15,2)
                                     , vl_icms         number(15,2)
                                     , vl_bc_icms_st   number(15,2)
                                     , vl_icms_st      number(15,2)
                                     , vl_red_bc_icms  number(15,2)
                                     , cod_obs         varchar2(6) );
--
   type t_tab_csf_reg_ct_efd is table of tab_csf_reg_ct_efd index by binary_integer;
   vt_tab_csf_reg_ct_efd t_tab_csf_reg_ct_efd;
--
--| Informa��o do Registro D190 - Campos Flex Field
   type tab_csf_reg_ct_efd_ff is record ( cpf_cnpj_emit   varchar2(14)
                                        , dm_ind_emit     number(1)
                                        , dm_ind_oper     number(1)
                                        , cod_part        varchar2(60)
                                        , cod_mod         varchar2(2)
                                        , serie           varchar2(3)
                                        , subserie        number(3)
                                        , nro_nf          number(9)
                                        , cst_icms        varchar2(2)
                                        , dm_orig_merc    number(1)
                                        , cfop            number(4)
                                        , aliq_icms       number(5,2)
                                        , atributo        varchar2(30)
                                        , valor           varchar2(255) );
--
   type t_tab_csf_reg_ct_efd_ff is table of tab_csf_reg_ct_efd_ff index by binary_integer;
   vt_tab_csf_reg_ct_efd_ff t_tab_csf_reg_ct_efd_ff;
--
--| Informa��o do Complemento da opera��o de PIS/PASEP
   type tab_csf_ctcompdoc_pisefd is record ( cpf_cnpj_emit   varchar2(14)
                                           , dm_ind_emit     number(1)
                                           , dm_ind_oper     number(1)
                                           , cod_part        varchar2(60)
                                           , cod_mod         varchar2(2)
                                           , serie           varchar2(3)
                                           , subserie        number(3)
                                           , nro_nf          number(9)
                                           , cst_pis         varchar2(2)
                                           , dm_ind_nat_frt  number(1)
                                           , vl_item         number(15,2)
                                           , cod_bc_cred_pc  varchar2(2)
                                           , vl_bc_pis       number(15,2)
                                           , aliq_pis        number(8,4)
                                           , vl_pis          number(15,2)
                                           , cod_cta         varchar2(60) );
--
   type t_tab_csf_ctcompdoc_pisefd is table of tab_csf_ctcompdoc_pisefd index by binary_integer;
   vt_tab_csf_ctcompdoc_pisefd t_tab_csf_ctcompdoc_pisefd;
--
--| Informa��o do Complemento da opera��o de PIS/PASEP - Campos Flex Field
   type tab_csf_ctcompdocpisefd_ff is record ( cpf_cnpj_emit   varchar2(14)
                                              , dm_ind_emit     number(1)
                                              , dm_ind_oper     number(1)
                                              , cod_part        varchar2(60)
                                              , cod_mod         varchar2(2)
                                              , serie           varchar2(3)
                                              , subserie        number(3)
                                              , nro_nf          number(9)
                                              , cst_pis         varchar2(2)
                                              , atributo        varchar2(30)
                                              , valor           varchar2(255) );
--
   type t_tab_csf_ctcompdocpisefd_ff is table of tab_csf_ctcompdocpisefd_ff index by binary_integer;
   vt_tab_csf_ctcompdocpisefd_ff t_tab_csf_ctcompdocpisefd_ff;
--
--| Informa��o do Complemento da opera��o de COFINS
   type tab_csf_ctcompdoc_cofinsefd is record ( cpf_cnpj_emit   varchar2(14)
                                              , dm_ind_emit     number(1)
                                              , dm_ind_oper     number(1)
                                              , cod_part        varchar2(60)
                                              , cod_mod         varchar2(2)
                                              , serie           varchar2(3)
                                              , subserie        number(3)
                                              , nro_nf          number(9)
                                              , cst_cofins      varchar2(2)
                                              , dm_ind_nat_frt  number(1)
                                              , vl_item         number(15,2)
                                              , cod_bc_cred_pc  varchar2(2)
                                              , vl_bc_cofins    number(15,2)
                                              , aliq_cofins     number(8,4)
                                              , vl_cofins       number(15,2)
                                              , cod_cta         varchar2(60) );
--
   type t_tab_csf_ctcompdoc_cofinsefd is table of tab_csf_ctcompdoc_cofinsefd index by binary_integer;
   vt_tab_csf_ctcompdoc_cofinsefd t_tab_csf_ctcompdoc_cofinsefd;
--
--| Informa��o do Complemento da opera��o de COFINS - Campos Flex Field
   type tab_csf_ctcompdoccofefd_ff is record ( cpf_cnpj_emit   varchar2(14)
                                             , dm_ind_emit     number(1)
                                             , dm_ind_oper     number(1)
                                             , cod_part        varchar2(60)
                                             , cod_mod         varchar2(2)
                                             , serie           varchar2(3)
                                             , subserie        number(3)
                                             , nro_nf          number(9)
                                             , cst_cofins      varchar2(2)
                                             , atributo        varchar2(30)
                                             , valor           varchar2(255) );
--
   type t_tab_csf_ctcompdoccofefd_ff is table of tab_csf_ctcompdoccofefd_ff index by binary_integer;
   vt_tab_csf_ctcompdoccofefd_ff t_tab_csf_ctcompdoccofefd_ff;
--
--| Informa��o do Processo referenciado
   type tab_csf_ctprocrefefd is record ( cpf_cnpj_emit   varchar2(14)
                                       , dm_ind_emit     number(1)
                                       , dm_ind_oper     number(1)
                                       , cod_part        varchar2(60)
                                       , cod_mod         varchar2(2)
                                       , serie           varchar2(3)
                                       , subserie        number(3)
                                       , nro_nf          number(9)
                                       , num_proc        varchar2(20)
                                       , orig_proc       number(1) );
--
   type t_tab_csf_ctprocrefefd is table of tab_csf_ctprocrefefd index by binary_integer;
   vt_tab_csf_ctprocrefefd t_tab_csf_ctprocrefefd;
--
--| Informa��o Fiscal do CT
   type tab_csf_ctinfor_fiscal_efd is record ( cpf_cnpj_emit   varchar2(14)
                                             , dm_ind_emit     number(1)
                                             , dm_ind_oper     number(1)
                                             , cod_part        varchar2(60)
                                             , cod_mod         varchar2(2)
                                             , serie           varchar2(3)
                                             , subserie        number(3)
                                             , nro_nf          number(9)
                                             , cod_obs         varchar2(6)
                                             , txt_compl       varchar2(255) );
--
   type t_tab_csf_ctinfor_fiscal_efd is table of tab_csf_ctinfor_fiscal_efd index by binary_integer;
   vt_tab_csf_ctinfor_fiscal_efd t_tab_csf_ctinfor_fiscal_efd;
--
--| Informa��o de ajustes e de valores provenientes do CT
   type tab_csf_ct_inf_prov_efd is record ( cpf_cnpj_emit   varchar2(14)
                                          , dm_ind_emit     number(1)
                                          , dm_ind_oper     number(1)
                                          , cod_part        varchar2(60)
                                          , cod_mod         varchar2(2)
                                          , serie           varchar2(3)
                                          , subserie        number(3)
                                          , nro_nf          number(9)
                                          , cod_obs         varchar2(6)
                                          , cod_aj          varchar2(10)
                                          , descr_compl_aj  varchar2(255)
                                          , vl_bc_icms      number(15,2)
                                          , aliq_icms       number(5,2)
                                          , vl_icms         number(15,2)
                                          , vl_outros       number(15,2) );
--
   type t_tab_csf_ct_inf_prov_efd is table of tab_csf_ct_inf_prov_efd index by binary_integer;
   vt_tab_csf_ct_inf_prov_efd t_tab_csf_ct_inf_prov_efd;
--
--| Informa��es FlexField do Registro D100
   type tab_csf_conhec_tranp_efd_ff is record ( cpf_cnpj_emit    varchar2(14)
                                              , dm_ind_emit      number(1)
                                              , dm_ind_oper      number(1)
                                              , cod_part         varchar2(60)
                                              , cod_mod          varchar2(2)
                                              , serie            varchar2(3)
                                              , subserie         number(3)
                                              , nro_nf           number(9)
                                              , atributo         varchar2(30)
                                              , valor            varchar2(255)
                                              );
--
   type t_tab_csf_conhec_tranp_efd_ff is table of tab_csf_conhec_tranp_efd_ff index by binary_integer;
   vt_tab_csf_conhec_tranp_efd_ff t_tab_csf_conhec_tranp_efd_ff;
--
--| Informa��o dos impostos retidos
   type tab_csf_ctimpretefd is record ( cpf_cnpj_emit   varchar2(14)
                                      , dm_ind_emit     number(1)
                                      , dm_ind_oper     number(1)
                                      , cod_part        varchar2(60)
                                      , cod_mod         varchar2(2)
                                      , serie           varchar2(3)
                                      , subserie        number(3)
                                      , nro_nf          number(9)
                                      , cod_imposto     number(3)
                                      , cd_tipo_ret_imp varchar2(10)
                                      , cod_receita     varchar2(2)
                                      , vl_item         number(15,2)
                                      , vl_base_calc    number(15,2)
                                      , vl_aliq         number(15,2)
                                      , vl_imp          number(15,2)
                                      );
--
   type t_tab_csf_ctimpretefd is table of tab_csf_ctimpretefd index by binary_integer;
   vt_tab_csf_ctimpretefd t_tab_csf_ctimpretefd;
--
--| Informa��o dos impostos retidos - Campos Flex Field
   type tab_csf_ctimpretefd_ff is record ( cpf_cnpj_emit   varchar2(14)
                                         , dm_ind_emit     number(1)
                                         , dm_ind_oper     number(1)
                                         , cod_part        varchar2(60)
                                         , cod_mod         varchar2(2)
                                         , serie           varchar2(3)
                                         , subserie        number(3)
                                         , nro_nf          number(9)
                                         , cod_imposto     number(3)
                                         , atributo        varchar2(30)
                                         , valor           varchar2(255) );
--
   type t_tab_csf_ctimpretefd_ff is table of tab_csf_ctimpretefd_ff index by binary_integer;
   vt_tab_csf_ctimpretefd_ff t_tab_csf_ctimpretefd_ff;
--
--| Informa��o do emitente do conhecimento
   type tab_csf_conhec_transp_emit is record ( cpf_cnpj_emit varchar2(14)
                                             , dm_ind_emit   number(1)
                                             , dm_ind_oper   number(1)
                                             , cod_part      varchar2(60)
                                             , cod_mod       varchar2(2)
                                             , serie         varchar2(3)
                                             , nro_ct        number(9)
                                             , ie            varchar2(14)
                                             , nome          varchar2(60)
                                             , nome_fant     varchar2(60)
                                             , lograd        varchar2(60)
                                             , nro           varchar2(60)
                                             , compl         varchar2(60)
                                             , bairro        varchar2(60)
                                             , ibge_cidade   number(7)
                                             , descr_cidade  varchar2(60)
                                             , cep           varchar2(8)
                                             , uf            varchar2(2)
                                             , cod_pais      number(4)
                                             , descr_pais    varchar2(60)
                                             , fone          number(14)
                                             , dm_ind_sn     number(1)
                                             , cnpj          varchar2(14) );
--
   type t_tab_csf_conhec_transp_emit is table of tab_csf_conhec_transp_emit index by binary_integer;
   vt_tab_csf_conhec_transp_emit t_tab_csf_conhec_transp_emit;
--
--| Informa��es das NF-e do Conhecimento de Transporte: VW_CSF_CT_INF_NFE
   -- N�vel 1
   type tab_csf_ct_inf_nfe is record (cpf_cnpj_emit  varchar2(14),
                                      dm_ind_emit   number(1),
                                      dm_ind_oper   number(1),
                                      cod_part	    varchar2(60),
                                      cod_mod	      varchar2(2),
                                      serie	        varchar2(3),
                                      nro_ct        number(9),
                                      nro_chave_nfe varchar2(44),
                                      pin           number(9),
                                      dt_prev_ent   date);
   --
   type t_tab_csf_ct_inf_nfe is table of tab_csf_ct_inf_nfe index by binary_integer;
   vt_tab_csf_ct_inf_nfe t_tab_csf_ct_inf_nfe;
--
--| Informa��o do Diferencial de Aliquota
   type tab_csf_ct_dif_aliq is record ( cpf_cnpj_emit   varchar2(14)
                                      , dm_ind_emit     number(1)
                                      , dm_ind_oper     number(1)
                                      , cod_part        varchar2(60)
                                      , cod_mod         varchar2(2)
                                      , serie           varchar2(3)
                                      , subserie        number(3)
                                      , nro_nf          number(9)									  
                                      , aliq_interna    number(5,2)
                                      , aliq_ie         number(5,2)
                                      , bc_dif_aliq     number(15,2)
                                      , vl_dif_aliq     number(15,2)
                                      , bc_fcp          number(15,2)
                                      , aliq_fcp        number(5,2)
                                      , vl_fcp          number(15,2)
                                      , dm_tipo         number(1) );
--
   type t_tab_csf_ct_dif_aliq is table of tab_csf_ct_dif_aliq index by binary_integer;
   vt_tab_csf_ct_dif_aliq t_tab_csf_ct_dif_aliq;   
-------------------------------------------------------------------------------------------------------

   GV_ASPAS            CHAR(1) := null;
   GV_NOME_DBLINK      empresa.nome_dblink%type := null;
   GV_FORMATO_DT_ERP   empresa.FORMATO_DT_ERP%type := null;
   GV_OWNER_OBJ        empresa.owner_obj%type := null;

-------------------------------------------------------------------------------------------------------

-- Declara��o de constantes

   ERRO_DE_VALIDACAO   CONSTANT NUMBER := 1;
   ERRO_DE_SISTEMA     CONSTANT NUMBER := 2;
   INFORMACAO          CONSTANT NUMBER := 35;

-------------------------------------------------------------------------------------------------------

   gv_sql              varchar2(4000) := null;
   gv_cabec_log        log_generico_ct.mensagem%TYPE;
   gv_mensagem_log     log_generico_ct.mensagem%TYPE;
   gv_obj_referencia   log_generico_ct.obj_referencia%type := 'CONHEC_TRANSP';
   gn_referencia_id    log_generico_ct.referencia_id%type := null;
   gv_resumo           log_generico.resumo%type;
   gv_cabec_ct         varchar2(4000) := null;
   gv_cd_obj           obj_integr.cd%type := '4';
   gn_multorg_id       mult_org.id%type;
   gv_formato_data     param_global_csf.valor%type := null;
   gn_empresa_id       empresa.id%type;
   --
   info_fechamento     number;

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integra��o 
procedure pkb_integracao ( en_empresa_id in number
                         , ed_dt_ini     in date
                         , ed_dt_fin     in date );

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integra��o de conhecimento de transporte com todas as empresas

procedure pkb_integracao_normal ( ed_dt_ini      in date
                                , ed_dt_fin      in date
                                );

-------------------------------------------------------------------------------------------------------

-- Processo de integra��o por per�odo e informando todas as empresas ativas

procedure pk_integr_periodo_geral ( en_multorg_id in mult_org.id%type
                                  , ed_dt_ini     in date
                                  , ed_dt_fin     in date );

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integra��o Geral de empresas para o CT
procedure pkb_integr_geral_empresa ( en_paramintegrdados_id in param_integr_dados.id%type
                                   , ed_dt_ini in date
                                   , ed_dt_fin in date
                                   , en_empresa_id in empresa.id%type
                                   );

-------------------------------------------------------------------------------------------------------
end pk_int_view_d100;
/
