create or replace package csf_own.pk_csf_api_ct is

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Especifica��o do pacote da API do Conhecimento de Transporte
----------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- Em 08/01/2020   - Karina de Paula
-- Redmine #74868  - Erro de Valida��o: Dominio conhec_transp.dm_st_integra
--          74768  - Liberar de valida��o CTE legado
--         #75061  - Erro ainda ocorre. 
-- Rotina Alterada - pkb_integr_evento_cte e pkb_integr_conhec_transp => Incluido valor do dominio dm_st_integra "10"
--                 - Criada a variavel global gn_dm_ind_emit e gn_dm_legado para receber o valor da pkb_busca_dm_ind_emit
--                 - Incluida a verificacao se integracao � de emiss�o pr�pria e n�o legado para executar as valida��es
-- Liberado        - Release_2.9.6
--
-- Em 18/12/2020   - Karina de Paula
-- Redmine #74308  - Teste de Integra��o CT-e
-- Rotina Alterada - pkb_integr_conhec_transp => Alterada a verificacao do dm_legado para ser igual a 0, para criacao de uma nova chave
-- Liberado        - Release_2.9.6
--
-- Em 16/11/2020   - Joao Carlos - 2.9.4-5 / 2.9.5-2 / 2.9.6
-- Redmine #73332  - Corre��o na condi��o do select de and tc.cd_compat = ln.csftipolog_id para and tc.id = ln.csftipolog_id
-- Rotina Alterada - fkg_ver_erro_log_generico
--
--
-- Em 11/11/2020   - Jo�o Carlos - 2.9.4-5 / 2.9.5-2 / 2.9.6
-- Redmine #66443  - Inclus�o da vari�vel en_referencia_id na chamada da pkb_log_generico_ct - Ticket #66443
-- Rotina Alterada - fkg_integr_lote_cte, pkb_reenvia_lote_cte, PKB_AJUSTA_LOTE_CTE, pkb_excluir_lote_sem_cte, pkb_gera_lote_cte,
--                 - fkg_ct_nao_inutiliza, pkb_atual_cte_inut, pkb_relac_cte_cons_sit, pkb_atual_sit_docto
--
-- Em 14/09/2020   - Karina de Paula
-- Redmine #67105  - Criar processo de valida��o da CT_CONS_SIT
-- Rotina Alterada - pkb_integr_ct_cons_sit => Exclus�o dessa rotina pq foi substitu�da pela pk_csf_api_cons_sit.pkb_integr_ct_cons_sit
--                 - pkb_excluir_dados_ct   => Retirado o update na ct_cons_sit e inclu�da a chamada da pk_csf_api_cons_sit.pkb_ins_atu_ct_cons_sit
--                 - pkb_relac_cte_cons_sit => Retirado o update na ct_cons_sit e inclu�da a chamada da pk_csf_api_cons_sit.pkb_ins_atu_ct_cons_sit
--                 - pkb_cons_cte_terc      => Retirado o insert na ct_cons_sit e inclu�da a chamada da pk_csf_api_cons_sit.pkb_ins_atu_ct_cons_sit
-- Liberado        - Release_2.9.5
--
-- Em 19/08/2020   - Luis Marques - 2.9.3-5 / 2.9.4-2 / 2.9.5
-- Redmine #70694  - colocar a tabela CONHEC_TRANSP_IMP_RET na rotina de exclus�o
-- Rotina Alterada - pkb_excluir_dados_ct - Incluir tabela "CONHEC_TRANSP_IMP_RET" na rotina de exclus�o dos CTE(s).
--
-- Em 23/07/2020   - Luis Marques - 2.9.4-2 / 2.9.5
-- Redmine #69796  - Diverg�ncia entre apura��o de ICMS e livro de sa�das
-- Rotina Alterada - pkb_integr_conhec_transp_imp - Colocado log de alerta para conhecimento de transporte com CST
--                   90 Outras e com valores nos campos de triburta��o de ICMS Base, aliquota e valor do imposto,
--                   pode ocorrer caso parametriza��o de CST n�o tributados estiver ativa erro no Livro de Sa�da.
--
-- Em 05/12/2019 - Allan Magrini
-- Redmine #61656 - Regra de valida��o D100 campo 11
-- Criada regra de valida��o onde o campo CONHEC_TRANSP.DT_HR_EMISSAO>= 01/01/2019 e CONHEC_TRANSP.MODFISCAL_ID seja igual a 07, 09, 10, 11, 26 ou 27 
-- sera gerado erro de valida��o informando que o modelo selecionado n�o est� mais vigente na data de emiss�o informada.        
-- RotinaS Criada: pkb_valida_ct_d100
--
-- Em 27/11/2019 - Luiz Armando / Luis Marques
-- Redmine #61768 - Retorno de XML CT-e e NF-e em Duplicidade
-- Rotina Alterada: PKB_RELAC_CTE_CONS_SIT - Ajustado para verificar o DM_ST_PROC do documento antes de setar DM_RET_CT_ERP 
--                  que inicia nova leitura na SEFAZ e retorna ao ERP.
--
-- Em 25/11/2019   - Allan Magrini
-- Redmine #58461  - Valida��o CT-e
-- Retirada a valida��o da forma de emiss�o fase 19
-- Rotina Alterada - PKB_VALIDA_CHAVE_ACESSO
--
-- Em 12/11/2019   - Marcos Ferreira
-- Redmine #60533  - Erro de valida��o CTe Terceiro - Forma de emiss�o FS-DA (FRONERI)
-- Rotina Alterada - pkb_integr_conhec_transp - Inclu�do associa��o da vari�vel gt_row_conhec_transp
--                   pkb_valida_chave_acesso - Inclu�do clausula para validar forma de emiss�o somente para ctes de emiss�o pr�pria
--
-- Em 20/09/2019   - Karina de Paula
-- Redmine #53132  - Atualizar Campos Chaves da View VW_CSF_CT_INF_OUTRO
-- Rotina Alterada - pkb_integr_r_outro_infut e pkb_integr_r_outro_infuc => Incluido o campo NRO_DOCTO para ser usado como chave na chamada da funcao pk_csf_ct.fkg_ct_inf_outro_id
--
-- Em 18/09/2019 - Luis Marques
-- Redmine #58940 - Valida��o incorreta do CTe
-- Rotina Alterada: pkb_integr_ct_part_icms - Ajustado para o campo "perc_icms_inter_part" Percentual provis�rio de 
--                  partilha entre os estados aceitar nulo ou n�o ser informado.
--
-- Em 09/09/2019 - Luis Marques
-- Redmine #58593 - Diversas consultas de chave de CTE duplicadas
-- Rotinas Alteradas: PKB_CONS_CTE_TERC - justado para a valida��o de inclus�o de registros a consultar a Chave do
--                    CTE para incluir at� 7 vezes  e se n�o existe registro para o dia.
--                    pkb_relac_cte_cons_sit - tratado o DM_ST_PROC do conhecimento caso n�o seja possivel a leitura
--                    na sefaz, colocado log de informa��o.
--
-- Em 21/08/2019 - Luis Marques
-- Redmine #57141 - Valida��o nota fiscal servi�os
-- Rotinas Alteradas: pkb_integr_ctimpout_pis, pkb_integr_ctimpout_cofins - ajustado para mostrar Informa��o Geral ao inves de
--                    Avisos Gen�ricos
--
-- Em 08/08/2019 - Luis Marques
-- Redmine #57204 - Falha na consulta autom�tica chave de acesso CTe (TUPPERWARE)
-- Rotina Alterada: PKB_CONS_CTE_TERC - Ajustado para se no dia j� foi atingido sete leituras antes de 23:59 inserir mais
--                  um registro para oitava leitura para verifica��o de possivel cancelamento do conhecimento.
--
-- Em 25/07/2019 - Eduardo Linden
-- Redmine #56442 - CTE - Mudan�a na obten��o do Valor de opera��o 
-- Solicita��o:  , o valor de opera��o (ct_reg_anal.vl_opr) ir� receber o valor do campo conhec_transp_vlprest.VL_DOCTO_FISCAL, 
-- ao inv�s da soma do campo conhec_transp_imp.vl_base_cal
-- Rotina alterada : pkb_valida_ct_d190
--
-- Em 21/07/2019 - Luis Marques
-- Redmine #56565 - feed - Mensagem de ADVERTENCIA est� deixando documento com ERRO DE VALIDA��O
-- Rotinas alteradas: pkb_integr_conhec_transp, pkb_integr_ctimpout_pis e pkb_integr_ctimpout_cofins
--                    Alterado para colocar verifica��o de falta de Codigo de base de calculo de PIS/COFINS
--                    como advertencia e n�o marcar o documento com erro de valida��o se for s� esse log.
-- Function nova: fkg_verif_erro_log_generico
--
-- Em 12/07/2019 - Luis Marques
-- Redmine #56155 - feed - Valida��o de chave de CT-e
-- 
-- Em 09/07/2019 e 12/07/2019 - Luis Marques
-- Redmine #27836 Valida��o PIS e COFINS - Gerar log de advert�ncia durante integra��o dos documentos
-- Rotinas alteradas: Incluido verifica��o de advertencia da falta de Codigo da base de calculo do credito
--                    se existir base e aliquota de imposto for do tipo imposto (0) e cliente juridico
--                    pkb_integr_ctimpout_pis e pkb_integr_ctimpout_cofins
-- Function nova: fkg_dmindemit_conhectransp
--
-- Em 05/07/2018 - Luis Marques
-- Redmine #56042 - Parou de validar a chave de cte de terceiro
-- Rotina Alterada: pkb_integr_conhec_transp na chamada da fkg_ret_valid_integr incluido campos
--                  dm_forma_emiss para valida��o de forma de emiss�o <> 8 8 e conhecimento 
--                  n�o de terceiros, DM_IND_EMIT = 0 e legado (1,2,3,4), DM_LEGADO in (1,2,3,4)
--
----------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- Em 07/06/2019 - Luiz Armando Azoni
-- Redmine #55207 - Erro na valida��o CTe Terceiro
-- Rotina Alterada:  pkb_relac_cte_cons_sit
-- Motivo: Na valida��o quando o campo rec.dm_situacao=5 e o campo rec.cstat=null, a vari�vel vn_dm_st_proc ficava nula gerando erro no update da tabela conhec_transp
--				 Foi adicionado uma tratativa para corrigir esta condi��o e no update da tabela conhec_transp foi adicionado um tratamente de exce��o, caso ocorra erro no update, 
--			       ser� gerado um log e o processo continuar� normalmente.
--
----------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- Em 31/05/2019 - Karina de Paula
-- Redmine #54663 - Valida��o de CTe Complementar com Valor 0
-- Rotina Alterada: pkb_integr_ct_vlprest => Inclu�da a verifica��o do pk_csf_api_ct.gt_row_conhec_transp.dm_tp_cte <> 1 para validar os campos vl_prest_serv e vl_docto_fiscal
--
-- Em 31/05/2019 - Karina de Paula
-- Redmine #53834 - Erro de valida��o CTe Terceiro - Forma de emiss�o SVC-SP (LCA)
-- Rotina Alterada: pkb_integr_conhec_transp => Inclu�da a chamada da fkg_ret_valid_integr =. Function retorna se o dado de integra��o deve ser validado ou n�o
--
-- Em 23/05/2019 - Karina de Paula
-- Redmine #54711 - CT-e n�o exclui.
-- Rotina Alterada: pkb_excluir_dados_ct => Foi descomentada a linha de delete da tabela r_loteintws_ct. Essa linha foi comentada em agosto/2017 sem explica��o.
-- Por�m tb foi criado o par�metro de entrada "en_excl_rloteintwsct" para verificar se ir� excluir o v�nculo com a "r_loteintws_ct".
-- Foi verificado q esse processo tb � chamado na integra��o do CTE, por isso que o delete estava comentado. No caso de integra��o do CTE n�o podemos excluir o
-- v�nculo do CTE com o lote de integra��o. Para solucionar o problema ser� criado um novo par�metro de entrada na chamada do processo pk_csf_api_ct.pkb_excluir_dados_ct
-- que identifique se a rotina pode excluir os dados da r_loteintws_ct ou n�o.
-- Inclu�da a verifica��o pk_csf_ct.fkg_cte_nao_integrar
--
-- === AS ALTERA��ES ABAIXO EST�O NA ORDEM CRESCENTE USADA ANTERIORMENTE ================================================================================= --
--
-- Em 14/09/2012 por Rog�rio Silva.
-- Altera��o no processo de valida��o do sufixo da placa do Ve�culo no Modal Rodovi�rio, conforme
-- a ficha 63038.
--
-- Em: 19/09/2012 por Rog�rio Silva.
-- Foi adicionado o campo "NRO_CARREG" no processo de valida��o e integra��o de conhecimento de transporte.
--
-- Em 28/11/2012 - Angela In�s.
-- Ficha HD 64674 - Melhoria em valida��es, n�o permitir valores zerados para os campos:
-- Rotina: pkb_integr_ct_vlprest -> conhec_transp_vlprest.vl_prest_serv e conhec_transp_vlprest.vl_docto_fiscal.
--
-- Em 03/01/2013 - Angela In�s.
-- Ficha HD 65123 - Implementar no processo de inutiliza��o de CTe, a cria��o dos dados para recuperar os dados na tela de monitoramento e retornar para o ERP.
-- Rotina: pkb_atual_cte_inut.
--
-- Em 06/08/2013 - Angela In�s.
-- Redmine #451 - Valida��o de informa��es Fiscais - Ficha HD 66733.
-- Corre��o nas rotinas chamadas pela pkb_consistem_ct, eliminando as refer�ncias das vari�veis globais, pois essa rotina ser� chamada de outros processos.
-- Rotina: pkb_consistem_ct e todas as chamadas dentro dessa rotina.
-- Inclus�o da fun��o de valida��o dos conhecimentos de transporte, atrav�s dos processos de sped fiscal, contribui��es e gias.
-- Rotina: fkg_valida_ct.
--
-- Em 05/09/2013 - Angela In�s.
-- Alterar a rotina que valida os processos considerando somente conhecimentos de transporte que sejam de emiss�o pr�pria (conhec_transp;dm_ind_emit = 0).
-- Rotina: fkg_valida_ct.
--
-- Em 12/09/2013 - Rog�rio Silva.
-- Atividade #600 -> Adicionado os procedimentos  pkb_integr_ct_aquav_cont_nf e pkb_integr_ct_aquav_cont_nfe e adicionado os campos DT_INI e DT_FIM na
-- integra��o do procedimento pkb_integr_conhec_transp_duto.
--
-- Em 19/09/2013 - Angela In�s.
-- Redmine #680 - Fun��o de valida��o dos documentos fiscais.
-- Invalidar o conhecimento de transporte no processo de consist�ncia dos dados, se o objeto de refer�ncia for CONHEC_TRANSP.
-- Rotina: pkb_consistem_ct.
--
-- Em 30/06/2014 - Angela In�s.
-- Redmine #3207 - Suporte - Leandro/GPA. Verificar trace enviado por email - Integra��o de Conhecimentos de Transportes.
-- 1) Verificar a possibilidade de recuperar o valor da fun��o pk_csf.fkg_dm_tp_cte uma �nica vez dentro de cada rotina api de ct.
--    A fun��o � chamada v�rias vezes dentro da mesma rotina (pkb_valida...).
--    Rotinas em pk_csf_api_ct: pk_csf.fkg_dm_tp_cte.
-- 2) Verificar a possibilidade de recuperar o valor da fun��o pk_csf.fkg_dm_modal uma �nica vez dentro de cada rotina api de ct.
--    A fun��o � chamada v�rias vezes dentro da mesma rotina (pkb_valida...).
--    Rotinas em pk_csf_api_ct: pk_csf.fkg_dm_modal.
--
-- Em 18/11/2014 - Rog�rio Silva
-- Redmine #5018 - Alterar os processos de integra��o NFe, CTe e NFSe (emiss�o pr�pria)
-- Rotina: pkb_consistem_ct
--
-- Em 05/01/2015 - Angela In�s.
-- Redmine #5616 - Adequa��o dos objetos que utilizam dos novos conceitos de Mult-Org.
--
-- Em 13/01/2015 - Rog�rio Silva
-- Redmine #5827 - Retirar a obrigatoriedade de preenchimento da coluna "UF" da tabela "CTRODO_VEIC_PROP"
-- Rotina: pkb_integr_ctrodo_veic_prop
--
-- Em 27/01/2015 - Rog�rio Silva
-- Redmine #5696 - Indica��o do par�metro de integra��o
--
-- Em 01/06/2015 - Rog�rio Silva
-- Redmine #8230 - Processo de Registro de Log em Packages - Conhecimento de Transporte
--
-- Em 13/08/2015 - Angela In�s.
-- Redmine #10117 - Escritura��o de documentos fiscais - Processos.
-- Inclus�o do novo conceito de recupera��o de data dos documentos fiscais para retorno dos registros.
--
-- Em 05/02/2016 - Rog�rio Silva
-- Redmine #13079 - Registro do N�mero do Lote de Integra��o Web-Service nos logs de valida��o
--
-- Em 14/04/2016 - F�bio Tavares
-- Redmine #16793 - Melhoria nas mensagens dos processos flex-field.
--
-- Em 27/10/2017 - Marcelo Ono
-- Redmine #35937 - Inclus�o do par�metro de entrada empresa_id, para que seja filtrado a empresa do documento na execu��o das rotinas program�veis.
-- Rotina: pkb_consistem_ct.
--
-- Em 07/11/2017 - Leandro Savenhago
-- Redmine #33992 - Integra��o de CTe cuja emiss�o � propria legado atrav�s da Open Interface
-- Rotina: pkb_integr_conhec_transp.
--
-- Em 29/12/2017 - Marcelo Ono
-- Redmine #36865 - Atualiza��o no processo de valida��o e exclus�o do Conhecimento de Transporte para Emiss�o Pr�pria - CTe 3.00.
-- Rotinas: pkb_integr_conhec_transp, pkb_integr_conhec_transp_imp, pkb_integr_ct_part_icms, pkb_integr_ct_infcarga, pkb_integr_conhec_transp_subst,
--          pkb_integr_ct_inf_vinc_mult, pkb_integr_ct_transp_percurso, pkb_integr_ct_doc_ref_os, pkb_integr_ct_rodo_os, pkb_integr_ct_aereo_peri,
--          pkb_integr_ct_aquav_cont, pkb_integr_ct_aquav_cont_lacre, pkb_integr_ct_aquav_cont_nf, pkb_integr_ct_aquav_cont_nfe, pkb_integr_ct_ferrov,
--          pkb_integr_evento_cte_gtv, pkb_integr_evento_cte_gtv_esp, pkb_integr_evento_cte_desac, pkb_excluir_dados_ct, pkb_valida_chave_acesso
--          pkb_integr_CTChave_Refer, pkb_gera_lote_cte, pkb_atual_cte_inut, pkb_gera_lote_cte e fkg_integr_lote_cte.
--
-- Em 23/01/2018 - Karina de Paulas
-- Redmine #38656 - Processos de integra��o de Conhecimento de Transporte - Modelo D100.
-- Incluido somente explicacao da existencia de 2 cursores (c_conhec_transp e c_conhec_transp_os) para tratar o mod fiscal 57 e 67
--
-- Em 02/02/2018 - Angela In�s.
-- Redmine #39080 - Valida��o de Ambiente de Conhecimento de Transporte Emiss�o por Job Scheduller.
-- Rotinas: pkb_gera_lote_cte, pkb_consit_inutilizacao, pkb_atual_cte_inut, pkb_ajusta_lote_cte, pkb_relac_cte_cons_sit e pkb_atual_sit_docto.
--
-- Em 19/03/2018 - Karina de Paula
-- Redmine #39208 - Karina de Paula - Rotina (pkb_valida_ct_d190) criada para incluir c�lculo do ICMS na tabela ct_reg_anal
--
-- Em 06/04/2018 - Angela In�s.
-- Redmine #41482 - Corre��o no retorno do CTE atrav�s de consulta.
-- Considerar o CTe de armazenamento (Conhec_Transp.dm_arm_cte_terc=1), para atualiza��o do ID e do DM_ST_PROC, quando o mesmo � consultado pela tabela CT_CONS_SIT.
-- Rotina: pkb_relac_cte_cons_sit.
--
-- Em 13/04/2018 - Karina de Paula
-- Redmine #41660 - Altera��o processo de Integra��o de Conhecimento de Transporte, adicionando Integra��o de PIS e COFINS.
-- Criada a vari�vel global: gt_row_conhec_transp_imp_out
-- Criada a rotina: pkb_integr_ctimpout_pis
-- Criada a rotina: pkb_integr_ctimpout_cofins
-- Objetos Criados: gt_row_ct_compdoc_pis / gt_row_ct_compdoc_cofins
--
-- Em 23/04/2018 - Angela In�s.
-- Redmine #42053 - Alterar o M�todo para consultar CTe de Terceiro.
-- 1) Ao recuperar os CTEs de terceiro para consulta, considerar o per�odo de at� 8 dias e n�o mais 7 dias, anteriores ao dia atual.
-- 2) Alterar a data utilizada para recuperar os CTEs de terceiro no per�odo de 8 dias (item 1), de DT_HR_EMISSAO para DT_AUT_SEFAZ.
-- 3) Como melhoria t�cnica utilizar vari�veis para data inicial e final, considerando a inicial como sendo o sysdate e hora 00:00h, e a final como sendo o
-- sysdate menos(-) 8(oito) dias e hora 23:59h. Com isso, n�o utilizar a data truncando a informa��o de hora, e utilizar between com as datas inicial e final.
-- Rotina: pkb_cons_cte_terc.
--
-- Em 30/04/2018 - Angela In�s.
-- Redmine #42339 - Altera��o na Regra de Valida��o de CST para Impostos PIS e COFINS - CTE.
-- Para os Impostos PIS e COFINS considerar os CSTs entre 50 e 56, 60 e 66, 70 e 75, 98 e 99, se o CTE for de Aquisi��o (conhec_trans.dm_ind_oper=0).
-- Para os Impostos PIS e COFINS considerar os CSTs 01, 02, 03, 04, 05, 06, 07, 08, 09, ou 49, se o CTE for de Presta��o (conhec_trans.dm_ind_oper=1).
-- Rotinas: pkb_integr_ctimpout_pis e pkb_integr_ctimpout_cofins.
--
-- Em 28/08/2018 - Karina de Paula
-- Redmine #45905 - DE-PARA
-- Rotina Alterada: pkb_integr_conhec_transp_rodo => Alterada a rotina para aceitar valor nulo para o dm_lotacao
--
-- Em 20/09/2018 - Karina de Paula
-- Redmine #47066 - Integra��o de Conhecimento de Transporte
-- Rotina Alterada: pkb_integr_conhec_transp => Inclu�da a chamada da pk_csf_ct.fkg_legado_ct; cria��o da vn_dm_legado e inclu�do tratamento para LEGADO
--
-- Em 25/09/2018 - Karina de Paula
-- Redmine #47169 - Analisar o levantamento feito do CTE 3.0
-- Rotina Alterada: pkb_integr_conhec_transp_subst => Incluido campo CPF
-- Rotina Criada: pkb_integr_evento_cte_etec
--
-- Em 04/10/2018 - Karina de Paula
-- #47505 - Feed - Integra��o Agendamento
-- Rotina Alterada: pkb_integr_conhec_transp => Inclu�da a contagem da pk_agend_integr.gvtn_qtd_total(gv_cd_obj)
-- Incluida a vari�vel global gv_cd_obj.
--
-- Em 06/11/2018 - Angela In�s.
-- Redmine #48431 - N�o deixa excluir o cte qdo tem vinculo com a tabela conhec_transp_imp_ret.
-- Os detalhes das abas s�o exclu�dos por uma procedure do PL que � chamada quando o bot�o excluir � acionado. A procedure deleta os dados relacionados das abas
-- e depois o java exclui o principal.
-- Al�m da tabela mencionada na atividade, CONHEC_TRANSP_IMP_RET, foram inclu�das as seguintes: CONHEC_TRANSP_CANC, CONHEC_TRANSP_CARGA, CT_CARGA_DOC_FISCAL,
-- CT_CARGA_LOCAL, CONHEC_TRANSP_ITEM, CT_ITEM_COMPL, CT_COMPL_AEREO, CT_COMPL_AQUAV, CT_COMPL_RODO, CTINFOR_FISCAL, CT_INF_PROV, R_CTINFNF_CTINFUNIDCARGA,
-- R_CTINFNFE_CTINFUNIDCARGA, R_CTINFOUTRO_CTINFUNIDCARGA, R_CTINFNF_CTINFUNIDTRANSP, R_CTINFNFE_CTINFUNIDTRANSP, R_CTINFOUTRO_CTINFUNIDTRANSP, CT_MODAIS,
-- FRETE_ITEMNF, R_CTRLINTEGRARQ_CT e R_LOTEINTWS_CT.
-- N�o foram inclu�das: EFD_REINF_R2010_CTE, EFD_REINF_R2020_CTE e R_CT_CT.
-- Rotina: pkb_excluir_dados_ct.
--
-- Em 07/11/2018 - Angela In�s.
-- Redmine #48476 - Corre��o na Valida��o da Placa em "Informa��es do Modal Rodovi�rio CTe Outros Servi�os" e em "Ve�culos do Transporte da Nota Fiscal".
-- N�o fazer a valida��o de Sufixo e Prefixo da Placa do Ve�culo.
-- Rotina: pkb_integr_ctrodo_veic.
--
-- Em 20/11/2018 - Angela In�s.
-- Redmine #48898 - Alterar o processo de valida��o da Forma de Emiss�o para Conhecimento de Transporte.
-- Considerar o forma de emiss�o parametrizada na empresa caso o conhecimento de transporte n�o seja legado, do contr�rio, considerar da pr�pria chave enviada.
-- Ap�s validar a chave do conhecimento de transporte, de emiss�o pr�pria, e o processo verificar que houve erro, fazer a montagem da chave somente se o
-- conhecimento for legado.
-- Rotina: pkb_integr_conhec_transp.
--
-- Em 21/11/2018 - Angela In�s.
-- Redmine #48916 - Defeito - nao est� integrando cte com dm_legado <> 0.
-- O processo estava considerando a situa��o e o legado, do conhecimento j� cadastrado, por�m essas informa��es est�o da View de Integra��o com valor e o
-- conhecimento ainda n�o est� no cadastro integrado. Foi necess�rio fazer um teste identificando se os valores da situa��o e do legado est�o nulos para serem
-- recuperados no conhecimento caso exista, do contr�rio os valores ser�o recuperados da view de integra��o.
-- Outras corre��o foi feita na recupera��o da forma de emiss�o, que est� considerando o valor enviado na chave de acesso, por�m esses conhecimentos de transporte
-- n�o possuem chave de acesso, ficando com o valor NULO. Foi necess�rio identificar se o conhecimento for legado (<>0), e a chave de acesso estiver nula, a forma
-- de emiss�o ser� 1-Normal. Se o conhecimento n�o for legado (=0), e a forma de emiss�o estiver nula, o valor ser� recuperado do par�metro da empresa.
-- Rotina: pkb_integr_conhec_transp.
--
-- Em 28/01/2018 - Karina de Paula
-- Redmine #50749 - Procedure para limpar depend�ncias da tabela CONHEC_TRANSP.
-- Rotina Alterada: pk_csf_api_ct.pkb_excluir_dados_ct => Inclu�da a exclus�o dos dados da tabela ctinfor_fiscal
--
-- Em 29/01/2019 - Renan Alves
-- Redmine #49303 - Tela de Conhecimento de Transporte - Bot�o validar
-- Altera��o: Foi acrescentado uma verifica��o para os tipos de emiss�es (0 - Emiss�o pr�pria / 1 - Terceiros)
-- na pkb_consistem_ct, retornando uma mensagem de log espec�fica, para cada emiss�o.
--
-- Em 31/01/2019 - Marcos Ferreira
-- Redmine #51090 - Valor Base Outras e Valor Base Isenta para CTe Emissao Propria
-- Solicita��o: Incluir a integra��o dos campos VL_BASE_OUTRO, VL_IMP_OUTRO, VL_BASE_ISENTA, ALIQ_APLIC_OUTRO na Integra��o de impostos para Conhecimento de Transporte
-- Altera��es: Cria��o da integra��o pela VW_CSF_CONHEC_TRANSP_IMP_FF
-- Procedures Criada: pkb_integr_ct_imp_ff
--
-- Em 14/02/2018 - Karina de Paula
-- Redmine #51537 - CTe n�o est� excluindo pela tela
-- Rotina Alterada: pk_csf_api_ct.pkb_excluir_dados_ct => Inclu�da a exclus�o dos dados da tabela ct_inf_prov
--
-- Em 18/03/2019 - Marcos Ferreira
-- Redmine Melhoria #52544: Mudar forma de gera��o CCT_CTE
-- Solicita��o: Para evitar fraudes e aumentar a seguran�a, gerar o campo CCT_CTE por numero randomico
-- Altera��es: Criado Fun��o FKG_GERA_CCT_CTE_RAND e Alterado as procedures que utilizam a composi��o do campo CCT_CTE
-- Procedures Alteradas: FKG_GERA_CCT_CTE_RAND, PKB_INTEGR_CTCHAVE_REFER
--
-- Redmine Redmine #53636 - Corre��o na valida��o da Chave de Acesso do CTe.
-- Ao validar a chave de acesso do CTe consistimos o CNPJ da chave de acesso com o CNPJ da Empresa emitente do Conhecimento de Transporte.
-- Passar a considerar o CNPJ da chave de acesso com o CNPJ da Empresa emitente do Conhecimento de Transporte desde que o Indicador do Emitente seja Emiss�o Pr�pria.
-- Passar a considerar o CNPJ da chave de acesso com o CNPJ do Participante do Conhecimento de Transporte desde que o Indicador do Emitente seja Terceiro.
-- Rotinas: pkb_integr_conhec_transp e pkb_valida_chave_acesso.
--
-- Redmine Redmine #53666 - Corre��o na valida��o da Chave de Acesso do CTe.
-- Ao validar a chave de acesso do CTe consistimos o C�digo do IBGE da Cidade da chave de acesso com o C�digo do IBGE da Cidade da Empresa emitente do
-- Conhecimento de Transporte.
-- Passar a considerar o C�digo do IBGE da Cidade da chave de acesso com o C�digo do IBGE da Cidade da Empresa emitente do Conhecimento de Transporte desde que
-- o Indicador do Emitente seja Emiss�o Pr�pria.
-- Passar a considerar o C�digo do IBGE da Cidade da chave de acesso com o C�digo do IBGE da Cidade do Participante do Conhecimento de Transporte desde que o
-- Indicador do Emitente seja Terceiro.
-- Rotina: pkb_valida_chave_acesso.
--
-- Em 26/04/2019 - Karina de Paula
-- Redmine #52645 - Erro na exclus�o do CT-e.
-- Rotina Alterada: pkb_excluir_dados_ct => Criada a vari�vel global gn_ind_exclu que ser� usada na rotina de exclus�o do CT de convers�o para n�o chamar novamente a pk_csf_api_ct.pkb_excluir_dados_ct
--                                          gn_ind_exclu number := 0; -- Indica que o CT foi exclu�do (0-N�o / 1-Sim).
--
-- Em 22/05/2019 - Marcos Ferreira
-- Redmine #51731 - Upload de Cte de Terceiro
-- Solicita��o: Integra��o de XML CTe Terceiro, se rejeitar por algum motivo, n�o atualizar a conhec_transp.dm_st_proc
-- Procedures Alteradas: pkb_relac_cte_cons_sit
--
-- === AS ALTERA��ES PASSARAM A SER INCLU�DAS NO IN�CIO DA PACKAGE ================================================================================= --
--
----------------------------------------------------------------------------------------------------------------------------------------------------------------
--
   gt_row_inut_conhec_transp         Inutiliza_Conhec_Transp%rowtype;
