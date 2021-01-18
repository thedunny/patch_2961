create or replace package pk_csf_api_d100 is

----------------------------------------------------------------------------------------------------------
-- Especifica��o do pacote de procedimentos de integra��o e valida��o do Registro D100.
----------------------------------------------------------------------------------------------------------
--
-- Em 12/01/2020 - Eduardo Linden
-- Redmine #75121 (Feedback) - Inclus�o de parametriza��o para preenchimento do Codigo do Tipo Servi�o Reinf para CTE modelo 67
-- Remo��o cod_part da pesquisa do parametro e inclus�o do campo empresa_id.
-- Rotinas alteradas - pkb_integr_ctimpretefd
-- Patch_2.9.5.4 / Patch_2.9.6.1 / Release_2.9.7
--
-- Em 11/01/2021 - Eduardo Linden
-- Redmine #74968 - Inclus�o de parametriza��o para preenchimento do Codigo do Tipo Servi�o Reinf para CTE modelo 67
-- Rotina alterada - pkb_integr_ctimpretefd => Inclus�o de preenchimento do C�digo do Tipo Servi�o Reinf a partir da parametriza��o da tabela aliq_tipoimp_ncm_empresa]
-- Patch_2.9.5.4 / Patch_2.9.6.1 / Release_2.9.7
--
-- Em 28/12/2020 - Eduardo Linden
-- Redmine #74671 - Inclus�o do Flexfield UNID_ORG - VW_CSF_CONHEC_TRANSP_EFD_FF
-- Rotina alterada - pkb_integr_conhec_transp_ff => Inclusao do Flex Field UNID_ORG de Conhecimento de transporte 
--                 - pkb_integr_ct_d100 => Inclusao do parametro de entrada ev_cd_unid_org e a consistencia para o campo unidorg_id
--
-- Em 27/10/2020 - Renan Alves
-- Redmine #72827 - Valida��o para ct-e de complemento de valores
-- Foi incluido uma verifica��o no DM_IND_EMIT e realizado uma tratativa para cada DM_IND_EMIT
-- Rotina: pkb_integr_ct_d100
-- Patch_2.9.5.2 / Patch_2.9.4.5 / Release_2.9.6 
--
-- Em 15/10/2020 - Renan Alves
-- Redmine #72265 - CTe Integrado n�o valida
-- Foi incluido uma verifica��o no DM_IND_EMIT e realizado uma tratativa para cada DM_IND_EMIT
-- Rotina: pkb_integr_ctcompdoc_pisefd,
--         pkb_integr_ctcompdoc_cofinsefd 
--
-- Em 18/09/2020   - Luis Marques - 2.9.5
-- Redmine #70848  - Implementar Diferencial de Al�quota para CTE - Aviva
-- Nova Rotina     - pkb_integr_ct_dif_aliq - Procedimento para integra��o dos valores referente ao diferencial de
--                   aliquota.
-- Rotina Alterada - pkb_excluir_dados_ct - Incluido tabela "ct_dif_aliq".  
--
-- Em 19/08/2020   - Luis Marques - 2.9.3-5 / 2.9.4-2 / 2.9.5
-- Redmine #70694  - colocar a tabela CONHEC_TRANSP_IMP_RET na rotina de exclus�o
-- Rotina Alterada - pkb_excluir_dados_ct - Incluir tabela "CONHEC_TRANSP_IMP_RET" na rotina de exclus�o dos CTE(s).
--
-- Em 12/03/2020 - Luis Marques - 2.9.2-3 / 2.9.3
-- Redmine #65945 - Erro persiste
-- Rotina Alterada: pkb_valida_ct_d100 - alterado valida��o para tratar data como caracter para n�o impactar nao
--                  formata��o do blanco do cliente.
--
-- Em 10/03/2020 - Luis Marques - 2.9.2-3 / 2.9.3
-- Redmine #65667 - Erro na pkb_valida_ct_d100.pkb_valida_ct_d100 fase(2): ORA-01843: not a valid month (ALTA)
-- Rotina Alterada: pkb_valida_ct_d100 - Tirado format no cursor da data e colocado format na vari�vel destino.
-- 
-- Em 06/03/2020 - Allan Magrini
-- Redmine #65647 - CTe validando opera��o com base no participante novamente.. 
-- Colocada regra de valida��o na fase 1 se os campos vv_uf_emit = 'XX' or vv_uf_dest = 'XX' pega os valores de sigla da forma antiga e se
-- este campos vieram com siglas de estado diferente de XX mantem as mesmas e valida.        
-- Novas Rotinas: PKB_VALIDA_CFOP_POR_PART
-- Liberado na vers�o - Release_2.9.3, Patch_2.9.2.3 e Patch_2.9.1.6  
--
-- Em 05/12/2019 - Allan Magrini
-- Redmine #61656 - Regra de valida��o D100 campo 11
-- Criada regra de valida��o onde o campo CONHEC_TRANSP.DT_HR_EMISSAO>= 01/01/2019 e CONHEC_TRANSP.MODFISCAL_ID seja igual a 07, 09, 10, 11, 26 ou 27 
-- sera gerado erro de valida��o informando que o modelo selecionado n�o est� mais vigente na data de emiss�o informada.        
-- RotinaS Criada: pkb_valida_ct_d100
--
-- Em 18/11/2019 - Allan Magrini
-- Redmine #60889 - CTe validando opera��o com base no participante. 
-- Alterado a origem do campo vv_uf_dest para o campo sigla_uf_fim da tabela conhec_transp       
-- Novas Rotinas: PKB_VALIDA_CFOP_POR_PART
--
-- Em 26/09/2019 - Luis Marques
-- Redmine #59148 - Constru��o de inclus�o dos dados do emitente para Open Interface
-- Rotina Alterada: pkb_reg_pessoa_emit_ct - Ajuste para n�o jogar nulo no cnpj caso n�o encontre para
--                  ser posteriormente cadastrado.
--
-- Em 23/09/2019 - Luis Marques
-- Redmine #48353 - Ao fazer upload do CTe pelo compliance, o participante n�o � Cadastrado/Atulizado.
-- Novas Rotinas: pkb_integr_conhec_transp_emit e pkb_reg_pessoa_emit_ct para integra��o de dados do emitente.
--
-- Em 21/08/2019 - Luis Marques
-- Redmine #57141 - Valida��o nota fiscal servi�os
-- RotinaS Alteradas: pkb_integr_ctcompdoc_pisefd E pkb_integr_ctcompdoc_cofinsefd - ajustado para mostrar Informa��o Geral ao inves de
--                    Avisos Gen�ricos
--
-- Em 08/08/2019 - Luis Marques
-- Redmine #57310 - CTE terceiros com erro ao informar cidade origem
-- Rotina Alterada: pkb_integr_conhec_transp_ff
--                  Retirada valida��o final colocada que verificava conteudo dos campos no final pois o conhecimento
--                  entra com valores default e a verifica��o na integra��o j� est� verificando a existencia dos campos.
--
-- Em 06/08/2019 - Luis Marques
-- Redmine #56568 - Mensagem de erro de valida��o para CT-e sem origem e destino
-- Rotina Alterada: pkb_integr_conhec_transp_ff
--                  Valida��o dos campos IBGE_CIDADE_INI, DESCR_CIDADE_INI, SIGLA_UF_INI, IBGE_CIDADE_FIM, DESCR_CIDADE_FIM
--                  SIGLA_UF_FIM est�o sendo informados.
--
-- Em 29/07/2019 - Luis Marques
-- Redmine #56849 - feed - CT-e continua com erro de valida��o
-- Rotina Alterada: PKB_VALIDA_CFOP_POR_PART
--                  Na valida��o de CFOP estava passando informacao e esse tipo de log est� como erro e ser� ajustadado
--                  para informa��o e nesta valida��o foi passado ERRO_DE_VALIDACAO.
--
-- Em 26/07/2019 - Luis Marques
-- Redmine #56729 - feed - CT-e e NFS-e ainda ficam com erro de valida��o
-- Rotina Alterada: pkb_validar
--                  Ajuistado para se contiver s� aviso er informa��o na deixa o conhecimento como n�o validado
--   
-- Em 21/07/2019 - Luis Marques
-- Redmine #56565 - feed - Mensagem de ADVERTENCIA est� deixando documento com ERRO DE VALIDA��O
-- Rotinas alteradas: pkb_integr_ctcompdoc_pisefd, pkb_integr_ctcompdoc_pisefd e pkb_validar
--                    Alterado para colocar verifica��o de falta de Codigo de base de calculo de PIS/COFINS
--                    como advertencia.
--
-- Em 15/07/2019 - Luis Marques
-- Redmine #27836 Valida��o PIS e COFINS - Gerar log de advert�ncia durante integra��o dos documentos
-- Rotinas alteradas: Incluido verifica��o de advertencia da falta de Codigo da base de calculo do credito
--                    se existir base e aliquota de imposto for do tipo imposto (0) e cliente juridico
--                    pkb_integr_ctcompdoc_pisefd e pkb_integr_ctcompdoc_pisefd
-- Function nova: fkg_dmindemit_conhectransp
--
-- Em 11/07/2019 - Luis MArques
-- Redmine #56155 - feed - Valida��o de chave de CT-e
-- RotinaS Alteradas: pkb_integr_ct_d100 e pkb_validar, recuperando forma de emissao da chave do conhecimento
--                    para ver se valida ou n�o a chave
--
-- Em 05/07/2019 - Luis Marques
-- Redmine #56042 - Parou de validar a chave de cte de terceiro
-- Rotinas Alteradas: pkb_integr_ct_d100 e pkb_validar na chamada da fkg_ret_valid_integr incluido campos
--                    dm_forma_emiss para valida��o de forma de emiss�o <> 8 8 e conhecimento 
--                    n�o de terceiros, DM_IND_EMIT = 0 e legado (1,2,3,4), DM_LEGADO in (1,2,3,4)
--
-- Em 05/06/2019 - Karina de Paula
-- Redmine #55008 - feed - est� validando a forma de emiss�o 8
-- Rotina Alterada: pkb_integr_ct_d100 e pkb_validar => Inclu�da a chamada da pk_csf_ct.fkg_ret_valid_integr =. Function retorna se o dado de integra��o deve ser validado ou n�o
--
--
-- === AS ALTERA��ES ABAIXO EST�O NA ORDEM CRESCENTE USADA ANTERIORMENTE ================================================================================= --
--
--| Em 06/03/2012 - Angela In�s.
--| Inclu�do processo de valida��o (pkb_consiste_cte) para os complementos das opera��es de PIS e COFINS.
--
--| Em 18/05/2012 - Angela In�s.
--| Corre��o em mensagens e coment�rios de dados nas rotinas: pkb_integr_ctcompdoc_pisefd e pkb_integr_ctcompdoc_cofinsefd.
--| Verificar se o processo est� considerando as CST corretas para os impostos PIS e COFINS.
--
--| Em 05/07/2012 - Angela In�s.
--| 1) Inclus�o da rotina de gera��o de log/altera��es nos processos de Conhecimento de Transporte (tabela: conhec_transp) - pkb_inclui_log_conhec_transp.
--| 2) Inclus�o da exclus�o dos dados de log/altera��o dos processos de Conhecimento de Transporte (tabela: log_conhec_transp) - pkb_excluir_dados_ct.
--
--| Em 31/08/2012 - Angela In�s.
--| 1) Ficha HD: 62741 - Corre��o na valida��o de Natureza de Opera��o.
--|    Consistir se o identificador foi encontrado de acordo com o c�digo informado no layout.
--
-- Em 28/11/2012 - Angela In�s.
-- Ficha HD 64674 - Melhoria em valida��es, n�o permitir valores zerados para os campos:
-- Rotina: pkb_integr_ct_d100 -> conhec_transp_vlprest.vl_prest_serv.
-- Rotina: pkb_integr_ct_d190 -> ct_reg_anal.vl_opr.
--
-- Em 19/12/2012 - Angela In�s.
-- Ficha HD 64591 - Implementar os campos flex field para a integra��o de Conhecimento de Transporte: ct_reg_anal.
--
-- Em 22/03/2013 - Angela In�s.
-- Ficha HD 64674 - Alterar a mensagem de valida��o do valor da opera��o retirando a palavra ICMS.
-- Rotina: pkb_integr_ct_d190.
--
-- Em 14/05/2013 - Angela In�s.
-- Incluir as tabelas faltantes para desprocessamento de conhecimento de transporte.
-- Rotina: pkb_excluir_dados_ct.
--
-- Em 26/07/2013 - Angela In�s.
-- Redmine #405 - Leiaute: Conhec. Transporte: Implementar no complemento de Pis/Cofins o c�digo da natureza de receita isenta - Campos Flex Field.
-- Rotinas: pkb_integr_ctcompdocpisefd_ff e pkb_integr_ctcompdoccofefd_ff.
--
-- Em 06/08/2013 - Angela In�s.
-- Redmine #451 - Valida��o de informa��es Fiscais - Ficha HD 66733.
-- Corre��o nas rotinas chamadas pela pkb_consiste_cte, eliminando as refer�ncias das vari�veis globais, pois essa rotina ser� chamada de outros processos.
-- Rotina: pkb_consiste_cte e todas as chamadas dentro dessa rotina.
-- Inclus�o da fun��o de valida��o dos conhecimentos de transporte, atrav�s dos processos de sped fiscal, contribui��es e gias.
-- Rotina: fkg_valida_cte.
--
-- Em 05/09/2013 - Angela In�s.
-- Alterar a rotina que valida os processos considerando somente conhecimentos de transporte que sejam de terceiros (conhec_transp;dm_ind_emit = 1).
-- Rotina: fkg_valida_cte.
--
-- Em 13/09/2013 - Angela In�s.
-- Comentar a chamada da rotina de valida��o de documentos fiscais.
--
-- Em 19/09/2013 - Angela In�s.
-- Redmine #680 - Fun��o de valida��o dos documentos fiscais.
-- Invalidar o conhecimento de transporte no processo de consist�ncia dos dados, se o objeto de refer�ncia for CONHEC_TRANSP.
-- Rotina: pkb_consiste_cte.
--
-- Em 03/07/2014 - Angela In�s.
-- Redmine #3255 - N�o est� desprocessando a integra��o com a op��o Conhecimento de Transporte.
-- As tabelas que faltavam no processo foram inclu�das.
-- Rotina: pkb_excluir_dados_ct.
--
-- Em 19/02/2015 - Rog�rio Silva
-- Redmine #6398 - Validar CFOP x UF do Participante para Conhecimento de Transporte D100
-- Rotina: pkb_valida_cfop_por_part
--
-- Em 30/03/2015 - Angela In�s.
-- Redmine #6685 - Valida��o de Importa��o de Conhecimento de Transporte.
-- Implementar uma nova regra de valida��o de Conhecimento de Transporte, onde ao importar um Conhecimento de Transporte de Terceiro (D100) e o modelo for
-- "57-CTe", verificar se existe XML armazenado (DM_ARM_CTE_TERC=1) pela chave de acesso, caso a situa��o for "cancelada", gerar erro de valida��o para o
-- CTe de Terceiro.
-- Rotina: pkb_integr_ct_d100.
--
-- Em 09/04/2015 - Angela In�s.
-- Redmine #7489 - Erro de valida��o CT-e terceiro (TENDENCIA).
-- Considerar um registro para cada conhecimento de transporte e indicador de natureza do frete, ou seja, n�o poder� ter mais que um registro nas tabelas
-- ct_comp_doc_pis e ct_comp_doc_cofins com o mesmo conhecimento de transporte e indicador de natureza de frete.
-- Rotinas: pkb_valida_ct_d101 e pkb_valida_ct_d105.
--
-- Em 24/04/2015 - Angela In�s.
-- Redmine #7059 - Crit�rio de escritura��o base isenta e base outras (MANIKRAFT).
-- Ajustar o processo que determina a escritura��o em base Isenta e Outras, da seguinte forma:
-- 1) CST ICMS = 50 ==>> Base Outras
-- 2) Para os itens que possuam CST de ICMS como 90, por�m possuam o % de redu��o da base de c�lculo, fazer o c�lculo da redu��o, e lan�ar o valor como Isentas,
--    o restante do valor dever� ser escriturado como Outras.
-- Rotina: pkb_vlr_fiscal_ct_d100.
--
-- Em 04/05/2015 - Angela In�s.
-- Redmine #8004 - Erro de valida��o CT-e terceiro (TENDENCIA).
-- Corre��o: Ao verificar se existe imposto PIS com o mesmo CST e mesmo valor de base para COFINS, e de COFINS para PIS, considerar a CST, pois poder� existir mais de um registro com CSTs diferentes devido ao indicador da natureza de frete.
-- Rotinas: pkb_valida_ct_d101 e pkb_valida_ct_d105.
--
-- Em 01/06/2015 - Rog�rio Silva
-- Redmine #8230 - Processo de Registro de Log em Packages - Conhecimento de Transporte
--
-- Em 05/06/2015 - Angela In�s.
-- Redmine #8543 - Processos que utilizam as tabelas de c�digos de ajustes para Apura��o do ICMS.
-- Incluir como par�metros de entrada as datas inicial e final para recuperar o ID do c�digo de ocorr�ncia de ajuste de apura��o de icms.
-- Rotina: pkb_integr_ct_inf_prov.
--
-- Em 28/07/2015 - Angela In�s.
-- Redmine #9513 - Trocar a tabela de nota fiscal para conhecimento de transporte como refer�ncia ao campo dm_ind_emit.
--
-- Em 10/09/2015 - Angela In�s.
-- Redmine #11518 - Melhorar mensagem de CFOP no Registro Anal�tico - Conhecimento de Transporte.
-- A mensagem que indica: "CFOP informado no registro anal�tico est� divergente para o participante do Conhecimento de Transporte", dever� ser melhorada
-- informando quais s�o os estados/uf do participante e do emitente do conhecimento, e o pr�pria c�digo da CFOP informado no registro anal�tico para valida��o.
-- Rotina: pkb_valida_cfop_por_part.
--
-- Em 11/12/2015 - Angela In�s.
-- Redmine #13461 - Acertar a recupera��o dos valores de base de ICMS para Cupons Fiscais.
-- Para CST de ICMS 90-Outros, considerar base Outras por n�o houver redu��o de base de c�lculo.
-- Rotina: pkb_vlr_fiscal_ct_d100.
--
-- Em 14/12/2015 - Rog�rio Silva
-- Redmine #13602 - Verifica��o ActionSys SBB - Conhec. Transp.
--
-- Em 17/12/2015 - Angela In�s.
-- Redmine #13793 - Corre��o na fun��o que recupera valores cont�beis para os Conhecimentos de Transporte.
-- Rotina: pkb_vlr_fiscal_ct_d100.
--
-- Em 05/02/2016 - Rog�rio Silva
-- Redmine #13079 - Registro do N�mero do Lote de Integra��o Web-Service nos logs de valida��o
--
-- Em 14/04/2016 - F�bio Tavares
-- Redmine #16793 - Melhoria nas mensagens dos processos flex-field.
--
-- Em 08/06/2016 - Angela In�s.
-- Redmine #19918 - Valida��o do CFOP - Conhecimento de Transporte.
-- Trocar a situa��o da mensagem de "erro de valida��o" para "informa��o geral".
-- Rotina: pkb_valida_cfop_por_part.
--
-- Em 03/02/2016 - F�bio Tavares.
-- Redmine #27380 - Revis�o de processos de exclus�o - BD
-- Foi adicionado a exclus�o do registro da tabela de relacionamento R_CTRLINTEGRARQ_CT.
--
-- Em 20/11/2017 - Angela In�s.
-- Redmine #34618 - Utilizar o par�metro: "Valida Cfop por Destinat�rio" do cadastro para empresa para Validar NFSe.
-- Melhoria na descri��o da rotina que valida CFOP por Participante, no processo de valida��o de CTE/D100. O coment�rio da rotina PKB_VALIDA_CFOP_POR_PART, na
-- package PK_CSF_API_D100, est� indicando que utiliza o par�metro "Cfop por Destinat�rio" da empresa (Tabela empresa.dm_valida_cfop_por_dest), por�m o processo
-- n�o utiliza esse par�metro. Eliminamos do coment�rio da rotina essa informa��o. Melhoria t�cnica que n�o influencia nos processos.
--
-- Em 27/12/2017 - Angela In�s.
-- Redmine #37932 - Corre��o na valida��o dos dados do Conhecimento de Transporte - Inclus�o.
-- Verificar nas rotinas que enviam dados para inclus�o ou altera��o do Conhecimento de Transporte (pk_csf_api_d100.pkb_integr_ct_d100), e acertar os valores que
-- possuem valores fixos considerando os valores enviados como par�metros de entrada.
-- Rotinas: Convers�o de CTE de Terceiros (PK_ENTR_CTE_TERCEIRO), Integra��o Open Interface (PK_INT_VIEW_D100), e Valida��o de Ambiente (PK_VLD_AMB_D100).
-- Rotina:pkb_integr_ct_d100.
--
-- Em 23/01/2018 - Karina de Paula
-- Redmine #38656 - Processos de integra��o de Conhecimento de Transporte - Modelo D100.
-- Incluido o modelo fiscal 67 nas rotinas que tratam o modelo 57
--
-- Em 25/04/2018 - Angela In�s.
-- Redmine #42169 - Corre��es: Registro C100 - Atualiza��o do Plano de Contas; Convers�o de CTE - CFOP.
-- O CFOP recuperado para atualizar o C�digo da Conta Cont�bil, � do Conhecimento de Transporte (conhec_transp.cfop_id).
-- Por�m o processo de convers�o de CTE considera o CFOP 1000, como valor inicial, e a rotina que gera os registros anal�ticos desse conhecimento (ct_reg_anal),
-- est� utilizando o CFOP dos par�metros de c�lculo de ICMS da empresa (param_calc_icms_empr).
-- Rotina: pkb_integr_ct_d100.
--
-- Em 18/06/2018 - Karina de Paula
-- Redmine #40168 - Convers�o de CTE e Gera��o dos campo COD_MUN_ORIG e COD_MUN_DEST no registro D100 do Sped de ICMS e IPI
-- Rotina Alterada: pkb_integr_conhec_transp_ff => Inclu�do novos atributos e valida��o: (IBGE_CIDADE_INI, DESCR_CIDADE_INI, SIGLA_UF_INI, IBGE_CIDADE_FIM, DESCR_CIDADE_FIM e SIGLA_UF_FIM)
-- Rotina Alterada: pkb_integr_ct_d100 => Inclu�do novos par�metros de entrada na chamada da procedure, no update e no insert
--
-- Em 17/10/2018 - Karina de Paula
-- Redmine #47311 - Convers�o de CT-e modelo 67
-- Rotina Criada: pkb_integr_ctimpret_inssefd => Procedimento integra os impostos retidos de INSS
--
-- Em 30/10/2018 - Karina de Paula
-- Redmine #47549 - Adaptar packages de integra��o
-- Rotina Criada: pkb_integr_ctimpretefd e pkb_integr_ctimpretefd_ff
--
-- Em 31/10/2018 - Karina de Paula
-- Redmine #47558 - Altera��es na package pk_entr_cte_terceiro para atender INSS
-- Rotina Exclu�da: pkb_integr_ctimpret_inssefd (foi substitu�da pelas pkb_integr_ctimpretefd e pkb_integr_ctimpretefd_ff)
-- Rotina Alterada: pkb_integr_ct_d100 => Inclu�dos novos par�metros de entrada dm_modal e dm_tp_serv
--
-- Em 05/11/2018 - Karina de Paula
-- Redmine #48410 - feed - nao est� indo pra definitiva o CD_TP_SERV_REINF
-- Rotina Alterada: pkb_integr_ctimpretefd_ff => Alterada a verifica��o da vari�vel vn_tiposervreinf_id (se "IS NULL" dar erro)
--
-- Em 06/11/2018 - Karina de Paula
-- Redmine #47561 - pk_csf_api_d100.pkb_integr_ct_imp_ret criar uma adivert�ncia
-- Rotina Alterada: pkb_integr_ctimpretefd => Inclu�do msg de divergencia de valores de imposto para CTE de convers�o
--
-- Em 13/11/2018 - Eduardo Linden
-- Redmine #49688 - Adequa��o do processo CTe de emiss�o pr�pria para base isenta
-- O CTe receber� as tratativas de DE-PARA da base isenta (tabela param_calc_base_icms).
-- Rotina Alterada:pkb_vlr_fiscal_ct_d100
--
-- Em 29/01/2019 - Marcos Ferreira
-- Redmine #49524 - Funcionalidade - Base Isenta e Outros de Conhecimento de Transporte cuja emiss�o � pr�pria
-- Solicita��o: Unificar a procedure que retorna os valores fiscais (ICMS/ICMS-ST/IPI) de um conhecimento de transporte na api principal do Conhecimento de Transporte
-- Altera��es: Transporte da procedure pk_csf_api_d100.pkb_vlr_fiscal_ct_d100 para pk_csf_ct.pkb_vlr_fiscal_ct
-- Procedures Alteradas: pkb_vlr_fiscal_ct
--
-- Em 29/01/2019 - Renan Alves
-- Redmine #49303 - Tela de Conhecimento de Transporte - Bot�o validar
-- Altera��o: Foi acrescentado uma verifica��o para os tipos de emiss�es (0 - Emiss�o pr�pria / 1 - Terceiros)
-- na pkb_consiste_cte, retornando uma mensagem de log espec�fica, para cada emiss�o.
--
-- Em 26/02/2019 - Marcos Ferreira
-- Redmine #39016 - Integra��o e Valida��o do Campo conhec_transp.nro_chave_cte nas notas fiscais cuja emiss�o � por terceiro.
-- Solicita��o: Corrir problema de valida��o de chave do CTe
-- Altera��es: Inclu�do Valida��o e Gera��o da Chave CT-e
-- Procedures Alteradas: pkb_validar, pkb_integr_ct_d100
--
-- Redmine Redmine #53636 - Corre��o na valida��o da Chave de Acesso do CTe.
-- Ao validar a chave de acesso do CTe consistimos o CNPJ da chave de acesso com o CNPJ da Empresa emitente do Conhecimento de Transporte.
-- Passar a considerar o CNPJ da chave de acesso com o CNPJ da Empresa emitente do Conhecimento de Transporte desde que o Indicador do Emitente seja Emiss�o Pr�pria.
-- Passar a considerar o CNPJ da chave de acesso com o CNPJ do Participante do Conhecimento de Transporte desde que o Indicador do Emitente seja Terceiro.
-- Rotinas: pkb_integr_ct_d100 e pkb_validar.
--
-- === AS ALTERA��ES PASSARAM A SER INCLU�DAS NO IN�CIO DA PACKAGE ================================================================================= --
--
--------------------------------------------------------------------------------------------------------------------------------------------------
--
   gt_row_conhec_transp        conhec_transp%rowtype;
   gt_row_conhec_transp_emit   conhec_transp_emit%rowtype;
   gt_row_ct_reg_anal          ct_reg_anal%rowtype;
   gt_row_ct_compdoc_pisefd    ct_comp_doc_pis%rowtype;
   gt_row_ct_compdoc_cofinsefd ct_comp_doc_cofins%rowtype;
   gt_row_ct_procrefefd        ct_proc_ref%rowtype;
   gt_row_ctinfor_fiscal       ctinfor_fiscal%rowtype;
   gt_row_ct_inf_prov          ct_inf_prov%rowtype;
   gt_row_ct_impretefd         conhec_transp_imp_ret%rowtype;
   gt_row_ct_dif_aliq          ct_dif_aliq%rowtype;
