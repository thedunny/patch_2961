create or replace package csf_own.pk_vld_amb_d100 is

-------------------------------------------------------------------------------------------------------
--
-- Especifica��o do pacote da API para ler os conhecimentos de transporte de aquisi��o com
-- DM_ST_PROC = 0 (N�o validada) e chamar os procedimentos para validar os dados
--
-- Em 15/01/2020 - Eduardo Linden
-- Redmine #75237 (Feedback) - Inclus�o de parametriza��o para preenchimento do Codigo do Tipo Servi�o Reinf para CTE modelo 67
-- Foi ajustado as condi��es sobre dm_legado devido ao problema de estar vindo nulo. 
-- Rotina alterada - pkb_vld_ct_d100 
-- Patches 2.9.5.4 e 2.9.6.1 e Release 2.9.7 
--
-- Em 12/01/2020 - Eduardo Linden
-- Redmine #75121 (Feedback) - Inclus�o de parametriza��o para preenchimento do Codigo do Tipo Servi�o Reinf para CTE modelo 67
-- Inclus�o da chamada da rotina pkb_ler_conhec_transp_imp_ret.
-- Rotinas alteradas - pkb_ler_ct_d100 e pkb_vld_ct_d100
-- Patches 2.9.5.4 e 2.9.6.1 e Release 2.9.7 
--
-- Em 12/01/2021   - LUIZ ARMANDO AZONI - 2.9.5-4 - 296-1 297
-- Redmine #75061  - ADICIONADO AJUSTE NO DM_ST_PROC PARA AS SITUA��ES ONDE O CT-E � LEGADO
-- Nova Rotina     - pkb_vld_ct_d100
--
-- Em 28/12/2020   - Eduardo Linden
-- Redmine #74671  - Inclus�o do Flexfield UNID_ORG - VW_CSF_CONHEC_TRANSP_EFD_FF
-- Rotinas alteradas - pkb_ler_ct_d100 e pkb_vld_ct_d100 => Inclus�o do novo parametro ev_cd_unid_org na rotina pk_csf_api_d100.pkb_integr_ct_d100
--
-- Em 18/09/2020   - Luis Marques - 2.9.5
-- Redmine #70848  - Implementar Diferencial de Al�quota para CTE - Aviva
-- Nova Rotina     - pkb_ler_ct_dif_aliq - Rotina para ler os dados do diferencial de aliquota do conhecimento 
-- Rotina Alterada - pkb_ler_ct_d100 - Incluida chamada para rotina "pkb_ler_ct_dif_aliq".
--
-- Em 01/10/2020     - Armando/Luis Marques - 2.9.4-4 / 2.9.5-1 / 2.9.6
-- Redmine #71894    - Integra��o de CTe - Emiss�o Pr�pria - Documento Autorizado Adicionado por Gabriel 19 dias atr�s. 
--                     Atualizado aproximadamente 6 horas atr�s.
-- Rotinas Alteradas - pkb_int_ws - Incluido tipo de objeto de integra��o 1 e 3.
--                     pkb_ler_ct_d100_int_ws - Cursor ajustado para trazer conhecimentos de transporte proprio que sejam LEGADO.
--                     pkb_vld_ct_d100 - Tirado valida��o para s� conhecimento de emiss�o de terceiro e n�o de armazenamento na leitura.
--
-- ====================================================================================================================
-- Em 24/07/2013 - Angela In�s.
-- Corre��es nas mensagens.
--
-- Em 26/12/2013 - Angela In�s.
-- Redmine #1644 - Considerar os Conhecimentos de Transporte com dm_arm_cte_terc igual a 0.
--
-- Em 21/05/2015 - Rog�rio Silva.
-- Redmine #8054 - Implementar package pk_vld_amb_ws
--
-- Em 02/10/2015 - Angela In�s.
-- Redmine #11914 - Acompanhar os processos que est�o sendo desenvolvidos.
-- Para a integra��o dos conhecimentos de transporte de terceiros n�o deve ser exigido o c�digo da natureza de opera��o.
-- Rotina: pk_vld_amb_d100.pkb_vld_ct_d100 - cursor c_ct_d100.
--
-- Em 05/02/2016 - Rog�rio Silva
-- Redmine #13079 - Registro do N�mero do Lote de Integra��o Web-Service nos logs de valida��o
--
-- Em 24/01/2018 - Karina de Paula
-- Redmine #38656 - Processos de integra��o de Conhecimento de Transporte - Modelo D100.
-- Incluido o modelo fiscal 67 para todas as rotinas que est�o tratando o modelo 57-Conhecimento de Transporte Eletr�nico
--
-- Em 20/06/2018 - Karina de Paula
-- Redmine #40168 - Convers�o de CTE e Gera��o dos campo COD_MUN_ORIG e COD_MUN_DEST no registro D100 do Sped de ICMS e IPI
-- Rotina Alterada: pkb_ler_ct_d100 => Inclu�do os novos par�metros na chamda da pk_csf_api_d100.pkb_integr_ct_d100
--
-- Em 21/06/2018 - Marcos Ferreira
-- Redmine #29340 - Integra��o de Conhecimento de Transporte - Processo de Integra��o WEb Service - N�o chama processo de rotina program�vel
-- Problema: Ao fazer a integra��o de conhecimento de transporte, a valida ambiente n�o chamava as rotinas program�veis
-- Solu��o: Inclu�do chamada das rotinas program�veis na procedure pkb_ler_ct_d100_int_ws
-- Procedimentos alterados: pkb_ler_ct_d100_int_ws
--
-- Em 27/06/2018 - Angela In�s.
-- Redmine #43520 - Lote de Integra��o WS rejeitado com notas autorizadas.
-- Eliminar a recupera��o do Mult-Org atrav�s do Lote de Integra��o WS, e recuperar da Empresa vinculada com o Conhecimento de Transporte.
-- Rotina: pkb_ler_ct_d100_int_ws.
--
-- Em 31/10/2018 - Karina de Paula
-- Redmine #47549 - Adaptar packages de integra��o
-- Rotina Criada: pkb_ler_conhec_transp_imp_ret
--
-- Em 09/04/2019 - Fernando Basso
-- Redmine #53141 - Ajustar tags ibge_cidade_ini e ibge_cidade_fim - SPED
-- Complementa��o da chamada de conhecimento de transporte
-- Rotina: pkb_vld_ct_d100
--
-- Em 23/09/2019 - Luis Marques
-- Redmine #48353 - Ao fazer upload do CTe pelo compliance, o participante n�o � Cadastrado/Atulizado.
-- Rotinas Alteradas: pkb_ler_ct_d100, pkb_vld_ct_d100 - Incluido chamada para nova rotina pkb_ler_Conhec_Transp_Emit
--                    para gravar os dados do emitente.
--
-------------------------------------------------------------------------------------------------------

-- Vari�veis globais utilizadas no processo
   gv_cpf_cnpj_emit   varchar2(14);
   gn_multorg_id      mult_org.id%type;

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a valida��o de Conhecimentos de Transporte
procedure pkb_integracao;

-------------------------------------------------------------------------------------------------------

-- Procedimento de valida��o de dados de Conhecimento de Transporte de Terceiro, oriundos de Integra��o por Web-Service
procedure pkb_int_ws ( en_loteintws_id      in     lote_int_ws.id%type
                     , en_tipoobjintegr_id  in     tipo_obj_integr.id%type
                     , sn_erro              in out number
                     );

-------------------------------------------------------------------------------------------------------

end pk_vld_amb_d100;
/