--
   gt_row_lote_cte                   Lote_Cte%rowtype;
--
   gt_row_conhec_transp              Conhec_Transp%rowtype;
--
   gt_row_conhec_transp_tomador      Conhec_Transp_Tomador%rowtype;
--
   gt_row_conhec_transp_compl        Conhec_Transp_Compl%rowtype;
--
   gt_row_ct_compl_pass              Ct_Compl_Pass%rowtype;
--
   gt_row_ct_compl_obs               Ct_Compl_Obs%rowtype;
--
   gt_row_conhec_transp_emit         Conhec_Transp_Emit%rowtype;
--
   gt_row_conhec_transp_rem          Conhec_Transp_Rem%rowtype;
--
   gt_row_ctrem_loc_colet            ctrem_loc_colet%rowtype;
--
   gt_row_ctrem_inf_nf               Ctrem_Inf_Nf%rowtype;
--
   gt_row_ctrem_inf_nf_locret        Ctrem_Inf_Nf_Locret%rowtype;
--
   gt_row_ctrem_inf_nfe              Ctrem_Inf_Nfe%rowtype;
--
   gt_row_ctrem_inf_outro            Ctrem_Inf_Outro%rowtype;
--
   gt_row_conhec_transp_exped        Conhec_Transp_Exped%rowtype;