--
-------------------------------------------------------------------------------------------------------

-- Declara��o de constantes

   ERRO_DE_VALIDACAO       CONSTANT NUMBER := 1;
   ERRO_DE_SISTEMA         CONSTANT NUMBER := 2;
   CONHEC_TRANSP_INTEGRADO CONSTANT NUMBER := 34;
   INFORMACAO              CONSTANT NUMBER := 35;

-------------------------------------------------------------------------------------------------------

   gv_cabec_log          Log_Generico_ct.mensagem%TYPE;
   gv_cabec_log_item     Log_Generico_ct.mensagem%TYPE;
   gv_mensagem_log       Log_Generico_ct.mensagem%TYPE;
   gv_obj_referencia     Log_Generico_ct.obj_referencia%type default 'CONHEC_TRANSP';
   gn_referencia_id      Log_Generico_ct.referencia_id%type := null;
   gn_tipo_integr        number := null;
   gv_cd_obj             obj_integr.cd%type := '4';

-------------------------------------------------------------------------------------------------------

-- Retorna dm_st_proc atrav�s do id do conhecimento de transporte
function fkg_ct_dm_st_proc ( en_conhectransp_id in conhec_transp.id%type )
         return conhec_transp.dm_st_proc%type;
-------------------------------------------------------------------------------------------------------

