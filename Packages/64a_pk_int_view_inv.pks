create or replace package csf_own.pk_int_view_inv is

-------------------------------------------------------------------------------------------------------
--
-- Especifica��o do pacote de procedimentos de integra��o e valida��o de Invent�rio
--
-- Em 07/12/2020   - Luis Marques - 2.9.5-4 / 2.9.6-1 / 2.9.6
-- Redmine #72072  - erro
-- Rotina Alterada - pkb_inventario - Colocdado verifica��o para quando tiver log de erro verificar se os log(s) do
--                   registro s�o s� de advertencia colocar como 1-Validado e n�o 2-Erro de valida��o.
--
-- Em 06/11/2020   - Luis Marques - 2.9.4-5 / 2.9.5-2 / 2.9.6
-- Redmine #72903  - Invent�rio integrado mas n�o mostra mensagem nos logs.
-- Rotina Alterada - pkb_inventario - Ajustando contador para mostrar a quantidade de registros com erro, (IF) bloqueado.
--
-- Em 30/10/2020   - Luis Marques - 2.9.4-5 / 2.9.5-2 / 2.9.6
-- Redmine #72903  - Invent�rio integrado mas n�o mostra mensagem nos logs.
-- Rotina Alterada - pkb_inventario - Colocado verifica��o com a data de ultimo fechamento se a data de referencia
--                   for nula usa a data de invent�rio na verifica��o com a data de ultimo fechamento.
--
-- Em 29/09/2020   - Luis Marques - 2.9.4-4 / 2.9.5-1 / 2.9.6
-- Redmine #71874  - Integra��o de dados do Invent�rio.
-- Rotina Alterada - pkb_inventario - Colocado no where de montagem do select se o campo DT_REF for nulo pega pelo
--                   campo DT_INVENTARIO da view de invent�rio.
--
-- Em 04/12/2019 - Luis Marques
-- Redmine #61686 - Adicionar valor ao dominio INVENTARIO.DM_MOT_INV
-- Rotina Alterada: pkb_inventario - Colocado trunc para data de referencia na leitura dos dados do invent�rio.
--
-- ====================================================================================================
-- Em 28/12/2012 - Angela In�s.
-- Ficha HD 65154 - Fechamento Fiscal por empresa.
-- Verificar a data de �ltimo fechamento fiscal, n�o permitindo integrar se a data estiver posterior ao per�odo em quest�o.
--
-- Em 14/01/2013 - Angela In�s.
-- Alterar a integra��o, considerando somente os registros com valor de item maior que zero (vw_csf_inventario.vl_item > 0).
--
-- Em 26/02/2014 - Angela In�s.
-- Redmine #2087 - Passar a gerar log no agendamento quando a data do documento estiver no per�odo da data de fechamento.
-- Rotina: pkb_inventario.
--
-- Em 16/10/2014 - Rog�rio Silva
-- Redmine #4067 - Processo de contagem de registros integrados do ERP (Agendamento de integra��o)
--
-- Em 21/10/2014 - Rog�rio Silva
-- Redmine #4067 - Processo de contagem de registros integrados do ERP (Agendamento de integra��o)
--
-- Em 12/10/2014 - Rog�rio Silva
-- Redmine #5508 - Desenvolver tratamento no processo de contagem de dados
--
-- Em 13/12/2014 - Leandro Savenhago
-- Redmine #5520 - Adequa��o da package pk_int_view_inv para Mult-Organiza��o
--
-- Em 14/04/2015 - Rog�rio Silva
-- Redmine #7650 - Analisar todos os processos de integra��o, corrigir a busca dos par�metros de empresa
-- Rotina: pkb_integracao
--
-- Em 17/04/2015 - Angela In�s.
-- Redmine #7763 - Registro H010 - Invent�rio - Processo de Integra��o.
-- Alterar o processo de integra��o de invent�rio considerando a view VW_CSF_INVENTARIO_FF. Considerar o novo campo VL_ITEM_IR.
-- Rotina: pkb_inventario_ff.
--
-- Em 27/05/2015 - Rog�rio Silva.
-- Redmine #8228 - Processo de Registro de Log em Packages - Invent�rio de estoque de produtos
--
-- Em 18/02/2017 - F�bio Tavares
-- Redmine #28545 - Alterar o tipo do log de Integra��o do Invent�rio
-- pkb_ler_inventario.
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
-- Em 25/08/2018 - Angela In�s.
-- Redmine #46371 - Agendamento de Integra��o cujo Tipo seja "Todas as Empresas".
-- Incluir o identificador do Mult-Org como par�metro de entrada (mult_org.id), para Agendamento de Integra��o como sendo do Tipo "Todas as Empresas".
-- Rotina: pkb_integr_periodo_geral.
--
-------------------------------------------------------------------------------------------------------