--
   gt_row_conhec_transp_receb        Conhec_Transp_Receb%rowtype;
--
   gt_row_conhec_transp_dest         Conhec_Transp_Dest%rowtype;
--
   gt_row_ctdest_locent              Ctdest_Locent%rowtype;
--
   gt_row_conhec_transp_vlprest      Conhec_Transp_Vlprest%rowtype;
--
   gt_row_ctvlprest_comp             Ctvlprest_Comp%rowtype;
--
   gt_row_conhec_transp_imp          Conhec_Transp_Imp%rowtype;
--
   gt_row_ctinfcarga_qtde            Ctinfcarga_Qtde%rowtype;
--
   gt_row_conhec_transp_infcarga     Conhec_Transp_Infcarga%rowtype;
--
   gt_row_conhec_transp_cont         Conhec_Transp_Cont%rowtype;
--
   gt_row_ctcont_lacre               Ctcont_Lacre%rowtype;
--
   gt_row_conhec_transp_docant       Conhec_Transp_Docant%rowtype;
--
   gt_row_ctdocant_papel             Ctdocant_Papel%rowtype;
--
   gt_row_ctdocant_eletr             Ctdocant_Eletr%rowtype;
--
   gt_row_conhec_transp_seg          Conhec_Transp_Seg%rowtype;
--
   gt_rown_ctrodo_inf_valeped        ctrodo_inf_valeped%rowtype;
--
   gt_row_conhec_transp_rodo         Conhec_Transp_Rodo%rowtype;
--
   gt_row_ctrodo_occ                 Ctrodo_Occ%rowtype;
--
   gt_row_ctrodo_valeped             Ctrodo_Valeped%rowtype;
--
   gt_row_ctrodo_valeped_disp        Ctrodo_Valeped_Disp%rowtype;
--
   gt_row_ctrodo_veic                Ctrodo_Veic%rowtype;
--
   gt_row_ctrodo_veic_prop           Ctrodo_Veic_Prop%rowtype;
--
   gt_row_ctrodo_lacre               Ctrodo_Lacre%rowtype;
--
   gt_row_ctrodo_moto                Ctrodo_Moto%rowtype;
--
   gt_row_conhec_transp_aereo        Conhec_Transp_Aereo%rowtype;
--
   gt_row_ct_aereo_dimen             ct_aereo_dimen%rowtype;
--
   gt_row_ct_aereo_inf_man           ct_aereo_inf_man%rowtype;
--
   gt_row_ct_aereo_carg_esp          ct_aereo_carg_esp%rowtype;
--
   gt_row_conhec_transp_aquav        Conhec_Transp_Aquav%rowtype;
--
   gt_row_ctaquav_lacre              Ctaquav_Lacre%rowtype;
--
   gt_row_ct_aquav_balsa             ct_aquav_balsa%rowtype;
--
   gt_row_ctrodo_inf_valeped         ctrodo_inf_valeped%rowtype;
--
   gt_row_ct_aquav_cont              ct_aquav_cont%rowtype;
--
   gt_row_ct_aquav_cont_lacre        ct_aquav_cont_lacre%rowtype;
--
   gt_row_ct_aquav_cont_nf           ct_aquav_cont_nf%rowtype;