--| Procedimento para excluir registros de conhecimento de transporte

procedure pkb_excluir_dados_ct ( en_conhectransp_id in conhec_transp.id%type );

-------------------------------------------------------------------------------------------------------

--| Fun��o retorna o ID do conhecimento de transporte se existir
function fkg_conhec_transp_id ( en_empresa_id    in empresa.id%type
                              , en_dm_ind_emit   in conhec_transp.dm_ind_emit%type
                              , en_dm_ind_oper   in conhec_transp.dm_ind_oper%type
                              , en_pessoa_id     in pessoa.id%type
                              , en_modfiscal_id  in mod_fiscal.id%type
                              , ev_serie         in conhec_transp.serie%type
                              , ev_subserie      in conhec_transp.subserie%type
                              , en_nro_ct        in conhec_transp.nro_ct%type )
         return conhec_transp.id%type;
-------------------------------------------------------------------------------------------------------

--| Procedimento seta o tipo de integra��o que ser� feito
-- 0 - Somente v�lida os dados e registra o Log de ocorr�ncia
-- 1 - V�lida os dados e registra o Log de ocorr�ncia e insere a informa��o
-- Todos os procedimentos de integra��o fazem refer�ncia a ele
procedure pkb_seta_tipo_integr ( en_tipo_integr in number );