-- Especifica��o de array

--| Informa��es de Invent�rio
   type tab_csf_inventario is record ( cpf_cnpj       varchar2(14)   
                                     , cod_item       varchar2(60)
                                     , dt_inventario  date
                                     , sigla_unid     varchar2(6)
                                     , qtde           number(14,3)
                                     , vl_unit        number(15,6)
                                     , vl_item        number(15,2)
                                     , dm_ind_prop    number(1)
                                     , cod_part       varchar2(60)
                                     , txt_compl      varchar2(255)
                                     , cod_cta        varchar2(30)
                                     , dt_ref         date
                                     , dm_mot_inv     varchar2(2)
                                     );
--
   type t_tab_csf_inventario is table of tab_csf_inventario index by binary_integer;
   vt_tab_csf_inventario t_tab_csf_inventario;
--| Informa��es de Invent�rio - Flex Field
   type tab_csf_inventario_ff is record ( cpf_cnpj       varchar2(14)
                                        , cod_item       varchar2(60)
                                        , dt_inventario  date
                                        , atributo       varchar2(60)
                                        , valor          varchar2(255)
                                        );
--
   type t_tab_csf_inventario_ff is table of tab_csf_inventario_ff index by binary_integer;
   vt_tab_csf_inventario_ff t_tab_csf_inventario_ff;
--
--| Informa��es Complementares do Inventario
   type tab_csf_invent_cst is record ( cpf_cnpj       varchar2(14)
                                     , dt_inventario  date
                                     , cod_item       varchar2(60)
                                     , cod_st         varchar2(3)
                                     , vl_bc_icms     number(15,2)
                                     , vl_icms        number(15,2)
                                     );
--
   type t_tab_csf_invent_cst is table of tab_csf_invent_cst index by binary_integer;
   vt_tab_csf_invent_cst t_tab_csf_invent_cst;
--
-------------------------------------------------------------------------------------------------------

   gv_sql varchar2(4000) := null;

-------------------------------------------------------------------------------------------------------

   GV_ASPAS CHAR(1) := null;

   GV_NOME_DBLINK    empresa.nome_dblink%type := null;
   GV_OWNER_OBJ      empresa.owner_obj%type := null;
   GV_FORMATO_DT_ERP empresa.FORMATO_DT_ERP%type := null;

-------------------------------------------------------------------------------------------------------

-- Declara��o de constantes

   ERRO_DE_VALIDACAO       CONSTANT NUMBER := 1;
   ERRO_DE_SISTEMA         CONSTANT NUMBER := 2;
   INFORMACAO              CONSTANT NUMBER := 35;

-------------------------------------------------------------------------------------------------------

   gv_mensagem_log       Log_Generico_inv.mensagem%TYPE;
   gv_obj_referencia     Log_Generico_inv.obj_referencia%type := 'INVENTARIO';
   gn_referencia_id      Log_Generico_inv.referencia_id%type := null;
   --
   gv_cpf_cnpj           varchar2(14) := null;
   gv_cd_obj             obj_integr.cd%type := '2';
   gn_multorg_id         mult_org.id%type;
   gn_empresa_id         empresa.id%type;
   gv_formato_data       param_global_csf.valor%type := null;
   --
   info_fechamento       number;

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integra��o
procedure pkb_integracao ( en_empresa_id  in  empresa.id%type
                         , ed_dt_ini      in  date
                         , ed_dt_fin      in  date 
                         );

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integra��o de cadastros
procedure pkb_integracao_normal ( ed_dt_ini      in  date
                                , ed_dt_fin      in  date 
                                );

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integra��o por per�odo
procedure pkb_integr_periodo_geral ( en_multorg_id in mult_org.id%type
                                   , ed_dt_ini     in date
                                   , ed_dt_fin     in date
                                   );

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integra��o Geral de empresas para o CT
procedure pkb_integr_geral_empresa ( en_paramintegrdados_id in param_integr_dados.id%type
                                   , ed_dt_ini              in date
                                   , ed_dt_fin              in date
                                   , en_empresa_id          in empresa.id%type
                                   );

-------------------------------------------------------------------------------------------------------

end pk_int_view_inv;
/