--
   gt_row_ct_aquav_cont_nfe          ct_aquav_cont_nfe%rowtype;
--
   gt_row_conhec_transp_ferrov       Conhec_Transp_Ferrov%rowtype;
--
   gt_row_ctferrov_subst             Ctferrov_Subst%rowtype;
--
   gt_row_ctferrov_dcl               Ctferrov_Dcl%rowtype;
--
   gt_row_ctferrovdcl_detvag         Ctferrovdcl_Detvag%rowtype;
--
   gt_row_ctferrovdcldetvag_lacre    Ctferrovdcldetvag_Lacre%rowtype;
--
   gt_row_ctferrovdcldetvag_cont     Ctferrovdcldetvag_Cont%rowtype;
--
   gt_row_ct_ferrov_detvag           ct_ferrov_detvag%rowtype;
--
   gt_row_ct_ferrov_detvag_lacre     ct_ferrov_detvag_lacre%rowtype;
--
   gt_row_ct_ferrov_detvag_cont      ct_ferrov_detvag_cont%rowtype;
--
   gt_row_ct_ferrov_detvag_nf        ct_ferrov_detvag_nf%rowtype;
--
   gt_row_ct_ferrov_detvag_nfe       ct_ferrov_detvag_nfe%rowtype;
--
   gt_row_conhec_transp_duto         Conhec_Transp_Duto%rowtype;
--
   gt_row_conhec_transp_peri         Conhec_Transp_Peri%rowtype;
--
   gt_row_conhec_transp_veic         Conhec_Transp_Veic%rowtype;
--
   gt_row_conhec_transp_fat          conhec_transp_fat%rowtype;
--
   gt_row_conhec_transp_dup          conhec_transp_dup%rowtype;
--
   gt_row_conhec_transp_subst        Conhec_Transp_Subst%rowtype;
--
   gt_row_conhec_transp_compltado    Conhec_Transp_Compltado%rowtype;
--
   gt_row_ctcompltado_comp           Ctcompltado_Comp%rowtype;
--
   gt_row_ctcompltado_imp            Ctcompltado_Imp%rowtype;
--
   gt_row_conhec_transp_anul         Conhec_Transp_Anul%rowtype;
--
   gt_row_conhec_transp_canc         Conhec_Transp_Canc%rowtype;
--
   gt_row_conhec_transp_pdf          Conhec_Transp_Pdf%rowtype;
--
   gt_row_conhec_transp_email        Conhec_Transp_email%rowtype;
--
   gt_row_conhec_transp_impr         Conhec_Transp_impr%rowtype;
--
   gt_row_ct_aut_xml                 ct_aut_xml%rowtype;
--
   gt_row_ct_inf_nf                  ct_inf_nf%rowtype;
--
   gt_row_ct_inf_nfe                 ct_inf_nfe%rowtype;
--
   gt_row_ct_inf_outro               ct_inf_outro%rowtype;
--
   gt_row_ct_inf_unid_transp         ct_inf_unid_transp%rowtype;
--
   gt_row_ct_inf_ut_lacre            ct_inf_unid_transp_lacre%rowtype;
--
   gt_row_ct_inf_ut_carga            ct_inf_unid_transp_carga%rowtype;
--
   gt_row_ct_iut_carga_lacre         ct_iut_carga_lacre%rowtype;
--
   gt_row_ct_inf_unid_carga          ct_inf_unid_carga%rowtype;
--
   gt_row_ct_inf_uc_lacre            ct_inf_unid_carga_lacre%rowtype;
--
   gt_row_r_ctinfnf_ctinfut          r_ctinfnf_ctinfunidtransp%rowtype;
--
   gt_row_r_ctinfnf_ctinfuc          r_ctinfnf_ctinfunidcarga%rowtype;
--
   gt_row_r_ctinfnfe_ctinfut         r_ctinfnfe_ctinfunidtransp%rowtype;
--
   gt_row_r_ctinfnfe_ctinfuc         r_ctinfnfe_ctinfunidcarga%rowtype;
--
   gt_row_r_ctinfoutro_ctinfut       r_ctinfoutro_ctinfunidtransp%rowtype;
--
   gt_row_r_ctinfoutro_ctinfuc       r_ctinfoutro_ctinfunidcarga%rowtype;
--
   gt_row_ct_multimodal              ct_multimodal%rowtype;
--
   gt_row_evento_cte                 evento_cte%rowtype;
--
   gt_row_evento_cte_retorno         evento_cte_retorno%rowtype;
--
   gt_row_evento_cte_epec            evento_cte_epec%rowtype;
--
   gt_row_evento_cte_multimodal      evento_cte_multimodal%rowtype;
--
   gt_row_evento_cte_cce             evento_cte_cce%rowtype;
--
   gt_row_empresa                    Empresa%rowtype;
--
   gt_row_conhec_transp_part_icms    conhec_transp_part_icms%rowtype; -- Atualiza��o CTe 3.0
--
   gt_row_ct_inf_vinc_mult           ct_inf_vinc_mult%rowtype;        -- Atualiza��o CTe 3.0
--
   gt_row_conhec_transp_percurso     conhec_transp_percurso%rowtype;  -- Atualiza��o CTe 3.0
--
   gt_row_ct_doc_ref_os              ct_doc_ref_os%rowtype;           -- Atualiza��o CTe 3.0
--
   gt_row_ct_rodo_os                 ct_rodo_os%rowtype;              -- Atualiza��o CTe 3.0
--
   gt_row_ct_aereo_peri              ct_aereo_peri%rowtype;           -- Atualiza��o CTe 3.0
--
   gt_row_evento_cte_gtv             evento_cte_gtv%rowtype;          -- Atualiza��o CTe 3.0
--
   gt_row_evento_cte_gtv_esp         evento_cte_gtv_esp%rowtype;      -- Atualiza��o CTe 3.0
--
   gt_row_evento_cte_desac           evento_cte_desac%rowtype;        -- Atualiza��o CTe 3.0
--
   gt_row_ct_compdoc_pis             ct_comp_doc_pis%rowtype;
--
   gt_row_ct_compdoc_cofins          ct_comp_doc_cofins%rowtype;
--
----------------------------------------------------------------------------------------------------------------------------------------------------------------

   gv_cabec_log          log_generico_ct.mensagem%TYPE;
   --
   gv_cabec_log_item     Log_Generico_ct.mensagem%TYPE;
   --
   gv_mensagem_log       Log_Generico_ct.mensagem%TYPE;
   --
   gv_dominio            Dominio.descr%TYPE;
   --
   gn_notafiscal_id      Nota_Fiscal.id%TYPE;
   --
   gn_dm_tp_amb          Empresa.dm_tp_amb%TYPE := null;
   --
   gn_empresa_id         Empresa.id%type := null;
   --
   gn_processo_id        Log_Generico_ct.processo_id%TYPE := null;
   --
   gv_obj_referencia     Log_Generico_ct.obj_referencia%type default 'CONHEC_TRANSP';
   --
   gn_referencia_id      Log_Generico_ct.referencia_id%type := null;
   --
   gn_tipo_integr        number := null;
   --
   gn_multorg_id         mult_org.id%type;
   --
   gv_cd_obj             obj_integr.cd%type := '4';
   --
   -- Ser� usado na rotina de exclus�o do CT de convers�o para n�o chamar novamente a pk_csf_api_ct.pkb_excluir_dados_ct
   gn_ind_exclu          number := 0; -- Indica que o CT foi exclu�do (0-N�o / 1-Sim).
   --
   gn_dm_ind_emit        conhec_transp.dm_ind_emit%type := null;
   --
   gn_dm_legado          conhec_transp.dm_legado%type := null;
   --
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Declara��o de constantes
   ERRO_DE_VALIDACAO       CONSTANT NUMBER := 1;
   ERRO_DE_SISTEMA         CONSTANT NUMBER := 2;
   CONHEC_TRANSP_INTEGRADO CONSTANT NUMBER := 34;
   INFORMACAO              CONSTANT NUMBER := 35;
   info_canc_nfe           constant number := 31;

-------------------------------------------------------------------------------------------------------
-- Procedimento de cria��o do e-mail para o Conhec. Transp.
procedure pkb_integr_ct_email ( en_conhectransp_id   in conhec_transp.id%type
                              , en_dm_origem         in conhec_transp_email.dm_origem%type
                              , ev_email             in conhec_transp_email.email%type
                              , en_dm_tipo_anexo     in conhec_transp_email.dm_tipo_anexo%type
                              );

-------------------------------------------------------------------------------------------------------
-- Procedimento seta o tipo de integra��o que ser� feito
-- 0 - Somente valida os dados e registra o Log de ocorr�ncia
-- 1 - Valida os dados e registra o Log de ocorr�ncia e insere a informa��o
-- Todos os procedimentos de integra��o fazem refer�ncia � ele
procedure pkb_seta_tipo_integr ( en_tipo_integr in number );

-------------------------------------------------------------------------------------------------------
-- Procedimento seta o objeto de refer�ncia utilizado na Valida��o da Informa��o
procedure pkb_seta_obj_ref ( ev_objeto in varchar2 );

-------------------------------------------------------------------------------------------------------
-- Procedimento seta o "ID de Referencia" utilizado na Valida��o da Informa��o
procedure pkb_seta_referencia_id ( en_id in number );

-------------------------------------------------------------------------------------------------------
-- Procedimento exclui dados de um Conhecimento de Transporte Eletr�nico
procedure pkb_excluir_dados_ct ( en_conhectransp_id   in Conhec_Transp.id%TYPE
                               , en_excl_rloteintwsct in number default 0 );

-------------------------------------------------------------------------------------------------------
-- Procedimento armazena o valor do "loggenerico_id" do Conhecimento de Transporte Eletr�nico
procedure pkb_gt_log_generico_ct ( en_loggenerico    in             Log_generico_ct.id%TYPE
                                 , est_log_generico  in out nocopy  dbms_sql.number_table );

-------------------------------------------------------------------------------------------------------
-- Procedimento finaliza o Log Gen�rico
procedure pkb_finaliza_log_generico_ct;

-------------------------------------------------------------------------------------------------------
-- Procedimento de registro de log de erros na valida��o da nota fiscal
procedure pkb_log_generico_ct ( sn_loggenerico_id     out nocopy Log_Generico_ct.id%TYPE
                              , ev_mensagem        in            Log_Generico_ct.mensagem%TYPE
                              , ev_resumo          in            Log_Generico_ct.resumo%TYPE
                              , en_tipo_log        in            csf_tipo_log.cd_compat%type      default 1
                              , en_referencia_id   in            Log_Generico_ct.referencia_id%TYPE  default null
                              , ev_obj_referencia  in            Log_Generico_ct.obj_referencia%TYPE default null
                              , en_empresa_id      in            Empresa.Id%type                  default null
                              , en_dm_impressa     in            Log_Generico_ct.dm_impressa%type    default 0 );

-------------------------------------------------------------------------------------------------------
-- Procedimento de cria��o do Evento Presta��o de Servi�o em Desacordo do CTe por parte do Tomador - Atualiza��o CTe 3.0
procedure pkb_integr_evento_cte_desac ( est_log_generico         in out nocopy  dbms_sql.number_table
                                      , est_row_evento_cte_desac in out nocopy  evento_cte_desac%rowtype
                                      , en_conhectransp_id       in             conhec_transp.id%type );

-------------------------------------------------------------------------------------------------------
-- Procedimento de cria��o do Evento de CTe GTV (Grupo de Transporte de Valores) - Esp�cies Transportadas - Atualiza��o CTe 3.0
procedure pkb_integr_evento_cte_gtv_esp ( est_log_generico           in out nocopy  dbms_sql.number_table
                                        , est_row_evento_cte_gtv_esp in out nocopy  evento_cte_gtv_esp%rowtype
                                        , en_conhectransp_id         in             conhec_transp.id%type );

-------------------------------------------------------------------------------------------------------
-- Procedimento de cria��o do Evento de CTe GTV (Grupo de Transporte de Valores) - Atualiza��o CTe 3.0
procedure pkb_integr_evento_cte_gtv ( est_log_generico       in out nocopy  dbms_sql.number_table
                                    , est_row_evento_cte_gtv in out nocopy  evento_cte_gtv%rowtype
                                    , en_conhectransp_id     in             conhec_transp.id%type );