-------------------------------------------------------------------------------------------------------

--| Procedimento seta o objeto de referencia utilizado na Valida��o da Informa��o
procedure pkb_seta_obj_ref ( ev_objeto in varchar2 );

-------------------------------------------------------------------------------------------------------

procedure pkb_integr_ct_d100 ( est_log_generico            in out nocopy  dbms_sql.number_table
                             , ev_cpf_cnpj_emit            in             varchar2
                             , en_dm_ind_emit              in             conhec_transp.dm_ind_emit%type
                             , en_dm_ind_oper              in             conhec_transp.dm_ind_oper%type
                             , ev_cod_part                 in             pessoa.cod_part%type
                             , ev_cod_mod                  in             mod_fiscal.cod_mod%type
                             , ev_serie                    in             conhec_transp.serie%type
                             , ev_subserie                 in             conhec_transp.subserie%type
                             , en_nro_nf                   in             conhec_transp.nro_ct%type
                             , ev_sit_docto                in             sit_docto.cd%type
                             , ev_nro_chave_cte            in             conhec_transp.nro_chave_cte%type
                             , en_dm_tp_cte                in             conhec_transp.dm_tp_cte%type
                             , ev_chave_cte_ref            in             conhec_transp.chave_cte_ref%type
                             , ed_dt_emiss                 in             conhec_transp.dt_hr_emissao%type
                             , ed_dt_sai_ent               in             conhec_transp.dt_hr_emissao%type
                             , en_vl_doc                   in             conhec_transp_vlprest.vl_docto_fiscal%type
                             , en_vl_desc                  in             conhec_transp_vlprest.vl_desc%type
                             , en_dm_ind_frt               in             conhec_transp.dm_ind_frt%type
                             , en_vl_serv                  in             conhec_transp_vlprest.vl_prest_serv%type
                             , en_vl_bc_icms               in             conhec_transp_imp.vl_base_calc%type
                             , en_vl_icms                  in             conhec_transp_imp.vl_imp_trib%type
                             , en_vl_nt                    in             conhec_transp_imp.vl_imp_trib%type
                             , ev_cod_inf                  in             infor_comp_dcto_fiscal.cod_infor%type
                             , ev_cod_cta                  in             conhec_transp.cod_cta%type
                             , ev_cod_nat_oper             in             nat_oper.cod_nat%type
                             , en_multorg_id               in             mult_org.id%type
                             , sn_conhectransp_id          out            conhec_transp.id%type
                             , en_loteintws_id             in             lote_int_ws.id%type default 0
                             , en_cfop_id                  in             cfop.id%type default 1
                             , en_ibge_cidade_ini          in             conhec_transp.ibge_cidade_ini%type default 0
                             , ev_descr_cidade_ini         in             conhec_transp.descr_cidade_ini%type default 'XX'
                             , ev_sigla_uf_ini             in             conhec_transp.sigla_uf_ini%type default 'XX'
                             , en_ibge_cidade_fim          in             conhec_transp.ibge_cidade_fim%type default 0
                             , ev_descr_cidade_fim         in             conhec_transp.descr_cidade_fim%type default 'XX'
                             , ev_sigla_uf_fim             in             conhec_transp.sigla_uf_fim%type default 'XX'
                             , ev_dm_modal                 in             conhec_transp.dm_modal%type default '01'
                             , en_dm_tp_serv               in             conhec_transp.dm_tp_serv%type default 0
                             , ev_cd_unid_org              in             unid_org.cd%type default null
                             );

-------------------------------------------------------------------------------------------------------

-- Procedimento Integra as Informa��es relativas do Emitente do CT.
procedure pkb_integr_conhec_transp_emit ( est_log_generico           in out nocopy dbms_sql.number_table
                                        , est_row_conhec_transp_emit in out nocopy Conhec_Transp_Emit%rowtype
                                        , en_conhectransp_id         in            Conhec_Transp.id%TYPE 
                                        , ev_cod_part                in  pessoa.cod_part%TYPE );                    

------------------------------------------------------------------------------------------

-- Procedimento de Integra��o de Flex-Field de Conhecimento de Transporte
procedure pkb_integr_conhec_transp_ff ( est_log_generico    in out nocopy  dbms_sql.number_table
                                      , en_conhectransp_id  in             conhec_transp.id%type
                                      , ev_atributo         in             varchar2
                                      , ev_valor            in             varchar2 ); 
-------------------------------------------------------------------------------------------------------

--| Procedimento integra o resumo de impostos do Conhecimento de Transporte

procedure pkb_integr_ct_d190 ( est_log_generico            in out nocopy  dbms_sql.number_table
                             , est_ct_reg_anal             in out nocopy  ct_reg_anal%rowtype
                             , ev_cod_st                   in             cod_st.cod_st%type
                             , en_cfop                     in             cfop.cd%type
                             , ev_cod_obs                  in             obs_lancto_fiscal.cod_obs%type
                             , en_multorg_id               in             mult_org.id%type );