-------------------------------------------------------------------------------------------------------
-- Integra dados do Evento do CTe Carta de Corre��o

procedure pkb_integr_evento_cte_cce ( est_log_generico              in out nocopy  dbms_sql.number_table
                                    , est_row_evento_cte_cce        in out nocopy  evento_cte_cce%rowtype
                                    , en_conhectransp_id            in             conhec_transp.id%type
                                    , ev_estrutcte_grupo            in             estrut_cte.campo%type
                                    , ev_estrutcte_campo            in             estrut_cte.campo%type
                                    );

-------------------------------------------------------------------------------------------------------
-- Integra dados do Evento do CTe Multimodal

procedure pkb_integr_evento_cte_mmodal ( est_log_generico              in out nocopy  dbms_sql.number_table
                                       , est_row_evento_cte_multimodal in out nocopy  evento_cte_multimodal%rowtype
                                       , en_conhectransp_id            in             conhec_transp.id%type
                                       );

-------------------------------------------------------------------------------------------------------
-- Procedimento de cria��o do Evento que integra as informa��es de Eventos do CTe EPEC
procedure pkb_integr_evento_cte_epec ( est_log_generico        in out nocopy  dbms_sql.number_table
                                     , est_row_evento_cte_epec in out nocopy  evento_cte_epec%rowtype
                                     , en_conhectransp_id      in             conhec_transp.id%type );

-------------------------------------------------------------------------------------------------------
-- Integra dados do Evento do CTe

procedure pkb_integr_evento_cte ( est_log_generico              in out nocopy  dbms_sql.number_table
                                , est_row_evento_cte            in out nocopy  evento_cte%rowtype
                                , ev_tipoeventosefaz_cd         in             tipo_evento_sefaz.cd%type
                                );

-------------------------------------------------------------------------------------------------------
-- Integra dados do Multimodal

procedure pkb_integr_ct_multimodal ( est_log_generico              in out nocopy  dbms_sql.number_table
                                   , est_row_ct_multimodal         in out nocopy  ct_multimodal%rowtype
                                   , ev_cod_part_consg             in             pessoa.cod_part%type
                                   , ev_cod_part_red               in             pessoa.cod_part%type
                                   , en_multorg_id                 in             mult_org.id%type
                                   );

-------------------------------------------------------------------------------------------------------
-- Integra o Relacionamento de Outros Documentos com a Unidade de Carga

procedure pkb_integr_r_outro_infuc ( est_log_generico              in out nocopy  dbms_sql.number_table
                                   , est_row_r_outro_infunidcarga  in out nocopy  r_ctinfoutro_ctinfunidcarga%rowtype
                                   , en_conhectransp_id            in             conhec_transp.id%type
                                   , ev_dm_tipo_doc                in             ct_inf_outro.dm_tipo_doc%type
                                   , ev_nro_docto                  in             ct_inf_outro.nro_docto%type
                                   , en_dm_tp_unid_carga           in             ct_inf_unid_carga.dm_tp_unid_carga%type
                                   , ev_ident_unid_carga           in             ct_inf_unid_carga.ident_unid_carga%type
                                   );

-------------------------------------------------------------------------------------------------------
-- Integra o Relacionamento de Outros Documentos com a Unidade de Transporte

procedure pkb_integr_r_outro_infut ( est_log_generico                in out nocopy  dbms_sql.number_table
                                   , est_row_r_outro_infunidtransp   in out nocopy  r_ctinfoutro_ctinfunidtransp%rowtype
                                   , en_conhectransp_id              in             conhec_transp.id%type
                                   , ev_dm_tipo_doc                  in             ct_inf_outro.dm_tipo_doc%type
                                   , ev_nro_docto                    in             ct_inf_outro.nro_docto%type
                                   , en_dm_tp_unid_transp            in             ct_inf_unid_transp.dm_tp_unid_transp%type
                                   , ev_ident_unid_transp            in             ct_inf_unid_transp.ident_unid_transp%type
                                   );

-------------------------------------------------------------------------------------------------------
-- Integra o Relacionamento da NFe com a Unidade de Carga

procedure pkb_integr_r_nfe_infunidcarga ( est_log_generico            in out nocopy  dbms_sql.number_table
                                        , est_row_r_nfe_infunidcarga  in out nocopy  r_ctinfnfe_ctinfunidcarga%rowtype
                                        , en_conhectransp_id          in             conhec_transp.id%type
                                        , ev_nro_chave_nfe            in             ct_inf_nfe.nro_chave_nfe%type
                                        , en_dm_tp_unid_carga         in             ct_inf_unid_carga.dm_tp_unid_carga%type
                                        , ev_ident_unid_carga         in             ct_inf_unid_carga.ident_unid_carga%type
                                        );

-------------------------------------------------------------------------------------------------------
-- Integra o Relacionamento da NFe com a Unidade de Transporte

procedure pkb_integr_r_nfe_infunidtransp ( est_log_generico              in out nocopy  dbms_sql.number_table
                                         , est_row_r_nfe_infunidtransp   in out nocopy  r_ctinfnfe_ctinfunidtransp%rowtype
                                         , en_conhectransp_id            in             conhec_transp.id%type
                                         , ev_nro_chave_nfe              in             ct_inf_nfe.nro_chave_nfe%type
                                         , en_dm_tp_unid_transp          in             ct_inf_unid_transp.dm_tp_unid_transp%type
                                         , ev_ident_unid_transp          in             ct_inf_unid_transp.ident_unid_transp%type
                                         );

-------------------------------------------------------------------------------------------------------
-- Integra o Relacionamento da Nota Fiscal com a Unidade de Carga

procedure pkb_integr_r_nf_infunidcarga ( est_log_generico            in out nocopy  dbms_sql.number_table
                                       , est_row_r_nf_infunidcarga   in out nocopy  r_ctinfnf_ctinfunidcarga%rowtype
                                       , en_conhectransp_id          in             conhec_transp.id%type
                                       , ev_cod_mod_nf               in             mod_fiscal.cod_mod%type
                                       , ev_serie_nf                 in             ct_inf_nf.serie%type
                                       , en_nro_nf                   in             ct_inf_nf.nro_nf%type
                                       , en_dm_tp_unid_carga         in             ct_inf_unid_carga.dm_tp_unid_carga%type
                                       , ev_ident_unid_carga         in             ct_inf_unid_carga.ident_unid_carga%type
                                       );

-------------------------------------------------------------------------------------------------------
-- Integra o Relacionamento da Nota Fiscal com a Unidade de Transporte

procedure pkb_integr_r_nf_infunidtransp ( est_log_generico            in out nocopy  dbms_sql.number_table
                                        , est_row_r_nf_infunidtransp  in out nocopy  r_ctinfnf_ctinfunidtransp%rowtype
                                        , en_conhectransp_id          in             conhec_transp.id%type
                                        , ev_cod_mod_nf               in             mod_fiscal.cod_mod%type
                                        , ev_serie_nf                 in             ct_inf_nf.serie%type
                                        , en_nro_nf                   in             ct_inf_nf.nro_nf%type
                                        , en_dm_tp_unid_transp        in             ct_inf_unid_transp.dm_tp_unid_transp%type
                                        , ev_ident_unid_transp        in             ct_inf_unid_transp.ident_unid_transp%type
                                        );

-------------------------------------------------------------------------------------------------------
-- Integra os Lacres das Unidades de Carga
procedure pkb_integr_ct_ct_iuc_lacre ( est_log_generico         in out nocopy  dbms_sql.number_table
                                     , est_row_ct_iuc_lacre     in out nocopy  ct_inf_unid_carga_lacre%rowtype
                                     , en_conhectransp_id       in             conhec_transp.id%type
                                     );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es das Unidades de Carga
procedure pkb_integr_ct_inf_unid_carga ( est_log_generico               in out nocopy  dbms_sql.number_table
                                       , est_row_ct_inf_unid_carga      in out nocopy  ct_inf_unid_carga%rowtype
                                       );

-------------------------------------------------------------------------------------------------------
-- Integra os Lacres das Unidades de Carga
procedure pkb_integr_ct_iut_carga_lacre ( est_log_generico               in out nocopy  dbms_sql.number_table
                                        , est_row_ct_iut_carga_lacre     in out nocopy  ct_iut_carga_lacre%rowtype
                                        , en_conhectransp_id             in             conhec_transp.id%type
                                        );

-------------------------------------------------------------------------------------------------------
-- Integra os Cargas das Unidades de Transporte
procedure pkb_integr_ct_iut_carga ( est_log_generico         in out nocopy  dbms_sql.number_table
                                  , est_row_ct_iut_carga     in out nocopy  ct_inf_unid_transp_carga%rowtype
                                  , en_conhectransp_id       in             Conhec_Transp.id%TYPE
                                  );

-------------------------------------------------------------------------------------------------------
-- Integra os Lacres das Unidades de Transporte
procedure pkb_integr_ct_iut_lacre ( est_log_generico         in out nocopy  dbms_sql.number_table
                                  , est_row_ct_iut_lacre     in out nocopy  ct_inf_unid_transp_lacre%rowtype
                                  , en_conhectransp_id       in             Conhec_Transp.id%TYPE
                                  );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es das Unidades de Transporte
procedure pkb_integr_ct_inf_unid_transp ( est_log_generico               in out nocopy  dbms_sql.number_table
                                        , est_row_ct_inf_unid_transp     in out nocopy  ct_inf_unid_transp%rowtype
                                        );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas aos demais documentos
procedure pkb_integr_ct_inf_outro ( est_log_generico         in out nocopy  dbms_sql.number_table
                                  , est_row_ct_inf_outro     in out nocopy  ct_inf_outro%rowtype
                                  );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas a NFe do Conhec. Transp.
procedure pkb_integr_ct_inf_nfe ( est_log_generico      in out nocopy  dbms_sql.number_table
                                , est_row_ct_inf_nfe    in out nocopy  ct_inf_nfe%rowtype
                                );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas das NF do Conhecimento de Transporte
procedure pkb_integr_ct_inf_nf ( est_log_generico      in out nocopy  dbms_sql.number_table
                               , est_row_ct_inf_nf     in out nocopy  ct_inf_nf%rowtype
                               , ev_cod_mod            in             Mod_Fiscal.cod_mod%type
                               );

-------------------------------------------------------------------------------------------------------
-- Integra as informa��es de Pessoas Autorizadas a fazer download do XML na Sefaz
procedure pkb_integr_ct_aut_xml ( est_log_generico      in out nocopy  dbms_sql.number_table
                                , est_row_ct_aut_xml    in out nocopy  ct_aut_xml%rowtype
                                );

-------------------------------------------------------------------------------------------------------
-- Integra as informa��es de envio de Impressoras do CTe
procedure pkb_integr_conhec_transp_impr ( est_log_generico   in out nocopy  dbms_sql.number_table
                                        , est_row_ct_impr    in out nocopy  Conhec_Transp_impr%rowtype
                                        );

-------------------------------------------------------------------------------------------------------
-- Integra as informa��es de envio de e-mail do CTe
procedure pkb_integr_conhec_transp_email ( est_log_generico   in out nocopy  dbms_sql.number_table
                                         , est_row_ct_email   in out nocopy  Conhec_Transp_email%rowtype
                                         );