-------------------------------------------------------------------------------------------------------

--| Procedimento integra o resumo de impostos do Conhecimento de Transporte - Campos Flex Field

procedure pkb_integr_ct_d190_ff ( est_log_generico in out nocopy  dbms_sql.number_table
                                , en_ctreganal_id  in             ct_reg_anal.id%type
                                , ev_atributo      in             varchar2
                                , ev_valor         in             varchar2 );

-------------------------------------------------------------------------------------------------------

--| Procedimento integra o complemento da opera��o de PIS/PASEP - Campos Flex Field

procedure pkb_integr_ctcompdocpisefd_ff ( est_log_generico   in out nocopy  dbms_sql.number_table
                                        , en_ctcompdocpis_id in             ct_comp_doc_pis.id%type
                                        , ev_atributo        in             varchar2
                                        , ev_valor           in             varchar2
                                        , en_multorg_id      in             mult_org.id%type );

-------------------------------------------------------------------------------------------------------

--| Procedimento integra o complemento da opera��o de PIS/PASEP

procedure pkb_integr_ctcompdoc_pisefd ( est_log_generico      in out nocopy  dbms_sql.number_table
                                      , est_ctcompdoc_pisefd  in out nocopy  ct_comp_doc_pis%rowtype
                                      , ev_cpf_cnpj_emit      in             varchar2
                                      , ev_cod_st             in             cod_st.cod_st%type
                                      , ev_cod_bc_cred_pc     in             base_calc_cred_pc.cd%type
                                      , ev_cod_cta            in             plano_conta.cod_cta%type
                                      , en_multorg_id         in             mult_org.id%type );

-------------------------------------------------------------------------------------------------------

--| Procedimento integra o complemento da opera��o de COFINS - Campos Flex Field

procedure pkb_integr_ctcompdoccofefd_ff ( est_log_generico      in out nocopy  dbms_sql.number_table
                                        , en_ctcompdoccofins_id in             ct_comp_doc_cofins.id%type
                                        , ev_atributo           in             varchar2
                                        , ev_valor              in             varchar2
                                        , en_multorg_id         in             mult_org.id%type );

-------------------------------------------------------------------------------------------------------

--| Procedimento integra o complemento da opera��o de COFINS

procedure pkb_integr_ctcompdoc_cofinsefd ( est_log_generico        in out nocopy  dbms_sql.number_table
                                         , est_ctcompdoc_cofinsefd in out nocopy  ct_comp_doc_cofins%rowtype
                                         , ev_cpf_cnpj_emit        in             varchar2
                                         , ev_cod_st               in             cod_st.cod_st%type
                                         , ev_cod_bc_cred_pc       in             base_calc_cred_pc.cd%type
                                         , ev_cod_cta              in             plano_conta.cod_cta%type
                                         , en_multorg_id           in             mult_org.id%type );

-------------------------------------------------------------------------------------------------------

--| Procedimento integra o processo referenciado