-------------------------------------------------------------------------------------------------------
-- Integra as informa��es do detalhamento do CT-e do Tipo de Anula��o de Valores      conhec_transp_anul
procedure pkb_integr_conhec_transp_anul ( est_log_generico   in out nocopy  dbms_sql.number_table
                                        , est_row_ct_anul    in out nocopy  Conhec_Transp_Anul%rowtype
                                        , en_conhectransp_id in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas aos Impostos de complemento
procedure pkb_integr_ctcompltado_imp ( est_log_generico        in out nocopy  dbms_sql.number_table
                                     , est_row_Imp_ComCt       in out nocopy  Ctcompltado_Imp%rowtype
                                     , en_cd_imp               in             Tipo_Imposto.cd%TYPE
                                     , ev_cod_st               in             Cod_ST.cod_st%TYPE
                                     , en_conhectransp_id      in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas ao Valor da Presta��o de complemento
procedure pkb_integr_ctcompltado_comp ( est_log_generico        in out nocopy  dbms_sql.number_table
                                      , est_row_Comp_Ct         in out nocopy  ctcompltado_comp%rowtype
                                      , en_conhectransp_id      in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas ao Detalhamento do CT-e complementado
procedure pkb_integr_ct_compltado ( est_log_generico        in out nocopy  dbms_sql.number_table
                                  , est_row_ct_compltado    in out nocopy  Conhec_Transp_Compltado%rowtype
                                  , en_conhectransp_id      in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas do CT-e de substitui��o
procedure pkb_integr_conhec_transp_subst ( est_log_generico      in out nocopy  dbms_sql.number_table
                                         , est_row_ct_subst      in out nocopy  Conhec_Transp_Subst%rowtype
                                         , en_conhectransp_id    in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es de Dados da Cobran�a
procedure pkb_integr_conhec_transp_dup ( est_log_generico           in out nocopy  dbms_sql.number_table
                                       , est_row_Conhec_Transp_dup  in out nocopy  Conhec_Transp_dup%rowtype
                                       );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es de Dados da fatura
procedure pkb_integr_conhec_transp_fat ( est_log_generico          in out nocopy  dbms_sql.number_table
                                       , est_row_Conhec_Transp_fat in out nocopy  Conhec_Transp_fat%rowtype
                                       );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es dos ve�culos transportados
procedure pkb_integr_conhec_transp_veic ( est_log_generico        in out nocopy  dbms_sql.number_table
                                        , est_row_ct_veic         in out nocopy  Conhec_Transp_Veic%rowtype
                                        , en_conhectransp_id      in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas a transporte de produtos classificados pela ONU como perigosos
procedure pkb_integr_conhec_transp_peri ( est_log_generico        in out nocopy  dbms_sql.number_table
                                        , est_row_ct_peri         in out nocopy  Conhec_Transp_Peri%rowtype
                                        , en_conhectransp_id      in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas a transporte de produtos classificados pela ONU como perigosos
procedure pkb_integr_conhec_transp_duto ( est_log_generico        in out nocopy  dbms_sql.number_table
                                        , est_row_ct_duto         in out nocopy  Conhec_Transp_Duto%rowtype
                                        , en_conhectransp_id      in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas aos containeres contidos no vag�o com DCL
procedure pkb_integr_ctferr_cont ( est_log_generico        in out nocopy  dbms_sql.number_table
                                 , est_row_ctferr_cont     in out nocopy  Ctferrovdcldetvag_Cont%rowtype
                                 , en_conhectransp_id      in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas aos Lacres dos vag�es do DCL
procedure pkb_integr_ctferr_lacre ( est_log_generico        in out nocopy  dbms_sql.number_table
                                  , est_row_ctferr_lacre    in out nocopy  Ctferrovdcldetvag_Lacre%rowtype
                                  , en_conhectransp_id      in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas aos de detalhes dos Vag�es
procedure pkb_integr_ctferrovdcl_detvag ( est_log_generico        in out nocopy  dbms_sql.number_table
                                        , est_row_ctferr_detvag   in out nocopy  Ctferrovdcl_Detvag%rowtype
                                        , en_conhectransp_id      in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas ao DCL
procedure pkb_integr_ctferrov_dcl ( est_log_generico        in out nocopy  dbms_sql.number_table
                                  , est_row_ctferr_dcl      in out nocopy  Ctferrov_Dcl%rowtype
                                  , en_conhectransp_id      in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas a Dados do endere�o da ferrovia substitu�da
procedure pkb_integr_ctferrov_subst ( est_log_generico        in out nocopy  dbms_sql.number_table
                                    , est_row_ctferr_subst    in out nocopy  Ctferrov_Subst%rowtype
                                    , en_conhectransp_id      in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas modal Ferrovi�rio
procedure pkb_integr_ct_ferrov ( est_log_generico        in out nocopy  dbms_sql.number_table
                               , est_row_ct_ferrov       in out nocopy  Conhec_Transp_Ferrov%rowtype
                               , en_conhectransp_id      in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas ao lacres dos cointainers da qtde da carga no modal Aquavi�rio.
procedure pkb_integr_ctaquav_lacre ( est_log_generico        in out nocopy  dbms_sql.number_table
                                   , est_row_ctaquav_lacre   in out nocopy  Ctaquav_Lacre%rowtype
                                   , en_conhectransp_id      in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas modal Aquavi�rio.
procedure pkb_integr_conhec_transp_aquav ( est_log_generico      in out nocopy  dbms_sql.number_table
                                         , est_row_ct_aquav      in out nocopy  Conhec_Transp_Aquav%rowtype
                                         , en_conhectransp_id    in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Procedimento de cria��o das Informa��es do Transporte de produtos classificados pela ONU como perigosos - Atualiza��o CTe 3.0
procedure pkb_integr_ct_aereo_peri ( est_log_generico        in out nocopy dbms_sql.number_table
                                   , est_row_ct_aereo_peri   in out nocopy ct_aereo_peri%rowtype
                                   , en_conhectransp_id      in            conhec_transp.id%type );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas modal A�reo.
procedure pkb_integr_conhec_transp_aereo ( est_log_generico      in out nocopy  dbms_sql.number_table
                                         , est_row_ct_aereo      in out nocopy  Conhec_Transp_Aereo%rowtype
                                         , en_conhectransp_id    in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas aos motorista (rodovi�rio).
procedure pkb_integr_ctrodo_moto ( est_log_generico        in out nocopy  dbms_sql.number_table
                                 , est_row_ctrodo_moto     in out nocopy  Ctrodo_Moto%rowtype
                                 , en_conhectransp_id      in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas Dados dos Ve�culos (Lacre).
procedure pkb_integr_ctrodo_lacre ( est_log_generico        in out nocopy  dbms_sql.number_table
                                  , est_row_ctrodo_lacre    in out nocopy  Ctrodo_Lacre%rowtype
                                  , en_conhectransp_id      in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas aos Propriet�rios do Ve�culo.
procedure pkb_integr_ctrodo_veic_prop ( est_log_generico         in out nocopy  dbms_sql.number_table
                                      , est_row_ctrodo_veic_prop in out nocopy  Ctrodo_Veic_Prop%rowtype
                                      , en_conhectransp_id       in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas aos Dados do Ve�culo.
procedure pkb_integr_ctrodo_veic ( est_log_generico         in out nocopy  dbms_sql.number_table
                                 , est_row_ctrodo_veic      in out nocopy  Ctrodo_Veic%rowtype
                                 , en_conhectransp_id       in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas dispositivos do Vale Ped�gio.
procedure pkb_integr_ctrodo_valeped_disp ( est_log_generico            in out nocopy  dbms_sql.number_table
                                         , est_row_ctrodo_valeped_disp in out nocopy  Ctrodo_Valeped_Disp%rowtype
                                         , en_conhectransp_id          in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas Vale Ped�gio.
procedure pkb_integr_ctrodo_valeped ( est_log_generico       in out nocopy  dbms_sql.number_table
                                    , est_row_ctrodo_valeped in out nocopy  Ctrodo_Valeped%rowtype
                                    , en_conhectransp_id     in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es de Vale Ped�gio
procedure pkb_integr_ctrodo_inf_valeped ( est_log_generico             in out nocopy  dbms_sql.number_table
                                        , est_row_ctrodo_inf_valeped   in out nocopy  ctrodo_inf_valeped%rowtype
                                        , en_conhectransp_id           in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Procedimento de cria��o das Informa��es do modal Rodovi�rio CTe Outros Servi�os - Atualiza��o CTe 3.0
procedure pkb_integr_ct_rodo_os ( est_log_generico      in out nocopy dbms_sql.number_table
                                , est_row_ct_rodo_os    in out nocopy ct_rodo_os%rowtype
                                , en_conhectransp_id    in            conhec_transp.id%type );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es da Dimens�o da Carga do Modal A�reo.
procedure pkb_integr_ct_aereo_dimen ( est_log_generico             in out nocopy  dbms_sql.number_table
                                    , est_row_ct_aereo_dimen       in out nocopy  ct_aereo_dimen%rowtype
                                    , en_conhectransp_id           in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es do manuseio da carga do modal A�reo.
procedure pkb_integr_ct_aereo_inf_man ( est_log_generico             in out nocopy  dbms_sql.number_table
                                      , est_row_ct_aereo_inf_man     in out nocopy  ct_aereo_inf_man%rowtype
                                      , en_conhectransp_id           in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es do manuseio da carga especial do modal A�reo.
procedure pkb_integr_ct_aereo_carg_esp ( est_log_generico             in out nocopy  dbms_sql.number_table
                                       , est_row_ct_aereo_carg_esp    in out nocopy  ct_aereo_carg_esp%rowtype
                                       , en_conhectransp_id           in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es de Balsas do modal Aquavi�rio.
procedure pkb_integr_ct_aquav_balsa ( est_log_generico          in out nocopy  dbms_sql.number_table
                                    , est_row_ct_aquav_balsa    in out nocopy  ct_aquav_balsa%rowtype
                                    , en_conhectransp_id        in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es de Conteiners do modal Aquavi�rio.
procedure pkb_integr_ct_aquav_cont ( est_log_generico          in out nocopy  dbms_sql.number_table
                                   , est_row_ct_aquav_cont     in out nocopy  ct_aquav_cont%rowtype
                                   , en_conhectransp_id        in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es de Lacres de Conteiners do modal Aquavi�rio.
procedure pkb_integr_ct_aquav_cont_lacre ( est_log_generico             in out nocopy  dbms_sql.number_table
                                         , est_row_ct_aquav_cont_lacre  in out nocopy  ct_aquav_cont_lacre%rowtype
                                         , en_conhectransp_id           in             Conhec_Transp.id%TYPE );
-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es de Notas de Conteiners do modal Aquavi�rio.
procedure pkb_integr_ct_aquav_cont_nf ( est_log_generico            in out nocopy dbms_sql.number_table
                                      , est_row_ct_aquav_cont_nf    in out nocopy ct_aquav_cont_nf%rowtype
                                      , en_conhectransp_id          in            Conhec_Transp.id%TYPE );
-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es de Notas fiscais eletr�nicas de Conteiners do modal Aquavi�rio.
procedure pkb_integr_ct_aquav_cont_nfe ( est_log_generico            in out nocopy dbms_sql.number_table
                                       , est_row_ct_aquav_cont_nfe   in out nocopy ct_aquav_cont_nfe%rowtype
                                       , en_conhectransp_id          in            Conhec_Transp.id%TYPE );
-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es de detalhes dos vag�es.
procedure pkb_integr_ct_ferrov_detvag    ( est_log_generico            in out nocopy  dbms_sql.number_table
                                         , est_row_ct_ferrov_detvag    in out nocopy  ct_ferrov_detvag%rowtype
                                         , en_conhectransp_id          in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es de lacres dos vag�es.
procedure pkb_integr_ct_fer_detvag_lacre  ( est_log_generico                 in out nocopy  dbms_sql.number_table
                                          , est_row_ct_ferrov_detvag_lacre   in out nocopy  ct_ferrov_detvag_lacre%rowtype
                                          , en_conhectransp_id               in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es de conteiners dos vag�es.
procedure pkb_integr_ct_fer_detvag_cont  ( est_log_generico                in out nocopy  dbms_sql.number_table
                                         , est_row_ct_ferrov_detvag_cont   in out nocopy  ct_ferrov_detvag_cont%rowtype
                                         , en_conhectransp_id              in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es de Rateio das NF de Vag�es.
procedure pkb_integr_ct_ferrov_detvag_nf   ( est_log_generico               in out nocopy  dbms_sql.number_table
                                           , est_row_ct_ferrov_detvag_nf    in out nocopy  ct_ferrov_detvag_nf%rowtype
                                           , en_conhectransp_id             in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es de Rateio das NFe de Vag�es.
procedure pkb_integr_ct_fer_detvag_nfe  ( est_log_generico               in out nocopy  dbms_sql.number_table
                                        , est_row_ct_ferrov_detvag_nfe   in out nocopy  ct_ferrov_detvag_nfe%rowtype
                                        , en_conhectransp_id             in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas Ordens de Coleta associados.
procedure pkb_integr_ctrodo_occ ( est_log_generico       in out nocopy  dbms_sql.number_table
                                , est_row_ctrodo_occ     in out nocopy  Ctrodo_Occ%rowtype
                                , en_conhectransp_id     in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas ao do modal Rodovi�rio.
procedure pkb_integr_conhec_transp_rodo ( est_log_generico           in out nocopy  dbms_sql.number_table
                                        , est_row_conhec_transp_rodo in out nocopy  Conhec_Transp_Rodo%rowtype
                                        , en_conhectransp_id         in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas ao Seguro da Carga.
procedure pkb_integr_conhec_transp_seg ( est_log_generico          in out nocopy  dbms_sql.number_table
                                       , est_row_conhec_transp_seg in out nocopy  Conhec_Transp_Seg%rowtype
                                       , en_conhectransp_id        in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas ao Documentos de transporte anterior eletr�nicos.
procedure pkb_integr_ctdocant_eletr ( est_log_generico       in out nocopy  dbms_sql.number_table
                                    , est_row_ctdocant_eletr in out nocopy  Ctdocant_Eletr%rowtype
                                    , en_conhectransp_id     in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas ao Documentos de transporte anterior papel.
procedure pkb_integr_ctdocant_papel ( est_log_generico       in out nocopy  dbms_sql.number_table
                                    , est_row_ctdocant_papel in out nocopy  Ctdocant_Papel%rowtype
                                    , en_conhectransp_id     in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas ao Transporte Anterior.
procedure pkb_integr_conhectransp_docant ( est_log_generico            in out nocopy  dbms_sql.number_table
                                         , est_row_conhectransp_docant in out nocopy  Conhec_Transp_Docant%rowtype
                                         , en_conhectransp_id          in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas aos Lacres dos containers.
procedure pkb_integr_ctcont_lacre ( est_log_generico            in out nocopy  dbms_sql.number_table
                                  , est_row_ctcont_lacre        in out nocopy  Ctcont_Lacre%rowtype
                                  , en_conhectransp_id          in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas a Informa��es dos containers.
procedure pkb_integr_conhec_transp_cont ( est_log_generico            in out nocopy  dbms_sql.number_table
                                        , est_row_conhec_transp_cont  in out nocopy  Conhec_Transp_Cont%rowtype
                                        , en_conhectransp_id          in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas a Informa��es de quantidades da Carga do CT.
procedure pkb_integr_ctinfcarga_qtde ( est_log_generico         in out nocopy  dbms_sql.number_table
                                     , est_row_ctinfcarga_qtde  in out nocopy  Ctinfcarga_Qtde%rowtype
                                     , en_conhectransp_id       in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas a Informa��es da Carga do CT-e.
procedure pkb_integr_ct_infcarga ( est_log_generico     in out nocopy  dbms_sql.number_table
                                 , est_row_ct_infcarga  in out nocopy  Conhec_Transp_Infcarga%rowtype
                                 , en_conhectransp_id   in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Procedimento de cria��o das Informa��es do ICMS de partilha com a UF de t�rmino do servi�o de transporte na opera��o interestadual - Atualiza��o CTe 3.0
procedure pkb_integr_ct_part_icms ( est_log_generico     in out nocopy dbms_sql.number_table
                                  , est_row_ct_part_icms in out nocopy conhec_transp_part_icms%rowtype
                                  , en_conhectransp_id   in            conhec_transp.id%type );

-------------------------------------------------------------------------------------------------------
-- Procedimento de cria��o das Informa��es do CT-e multimodal vinculado - Atualiza��o CTe 3.0
procedure pkb_integr_ct_inf_vinc_mult ( est_log_generico         in out nocopy dbms_sql.number_table
                                      , est_row_ct_inf_vinc_mult in out nocopy ct_inf_vinc_mult%rowtype
                                      , en_conhectransp_id       in            conhec_transp.id%type );
                                      
-------------------------------------------------------------------------------------------------------
-- Procedimento de cria��o das Informa��es do Percurso do CT-e Outros Servi�os - Atualiza��o CTe 3.0
procedure pkb_integr_ct_transp_percurso ( est_log_generico           in out nocopy dbms_sql.number_table
                                        , est_row_ct_transp_percurso in out nocopy conhec_transp_percurso%rowtype
                                        , ev_sigla_estado            in            estado.sigla_estado%type
                                        , en_conhectransp_id         in            conhec_transp.id%type );

-------------------------------------------------------------------------------------------------------
-- Procedimento de cria��o das Informa��es dos documentos referenciados CTe Outros Servi�os - Atualiza��o CTe 3.0
procedure pkb_integr_ct_doc_ref_os ( est_log_generico      in out nocopy dbms_sql.number_table
                                   , est_row_ct_doc_ref_os in out nocopy ct_doc_ref_os%rowtype
                                   , en_conhectransp_id    in            conhec_transp.id%type );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas aos Impostos.
procedure pkb_integr_conhec_transp_imp ( est_log_generico          in out nocopy  dbms_sql.number_table
                                       , est_row_conhec_transp_imp in out nocopy  Conhec_Transp_Imp%rowtype
                                       , en_cd_imp                 in             Tipo_Imposto.cd%TYPE
                                       , ev_cod_st                 in             Cod_ST.cod_st%TYPE
                                       , en_conhectransp_id        in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas aos Impostos - Flex Field.
procedure pkb_integr_ct_imp_ff ( est_log_generico       in out nocopy  dbms_sql.number_table
                               , en_conhectranspimp_id  in             conhec_transp_imp.id%type
                               , ev_atributo            in             varchar2
                               , ev_valor               in             varchar2 );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas Componentes do Valor da Presta��o.
procedure pkb_integr_ctvlprest_comp ( est_log_generico          in out nocopy  dbms_sql.number_table
                                    , est_row_ctvlprest_comp    in out nocopy  Ctvlprest_Comp%rowtype
                                    , en_conhectransp_id        in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas aos Valores da Presta��o de Servi�o.
procedure pkb_integr_ct_vlprest ( est_log_generico      in out nocopy  dbms_sql.number_table
                                , est_row_ct_vlprest    in out nocopy  Conhec_Transp_Vlprest%rowtype
                                , en_conhectransp_id    in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas ao Local de Entrega constante na Nota Fiscal.
procedure pkb_integr_ctdest_locent ( est_log_generico      in out nocopy  dbms_sql.number_table
                                   , est_row_ctdest_locent in out nocopy  Ctdest_Locent%rowtype
                                   , en_conhectransp_id    in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas ao do Destinat�rio do CT.
procedure pkb_integr_conhec_transp_dest ( est_log_generico           in out nocopy  dbms_sql.number_table
                                        , est_row_conhec_transp_dest in out nocopy  Conhec_Transp_Dest%rowtype
                                        , en_conhectransp_id         in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas ao do Recebedor da Carga.
procedure pkb_integr_conhec_transp_receb ( est_log_generico            in out nocopy  dbms_sql.number_table
                                         , est_row_conhec_transp_receb in out nocopy  Conhec_Transp_Receb%rowtype
                                         , en_conhectransp_id          in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas ao Expedidor da Carga.
procedure pkb_integr_conhec_transp_exped ( est_log_generico            in out nocopy  dbms_sql.number_table
                                         , est_row_conhec_transp_exped in out nocopy  Conhec_Transp_Exped%rowtype
                                         , en_conhectransp_id          in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas aos demais documentos.
procedure pkb_integr_ctrem_inf_outro ( est_log_generico         in out nocopy  dbms_sql.number_table
                                     , est_row_ctrem_inf_outro  in out nocopy  Ctrem_Inf_Outro%rowtype
                                     , en_conhectransp_id       in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas a NFe do remetente
procedure pkb_integr_ctrem_inf_nfe ( est_log_generico         in out nocopy  dbms_sql.number_table
                                   , est_row_ctrem_inf_nfe    in out nocopy  Ctrem_Inf_Nfe%rowtype
                                   , en_conhectransp_id       in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas ao Local de retirada constante na NF
procedure pkb_integr_ctrem_inf_nf_locret ( est_log_generico            in out nocopy  dbms_sql.number_table
                                         , est_row_ctrem_inf_nf_locret in out nocopy  Ctrem_Inf_Nf_Locret%rowtype
                                         , en_conhectransp_id          in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas das NF do remetente
procedure pkb_integr_ctrem_inf_nf ( est_log_generico      in out nocopy  dbms_sql.number_table
                                  , est_row_ctrem_inf_nf  in out nocopy  Ctrem_Inf_Nf%rowtype
                                  , en_conhectransp_id    in             Conhec_Transp.id%TYPE
                                  , ev_cod_mod            in             Mod_Fiscal.cod_mod%type );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas ao Local da Coleta do Remetente
procedure pkb_integr_ctrem_loc_colet ( est_log_generico         in out nocopy dbms_sql.number_table
                                     , est_row_ctrem_loc_colet  in out nocopy ctrem_loc_colet%rowtype
                                     , en_conhectransp_id       in            Conhec_Transp.id%TYPE
                                     );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas ao Remetente das mercadorias transportadas pelo CT.
procedure pkb_integr_conhec_transp_rem ( est_log_generico          in out nocopy  dbms_sql.number_table
                                       , est_row_conhec_transp_rem in out nocopy  Conhec_Transp_Rem%rowtype
                                       , en_conhectransp_id        in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas do Emitente do CT.
procedure pkb_integr_conhec_transp_emit ( est_log_generico           in out nocopy  dbms_sql.number_table
                                        , est_row_conhec_transp_emit in out nocopy  Conhec_Transp_Emit%rowtype
                                        , en_conhectransp_id         in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas ao Observa��es do Contribuinte/Fiscal
procedure pkb_integr_ct_compl_obs ( est_log_generico      in out nocopy  dbms_sql.number_table
                                  , est_row_ct_compl_obs  in out nocopy  Ct_Compl_Obs%rowtype
                                  , en_conhectransp_id    in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas a Sigla ou c�digo interno da Filial/Porto/Esta��o/Aeroporto de Passagem
procedure pkb_integr_ct_compl_pass ( est_log_generico      in out nocopy  dbms_sql.number_table
                                   , est_row_ct_compl_pass in out nocopy  Ct_Compl_Pass%rowtype
                                   , en_conhectransp_id    in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas aos Dados compl. do CT-e para fins operacionais ou comerciais
procedure pkb_integr_conhec_transp_compl ( est_log_generico            in out nocopy  dbms_sql.number_table
                                         , est_row_conhec_transp_compl in out nocopy  Conhec_Transp_Compl%rowtype
                                         , en_conhectransp_id          in             Conhec_Transp.id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas ao Indicador do "papel" do tomador do servi�o no CT-e, pessoa que o servi�o foi prestado
procedure pkb_integr_ct_tomador ( est_log_generico     in out nocopy  dbms_sql.number_table
                                , est_row_ct_tomador   in out nocopy  Conhec_Transp_Tomador%rowtype
                                , en_conhectransp_id   in             Conhec_Transp.id%TYPE );
-------------------------------------------------------------------------------------------------------
-- Integra as Informa��es relativas aos Dados compl. do CT-e para fins operacionais ou comerciais
procedure pkb_integr_conhec_transp ( est_log_generico           in out nocopy  dbms_sql.number_table
                                   , est_row_conhec_transp      in out nocopy  Conhec_Transp%rowtype
                                   , ev_cod_mod                 in             Mod_Fiscal.cod_mod%TYPE
                                   , ev_cod_matriz              in             Empresa.cod_matriz%TYPE  default null
                                   , ev_cod_filial              in             Empresa.cod_filial%TYPE  default null
                                   , ev_empresa_cpf_cnpj        in             varchar2                 default null -- CPF/CNPJ da empresa
                                   , ev_cod_part                in             Pessoa.cod_part%TYPE     default null
                                   , ev_cd_sitdocto             in             Sit_Docto.cd%TYPE        default null
                                   , ev_cod_infor               in             Infor_Comp_Dcto_Fiscal.cod_infor%TYPE        default null
                                   , ev_sist_orig               in             sist_orig.sigla%type     default null
                                   , ev_cod_unid_org            in             unid_org.cd%type         default null
                                   , en_multorg_id              in             mult_org.id%type
                                   , en_empresaintegrbanco_id   in             empresa_integr_banco.id%type default null
                                   , en_loteintws_id            in             lote_int_ws.id%type default 0
                                   );

-------------------------------------------------------------------------------------------------------
-- Procedimento v�lida a chave de acesso do CTe
procedure pkb_valida_chave_acesso ( est_log_generico     in out nocopy  dbms_sql.number_table
                                  , ev_nro_chave_cte     in             conhec_transp.nro_chave_cte%TYPE
                                  , en_empresa_id        in             Empresa.id%TYPE
                                  , en_pessoa_id         in             pessoa.id%type
                                  , en_dm_ind_emit       in             conhec_transp.dm_ind_emit%type
                                  , ed_dt_hr_emissao     in             conhec_transp.dt_hr_emissao%TYPE
                                  , ev_cod_mod           in             Mod_Fiscal.cod_mod%TYPE
                                  , en_serie             in             conhec_transp.serie%TYPE
                                  , en_nro_ct            in             conhec_transp.nro_ct%TYPE
                                  , en_dm_forma_emiss    in             conhec_transp.dm_forma_emiss%type
                                  , sn_cCT_cte           out            conhec_transp.cCT_cte%TYPE
                                  , sn_dig_verif_chave   out            conhec_transp.dig_verif_chave%TYPE
                                  , sn_qtde_erro         out            number );

-------------------------------------------------------------------------------------------------------
-- Procedimento integra a Chave do Conhecimento de Transporte
procedure pkb_integr_CTChave_Refer ( est_log_generico     in out nocopy  dbms_sql.number_table
                                   , en_empresa_id        in             Empresa.id%TYPE
                                   , en_conhectransp_id   in             Conhec_Transp.id%TYPE
                                   , ed_dt_hr_emissao     in             Conhec_Transp.dt_hr_emissao%TYPE
                                   , ev_cod_mod           in             Mod_Fiscal.cod_mod%TYPE
                                   , en_serie             in             Conhec_Transp.serie%TYPE
                                   , en_nro_ct            in             Conhec_Transp.nro_ct%TYPE
                                   , en_dm_forma_emiss    in             Conhec_Transp.dm_forma_emiss%type
                                   , esn_cCT_cte          in out nocopy  Conhec_Transp.cCT_cte%TYPE
                                   , sn_dig_verif_chave   out            Conhec_Transp.dig_verif_chave%TYPE
                                   , sv_nro_chave_cte     out            Conhec_Transp.nro_chave_cte%TYPE
                                   );

-------------------------------------------------------------------------------------------------------

-- Fun��o cria o Lote de Envio da Nota Fiscal e retorna o ID
function fkg_integr_lote_cte ( est_log_generico     in out nocopy  dbms_sql.number_table
                             , en_empresa_id        in             Empresa.id%type
                             , en_modfiscal_id      in             Mod_Fiscal.id%type  --Atualiza��o CTe 3.0
                             ) return lote_cte.id%TYPE;

-------------------------------------------------------------------------------------------------------
-- Re-envia lote que teve erro ao ser enviado a SEFAZ
procedure pkb_reenvia_lote_cte;

-------------------------------------------------------------------------------------
-- Procedimento ajusta lotes que est�o com a situa��o 2-conclu�do e suas notas n�o
PROCEDURE PKB_AJUSTA_LOTE_CTE ( en_multorg_id in mult_org.id%type );

-------------------------------------------------------------------------------------------------------
-- Procedimento excluir lotes sem Conhecimento de Transportes
procedure pkb_excluir_lote_sem_cte ( en_multorg_id in mult_org.id%type default 0);

-------------------------------------------------------------------------------------------------------
-- Processo de cria��o do Lote de Conhecimento de Transportes
procedure pkb_gera_lote_cte ( en_multorg_id in mult_org.id%type );

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna os conhecimentos de transportes que n�o pode ser inutilizadas
function fkg_ct_nao_inutiliza ( en_empresa_id   in  Inutiliza_Conhec_Transp.empresa_id%TYPE
                              , en_dm_tp_amb    in  Inutiliza_Conhec_Transp.dm_tp_amb%TYPE
                              , ev_cod_mod      in  Mod_Fiscal.cod_mod%TYPE
                              , en_serie        in  Inutiliza_Conhec_Transp.serie%TYPE
                              , en_nro_ini      in  Inutiliza_Conhec_Transp.nro_ini%TYPE
                              , en_nro_fim      in  Inutiliza_Conhec_Transp.nro_fim%TYPE )
          return varchar2;

-------------------------------------------------------------------------------------------------------
-- Procedimento faz a integra��o da Inutiliza��o do Conhecimento de Transporte
procedure pkb_integr_inutilizact ( est_log_generico           in out nocopy  dbms_sql.number_table
                                 , est_row_Inutiliza_Ct       in out nocopy  Inutiliza_Conhec_Transp%rowtype
                                 , ev_cod_mod                 in             Mod_Fiscal.cod_mod%TYPE
                                 );

-------------------------------------------------------------------------------------------------------
-- procedimento de atualiar CT-e inutilizadas
-- Depois de Homologado a Inutiliza��o, verifica se tem algum CTe vinculada e
-- Altera o DM_ST_PROC para 8-Inutilizada e a Situa��o do Documento para "05-NF-e ou CT-e - Numera��o inutilizada"
procedure pkb_atual_cte_inut ( en_multorg_id in mult_org.id%type );

-------------------------------------------------------------------------------------------------------
-- Procedimento de atualiza��o do campo CONHECTRANSP_ID da tabela CT_CONS_SIT
-- Pega todos os registros que o campo CONHECTRANSP_ID est�o nulos, verifica se sua chave de acesso existe
-- na tabela CONHEC_TRANSP, se exitir relacionar o campo CONHECTRANSP_ID.ID com campo CSF_CONS_SIT.CONHECTRANSP_ID
procedure pkb_relac_cte_cons_sit ( en_multorg_id in mult_org.id%type );

--------------------------------------------------------------------------------------------------------
-- Metodo para consultar CTe de Terceiro, com "Data de Autoriza��o" menor que sete dias da data atual --
-- serve para verificar se o emitente da CTe cancelou a mesma                                         --
--------------------------------------------------------------------------------------------------------
PROCEDURE PKB_CONS_CTE_TERC ( en_multorg_id  in mult_org.id%type );

-------------------------------------------------------------------------------------------------------
-- Atualiza Situa��o do Conhecimento de Transporte
procedure pkb_atual_sit_docto ( en_multorg_id in mult_org.id%type );

-------------------------------------------------------------------------------------------------------
-- Procedimento que busca todas as Inutiliza��es com a situa��o "5-N�o Validada"
procedure pkb_consit_inutilizacao ( en_multorg_id in mult_org.id%type );

-------------------------------------------------------------------------------------------------------
-- Procedimento que faz a integra��o os CT-e Cancelados
procedure pkb_integr_Conhec_Transp_Canc ( est_log_generico            in out nocopy  dbms_sql.number_table
                                        , est_row_Conhec_Transp_Canc  in out nocopy  Conhec_Transp_Canc%rowtype
                                        , en_loteintws_id             in             lote_int_ws.id%type default 0
                                        );

-------------------------------------------------------------------------------------------------------
-- Procedimento valida informa��o de Anula��o de CT-e
-- Verifica se as informa��es inseridas est�o dentro das regras de neg�cios expostas no Layout do Ct-e vers�o 1.03.
procedure pkb_valida_infor_anulacao ( est_log_generico     in out nocopy  dbms_sql.number_table
                                    , en_conhectransp_id   in             Conhec_Transp.Id%TYPE );

-------------------------------------------------------------------------------------------------------
-- Procedure que consiste os dados do Conhecimento de Transporte
procedure pkb_consistem_ct ( est_log_generico     in out nocopy  dbms_sql.number_table
                           , en_conhectransp_id   in             Conhec_Transp.Id%TYPE
                           );

-------------------------------------------------------------------------------------------------------
-- Fun��o para validar os conhecimentos de transporte - utilizada nas rotinas de valida��es da GIA, Sped Fiscal e Contribui��es
function fkg_valida_ct ( en_empresa_id      in  empresa.id%type
                       , ed_dt_ini          in  date
                       , ed_dt_fin          in  date
                       , ev_obj_referencia  in  log_generico_ct.obj_referencia%type -- processo que acessa a fun��o: sped ou gia
                       , en_referencia_id   in  log_generico_ct.referencia_id%type ) -- identificador do processo que acessar: sped ou gia
         return boolean;

-------------------------------------------------------------------------------------------------------

procedure pkb_ret_multorg_id( est_log_generico       in out nocopy  dbms_sql.number_table
                            , ev_cod_mult_org        in             mult_org.cd%type
                            , ev_hash_mult_org       in             mult_org.hash%type
                            , sn_multorg_id          in out nocopy  mult_org.id%type
                            , ev_obj_referencia      in             log_generico_ct.obj_referencia%type
                            , en_referencia_id       in             log_generico_ct.referencia_id%type
                            );

-------------------------------------------------------------------------------------------------------

-- Procedimento valida o mult org de acordo com o COD e o HASH das tabelas Flex-Field

procedure pkb_val_atrib_multorg ( est_log_generico   in out nocopy  dbms_sql.number_table
                                , ev_obj_name        in             VARCHAR2
                                , ev_atributo        in             VARCHAR2
                                , ev_valor           in             VARCHAR2
                                , sv_cod_mult_org    out            VARCHAR2
                                , sv_hash_mult_org   out            VARCHAR2
                                , ev_obj_referencia  in             log_generico_ct.obj_referencia%type
                                , en_referencia_id   in             log_generico_ct.referencia_id%type
                                );

-------------------------------------------------------------------------------------------------------

procedure pkb_cria_nat_oper( ev_cod_nat         nat_oper.cod_nat%type
                           , ev_descr_nat       nat_oper.descr_nat%type default null
                           , en_multorg_id      mult_org.id%type);

-------------------------------------------------------------------------------------------------------

--| Fun��o retorna o ID da NAT_OPER pelo cod_nat

function fkg_natoper_id_cod_nat ( en_multorg_id in mult_org.id%type
                                , ev_cod_nat    in Nat_Oper.cod_nat%TYPE)
return Nat_Oper.id%TYPE;
-------------------------------------------------------------------------------------------------------
--
-- Procedimento integra o imposto de PIS
-- =================================================================================================================== --
procedure pkb_integr_ctimpout_pis ( est_log_generico              in out nocopy dbms_sql.number_table
                                  , est_row_ct_comp_doc_pis       in out nocopy ct_comp_doc_pis%rowtype
                                  , ev_cpf_cnpj_emit              in            varchar2
                                  , ev_cod_st                     in            cod_st.cod_st%type
                                  , ev_cod_bc_cred_pc             in            base_calc_cred_pc.cd%type
                                  , ev_cod_cta                    in            plano_conta.cod_cta%type
                                  , en_multorg_id                 in            mult_org.id%type );
--
-- Procedimento integra o imposto de CONFINS
-- =================================================================================================================== --
procedure pkb_integr_ctimpout_cofins ( est_log_generico        in out nocopy  dbms_sql.number_table
                                     , est_ct_comp_doc_cofins  in out nocopy  ct_comp_doc_cofins%rowtype
                                     , ev_cpf_cnpj_emit        in             varchar2
                                     , ev_cod_st               in             cod_st.cod_st%type
                                     , ev_cod_bc_cred_pc       in             base_calc_cred_pc.cd%type
                                     , ev_cod_cta              in             plano_conta.cod_cta%type
                                     , en_multorg_id           in             mult_org.id%type );
-- =================================================================================================================== --
--
-------------------------------------------------------------------------------------------------------------------------------------
-- Fun��o para retornar o tipo de emitente d� conhecimento de transporte - conhec_transp.dm_ind_emit = 0-emiss�o pr�pria, 1-terceiros
-------------------------------------------------------------------------------------------------------------------------------------
function fkg_dmindemit_conhectransp ( en_conhectransp_id in conhec_transp.id%type )
return conhec_transp.dm_ind_emit%type;
--
----------------------------------------------------------------------------
-- Fun��o para verificar se existe registro de erro grvados no Log Generico
----------------------------------------------------------------------------
function fkg_ver_erro_log_generico_ct ( en_conhec_transp_id in conhec_transp.id%type )
return number;
--
end PK_CSF_API_CT;
/