procedure pkb_integr_ctprocrefefd ( est_log_generico in out nocopy dbms_sql.number_table
                                  , est_ctprocrefefd in out nocopy ct_proc_ref%rowtype
                                  , en_cd_orig_proc  in            orig_proc.cd%type );

-------------------------------------------------------------------------------------------------------

--| Procedimento integra a informa��o fiscal do CT

procedure pkb_integr_ctinfor_fiscal ( est_log_generico      in out nocopy  dbms_sql.number_table
                                    , est_ctinfor_fiscal    in out nocopy  ctinfor_fiscal%rowtype
                                    , ev_cod_obs            in             varchar2
                                    , en_multorg_id         in             mult_org.id%type
                                    );
                                    
-------------------------------------------------------------------------------------------------------

--| Procedimento integra os ajustes e informac�es de valores provenientes de documento fiscal

procedure pkb_integr_ct_inf_prov ( est_log_generico      in out nocopy  dbms_sql.number_table
                                 , est_ct_inf_prov       in out nocopy  ct_inf_prov%rowtype
                                 , ev_cod_aj             in             varchar2 
                                 );

-------------------------------------------------------------------------------------------------------

-- Procedure que consiste os dados do Conhecimento de Transporte

procedure pkb_consiste_cte ( est_log_generico     in out nocopy  dbms_sql.number_table
                           , en_conhectransp_id   in             Conhec_Transp.Id%TYPE );
                           
-------------------------------------------------------------------------------------------------------

-- Procedimento para gravar o log/altera��o dos conhecimentos de transporte

procedure pkb_inclui_log_conhec_transp( en_conhectransp_id in conhec_transp.id%type
                                      , ev_resumo          in log_conhec_transp.resumo%type
                                      , ev_mensagem        in log_conhec_transp.mensagem%type
                                      , en_usuario_id      in neo_usuario.id%type
                                      , ev_maquina         in varchar2 );

-------------------------------------------------------------------------------------------------------

--| Procedimento Valida o Conhecimento de Transporte conforme ID

procedure pkb_validar ( en_conhectransp_id in conhec_transp.id%type );

-------------------------------------------------------------------------------------------------------
-- Fun��o para validar os conhecimentos de transporte - utilizada nas rotinas de valida��es da GIA, Sped Fiscal e Contribui��es
function fkg_valida_cte ( en_empresa_id      in  empresa.id%type
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
                            , en_referencia_id       in             log_generico_ct.referencia_id%type);

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
--| Procedimento integra os impostos retidos
procedure pkb_integr_ctimpretefd ( est_log_generico        in out nocopy  dbms_sql.number_table
                                 , est_ctimpretefd         in out nocopy  conhec_transp_imp_ret%rowtype
                                 , ev_cpf_cnpj_emit        in             varchar2
                                 , ev_cod_imposto          in             tipo_imposto.cd%type
                                 , ev_cd_tipo_ret_imp      in             tipo_ret_imp.cd%type
                                 , ev_cod_receita          in             tipo_ret_imp_receita.cod_receita%type
                                 , en_multorg_id           in             mult_org.id%type );

-------------------------------------------------------------------------------------------------------
--| Procedimento integra os impostos retidos - Campos Flex Field
procedure pkb_integr_ctimpretefd_ff ( est_log_generico   in out nocopy dbms_sql.number_table
                                    , en_ctimpretefd_id  in            conhec_transp_imp_ret.id%type
                                    , ev_atributo        in            varchar2
                                    , ev_valor           in            varchar2
                                    , en_multorg_id      in            mult_org.id%type );

-------------------------------------------------------------------------------------------------------
-- Procedimento Integra as Informa��es relativas ao diferencial de aliquota
procedure pkb_integr_ct_dif_aliq ( est_log_generico           in out nocopy dbms_sql.number_table
                                 , est_row_ct_dif_aliq        in out nocopy ct_dif_aliq%rowtype
                                 , en_conhectransp_id         in            Conhec_Transp.id%TYPE );
--								 
end pk_csf_api_d100;
/
