create or replace package csf_own.pk_csf_efd_pc is

-------------------------------------------------------------------------------------------------------
-- Especifica��o do pacote geral de processos e fun��es da EFD PIS/COFINS
--
-- Em 05/01/2021   - Luis Marques - 2.9.5-4 / 2.9.6-1 / 2.9.7
-- Redmine #74674  - Gera��o do registro M100 - C�digo do Tipo de Cr�dito para servicos de transporte gerando como agroindustria
-- Rotina Alterada - fkg_relac_tipo_cred_pc_id - Incluido verifica��o de novo parametro "TIPO_CRED_GRUPO_CST_60" para o padr�o de
--                   CST de 60 a 66 (106,206 ou 306) ou (107,207 ou 307) com verifica��o se for produtor rural e o padr�o for
--                   (107,207 ou 307) considera o padr�o como (106,206 ou 306).
--                   "TIPO_CRED_GRUPO_CST_60" -> 0 - Padr�o (106,206 ou 306) / 1 - Padr�o (107,207 ou 307)
--
-- Em 05/11/2020 - Eduardo Linden
-- Redmine #72780 - N�o foi gerado o evento R2060 ao gerar os per�odos REINF (feed)
-- Ajuste no select para enquandramento da regra e recuperar o id da tabela empresa_ativcprb
-- Rotina alterada: fkg_codativcprb_id_empativcprb
-- Liberado para Release 2.9.6 e os patchs 2.9.5.2 e 2.9.4.5
--
-- Em 02/09/2020 - Eduardo Linden
-- Redmine #54371 - Inclus�o de Tipo de Servi�o no de X para - R2060
-- Inclus�o dos campos cnae_id e tpservico_id para recuperar o id da tabela empresa_ativcprb
-- Rotina alterada: fkg_codativcprb_id_empativcprb
-- Liberado para Release 2.9.5 e os patchs 2.9.4.3 e 2.9.3.6
--
-- Em 10/08/2020 - Allan Magrini
-- Redmine #68646 - Melhoria na Rotina de gera��o de contas EFD
-- Alterados os cursores incluindo o novo campo COD_ST_PISCOFINS da tabela PARAM_EFD_CONTR_GERAL 
-- Rotina: fkb_recup_pcta_ccto_pc.
--
--------------------------------------------------------------------------------------------------------
-- Em 29/04/2011 - Angela In�s.
-- Inclu�do processo para recuperar identificador da base de c�lculo de cr�dito.
--
-- Em 03/05/2011 - Angela In�s.
-- Inclu�do processo de item de marca comercial.
--
-- Em 19/05/2011 - Angela In�s.
-- Inclu�do processo para recuperar tipo de cr�dito atrav�s relacionamentos.
-- Inclu�do processo para recuperar identificador do tipo de cr�dito.
--
-- Em 08/06/2011 - Angela In�s.
-- Inclu�do processo para recuperar c�digo de contribui��o social
--
-- Em 17/01/2012 - Angela In�s.
-- Eliminada a fun��o para retornar a situa��o do per�odo de apura��o de cr�dito para o imposto PIS
-- Eliminada a fun��o para retornar a situa��o do per�odo de apura��o de cr�dito para o imposto COFINS
--
-- Em 18/01/2012 - Angela In�s.
-- Incluir fun��o para retornar quantidade de registros relacionados ao per�odo das receitas isentas - PIS
-- Incluir fun��o para retornar quantidade de registros relacionados ao per�odo das receitas isentas - COFINS
--
-- Em 23/01/2012 - Angela In�s.
-- Incluir fun��o para retornar quantidade de registros relacionados ao per�odo das consolida��es - PIS
-- Incluir fun��o para retornar quantidade de registros relacionados ao per�odo das consolida��es - COFINS
--
-- Em 23/02/2012 - Angela In�s.
-- Acertar a recupera��o do c�digo de CFOP pela primeira posi��o, na rotina de recupera��o de tipo de cr�dito.
--
-- Em 26/06/2012 - Leandro.
-- Inclu�da fun��o para verificar se o CFOP gera receita para a empresa
-- O sistema busca na empresa, seja filial, ou busca na matriz
--
-- Em 04/07/2012 - Angela In�s.
-- 1) Inclus�o da rotina de gera��o de log/altera��es nos processos de Notas fiscais de servi�os cont�nuos
--    (tabela: nota_fiscal) - pkb_inclui_log_nf_serv_cont.
--
-- Em 25/07/2012 - Angela In�s.
-- Alterar a fun��o que verifica cfop x empresa para receita de cr�dito (cfop_receita_empresa), considerando a coluna dm_gera_cred_pf_pc = 1 (0-n�o, 1-sim).
-- Rotina: fkg_existe_cfop_rec_empr.
--
-- Em 10/09/2012 - Angela In�s.
-- 1) Alterar a fun��o que recupera natureza de receita de pis/cofins. Inclus�o de novos par�metros de entrada - al�quotas.
--    Rotina: fkg_nat_rec_pc_id.
-- 2) Incluir nova fun��o para confirmar o identificador da natureza de receita de pis/cofins atrav�s do pr�prio identificador.
--    Rotina: fkg_conf_id_nat_rec_pc.
--
-- Em 13/09/2012 - Angela In�s.
-- 1) Considerar os c�digos de CFOP 1102-Compra para comercializa��o - dentro do estado, 2102-Compra para comercializa��o - fora do estado e
--    3102-Compra para comercializa��o - fora do pa�s, para considerar os tipos de cr�ditos 105, 205 e 305, al�m do c�digo ncm de cada produto.
--    Rotina: fkg_relac_tipo_cred_pc_id.
--
-- Em 24/09/2012 - Angela In�s.
-- 1) Inclus�o de novos par�metros para recuperar o c�digo da natureza de receita ( en_ncm_id e ev_cod_ncm ). Deve existir o c�digo de NCM.
--    Rotina: fkg_nat_rec_pc_id.
--
-- Em 11/10/2012 - Angela In�s.
-- Ficha HD 63865 - Considerar o primeiro registro encontrado na recupera��o da natureza de receita isenta, devido aos NCMs que aparecem em mais de uma natureza.
-- Rotina: fkg_nat_rec_pc_id.
--
-- Em 08/11/2012 - Angela In�s.
-- Ficha HD 64080 - Escritura��o Doctos Fiscais e Bloco M. Nova tabela para considera��es de CFOP - param_cfop_empresa.
-- Rotinas: fkg_gera_recisen_cfop_empr, fkg_gera_cred_nfpc_cfop_empr e fkg_gera_escr_efdpc_cfop_empr.
--
-- Em 23/11/2012 - Angela In�s.
-- Ficha HD 64743 - Alterar recupera��o dos par�metros de CFOP para os valores default.
-- Rotinas: fkg_gera_recisen_cfop_empr, fkg_gera_cred_nfpc_cfop_empr e fkg_gera_escr_efdpc_cfop_empr.
--
-- Em 31/01/2013 - Vanessa N. F. Ribeiro
-- Ficha HD65502 - Inclusao da fun��o fkg_codst_id_nat_rec_pc para uso da integra��o do complemnto do item
--
-- Em 02/05/2013 - Angela In�s.
-- Ficha HD 66673 - Considerar o c�digo 102-Cr�dito vinculado � receita tributada no mercado interno - Al�quotas Diferenciadas
-- para CST 50 quando a al�quota do imposto for 0 (zero) e a base de c�lculo for por unidade de produto (qtde).
-- Rotina: fkg_relac_tipo_cred_pc_id.
--
-- Em 07/05/2013 - Marcelo Ono.
-- Corrigido o tipo da vari�vel de return da function fkg_cod_id_nat_rec_pc.
--
-- Em 27/08/2013 - Angela In�s.
-- Redmine #598 - Islaine - EFD Contribuicoes Ficha HD 66842.
-- Alterar a fun��o que recupera o tipo de cr�dito considerando a CFOP de Importa��o (in�cio 3), utilizando os c�digos 108, 208 e 308.
-- Rotina: fkg_relac_tipo_cred_pc_id.
--
-- Em 09/09/2013 - Angela In�s.
-- Redmine #648 - Suporte - Tadeu/Verdemar - Gera��o do PIS/COFINS - Abertura do arquivo.
-- Considerar o par�metro da empresa que indica se ir� utilizar recupera��o do tipo de cr�dito com o processo Embalagem ou n�o.
-- Rotina: fkg_relac_tipo_cred_pc_id.
--
-- Em 04/11/2013 - Angela In�s.
-- Redmine #1156 - Implementar o par�metro que indica gera��o autom�tica de ajuste no bloco M210 nos processos do PIS/COFINS.
-- Rotina: fkg_dmgeraajusm210_parcfopempr - Inclus�o da fun��o para retornar se o CFOP gera valor como ajuste na consolida��o para PIS e COFINS.
-- Rotina: fkg_id_cd_ajustcontrpc - Inclus�o da fun��o para retornar o identificador do c�digo de ajuste de contribui��o ou cr�dito.
--
-- Em 26/12/2013 - Angela In�s.
-- Redmine #1324 - Informa��o - Nova regra de valida��o CST 05 EFD Contribui��es Vers�o 2.0.5.
-- 1) Fun��o criada para encontrar a parametriza��o na tabela NAT_REC_PC que indica se o c�digo de situa��o tribut�ria vinculado (nat_rec_pc.codst_id),
-- ir� gerar receita (blocos M400 e M800): DM_GERA_RECEITA = 0-N�O, 1-SIM.
-- Rotina: fkg_dm_gerareceita_natrecpc.
--
-- Em 20/02/2014 - Angela In�s.
-- Redmine #1971 - Fun��o para retornar o par�metro de C�lculo autom�tico do Bloco M.
-- Rotina: fkg_dmcalcblocomaut_empresa.
--
-- Em 27/03/2014 - Angela In�s.
-- Redmine #2416 - Processo de c�lculo do M105 e M505.
-- Incluir a fun��o que recupera a descri��o do "C�digo da Base de C�lculo do Cr�dito" atrav�s do identificador.
-- Rotina: fkg_descr_basecalccredpc.
--
-- Em 07/04/2014 - Angela In�s.
-- Redmine #2454 - Embora a Gera��o do EFD Contribui��es est� com o status Validado ou Gerado o Portal permite que o usu�rio abra o Bloco M.
-- Incluir a fun��o que verifica se existe per�odo de abertura de efd pis/cofins com arquivo gerado, para desprocessar os registros desejados.
-- Rotina: fkb_existe_perarq_gerado.
--
-- Em 24/04/2014 - Angela In�s.
-- Redmine #2506/#2766 - Processo da Apura��o da Contribui��o Previdenci�ria Sobre a Receita Bruta.
-- Incluir a fun��o que retorna o identificador do c�digo de atividade incidente da contribui��o previdenci�ria sobre a receita bruta.
-- Rotina: fkg_codativcprb_id_empativcprb.
--
-- Em 19/05/2014 - Angela In�s.
-- Redmine #2767 - Gera��o do arquivo da EFD Contribui��es. Implementar a gera��o do Bloco P � Apura��o da Contribui��o Previdenci�ria sobre a Receita Bruta.
-- 1) Incluir fun��o para retornar o c�digo da atividade sujeita a incid�ncia da Contribui��o Previdenci�ria sobre a Receita Bruta.
-- 2) Incluir fun��o para retornar o c�digo de Detalhamento da Contribui��o Previdenci�ria sobre a Receita Bruta.
-- 3) Incluir fun��o para retornar o c�digo de ajuste de contribui��o ou cr�dito atrav�s do identificador.
-- Rotinas: fkg_cd_codativcprb, fkg_cd_coddetcprb e fkg_cd_ajustcontrpc.
--
-- Em 08/09/2014 - Angela In�s.
-- Redmine #4110 - Feedback #3901 - Melhoria #3842: Adpta��o do Modelo 65-NFCe para Obriga��es Fiscais.
-- Fun��o retorna o identificador do c�digo de atividade incidente da contribui��o previdenci�ria sobre a receita bruta, deve recuperar da empresa enviada
-- pelo par�metro, e caso n�o exista, recuperar da empresa matriz.
-- Rotina: fkg_codativcprb_id_empativcprb.
--
-- Em 26/12/2014 - Angela In�s.
-- Redmine #5616 - Adequa��o dos objetos que utilizam dos novos conceitos de Mult-Org.
-- Inverter os par�metros de entrada mantendo en_multorg_id como sendo o primeiro par�metro.
--
-- Em 17/03/2015 - Angela In�s.
-- Redmine #7027 - Apura��o do Bloco P - Previd�ncia.
-- Devemos acertar a fun��o que recupera o par�metro que indica se a CFOP gera receita pk_csf_efd_pc.fkg_gera_recisen_cfop_empr:
-- Considerar 0-N�o, caso n�o tenha par�metro gerado (no_data_found: empresa do par�metro e empresa da matriz).
--
-- Em 25/03/2015 - Angela In�s.
-- Redmine #7269 - Altera��o no processo de fun��es espec�ficas do EFD-Contribui��es.
-- 1) Criar uma fun��o que recupera o par�metro PARAM_CFOP_EMPRESA.DM_GERA_INSS_DESON: CFOP gera INSS Desonerado - fkb_gerainssdeson_cfop.
-- Par�metros de entrada: empresa_id e cfop_id.
-- 2) Criar uma fun��o que recupera o par�metro PARAM_EFD_CONTR.DM_VALIDA_INSS_DESON: Empresa valida ou n�o e se gera ou n�o log de inconsist�ncia
-- para INSS Desonerado - fkb_valinssdeson_empr. Par�metro de entrada: empresa_id.
-- 3) Criar uma fun��o que consiste o c�digo de atividade incidente da contribui��o previdenci�ria sobre a receita bruta com o per�odo de
-- validade da apura��o (cod_ativ_cprb.dt_ini e cod_ativ_cprb.dt_fin / apuracao_cprb.dt_ini e apuracao_cprb.dt_fin) - fkb_valida_codativcprb_id.
-- Par�metros de entrada: cod_ativ_cprb.id, dt_inicial e dt_final.
--
-- Em 16/04/2015 - Angela In�s.
-- Redmine #7724 - Processo INSS Desonerado - Bloco CPRB. Corre��o no processo.
-- Incluir fun��o para recuperar a al�quota vinculada ao c�digo da atividade da previd�ncia (cod_ativ_cprb.aliq).
-- Rotina: fkb_aliq_codativcprb_id.
--
-- Em 09/06/2015 - Angela In�s.
-- Redmine #9024 - Apura��o autom�tica dos ajustes dos Blocos M200 e M600 - Sped EFD-Contribui��es.
-- Alterar o nome da tabela onde retorna o tipo de campo da fun��o fkg_contr_soc_apur_pc_id, ficando: contr_soc_apur_pc.id.
--
-- Em 16/07/2015 - Angela In�s.
-- Redmine #10092 - Corre��o no Ajuste autom�tico Blocos M210 e M610.
-- Para recuperar o c�digo da contribui��o social do ajuste (contr_soc_apur_pc), deve ser considerado tamb�m a al�quota de cofins (pk_apur_cofins.pkb_monta_dados_m600).
-- Rotina: pk_csf_efd_pc.fkg_ajuste_cons_contr_id.
--
-- Em 19/08 - 01/09/2015 - Angela In�s.
-- Redmine #9837 - Ajuste Autom�tico Apura��o Bloco P - CPRB - Processos.
-- Incluir fun��o para retornar os par�metros de CFOP para os ajustes da CPRB atrav�s de Empresa e CFOP (param_cfop_empresa).
-- Rotina: pk_csf_efd_pc.fkb_paramcfopempr_emprcfop.
--
-- Em 13/10/2015 - Angela In�s.
-- Redmine #12181 - Gera��o do Arquivo Sped EFD-Contribui��es.
-- Considerar a composi��o do tipo de cr�dito 102 do CST 50, igual para os outros CSTs.
-- Rotina: pk_csf_efd_pc.fkg_relac_tipo_cred_pc_id.
--
-- Em 20/04/2016 - F�bio Tavares.
-- Redmine #10112 - Alteraos processos que utilizam o par�metro para o novo nome da coluna dm_gera_ajuste_contr
-- da tabela param_cfop_empresa.
-- Rotina: fkg_gera_recisen_cfop_empr.
--
-- Em 03/05/2016 - Angela In�s.
-- Redmine #18448 - Corre��o na gera��o do EFD-Contribui��es - Blocos M200 e M600.
-- 1) Inclus�o da fun��o que identifica se existe Obriga��es a Recolher da Apura��o de PIS das consolida��es de contribui��es com origem Digitado.
-- Rotina: fkb_existe_pisor_gerado.
-- 2) Inclus�o da fun��o que identifica se existe Obriga��es a Recolher da Apura��o de COFINS das consolida��es de contribui��es com origem Digitado.
-- Rotina: fkb_existe_cofinsor_gerado.
--
-- Em 29/06/2016 - Angela In�s.
-- Redmine #20812 - Processo de PIS e COFINS - Gera��o do Bloco M100/M500.
-- Fun��o retorna se existe Relacionamento entre Apura��o de Cr�dito (M100) e Controle de Cr�dito Fiscal (1100) - PIS.
-- Fun��o retorna se existe Valores de Relacionamento entre Apura��o de Cr�dito (M100) e Controle de Cr�dito Fiscal (1100) - PIS.
-- Fun��es: fkb_existe_relac_apur_pis e fkb_existe_rel_apur_contr_pis.
-- Fun��o retorna se existe Relacionamento entre Apura��o de Cr�dito (M500) e Controle de Cr�dito Fiscal (1500) - COFINS.
-- Fun��o retorna se existe Valores de Relacionamento entre Apura��o de Cr�dito (M500) e Controle de Cr�dito Fiscal (1500) - COFINS.
-- Fun��es: fkb_existe_relac_apur_cof e fkb_existe_rel_apur_contr_cof.
-- Redmine #20813 - Processo de PIS e COFINS - Gera��o do Bloco 1100/1500.
-- Fun��o retorna se existe Relacionamento entre Apura��o de Cr�dito (M100) e Controle de Cr�dito Fiscal (1100) - Controle de Cr�dito Fiscal
-- Fun��o retorna se existe Valores de Relacionamento entre Apura��o de Cr�dito (M100) e Controle de Cr�dito Fiscal (1100) - Controle de Cr�dito Fiscal
-- Fun��es: fkb_existe_relac_contr_pis e fkb_existe_rel_vlr_contr_pis.
-- Fun��o retorna se existe Relacionamento entre Apura��o de Cr�dito (M500) e Controle de Cr�dito Fiscal (1500) - Controle de Cr�dito Fiscal
-- Fun��o retorna se existe Valores de Relacionamento entre Apura��o de Cr�dito (M500) e Controle de Cr�dito Fiscal (1500) - Controle de Cr�dito Fiscal
-- Fun��es: fkb_existe_relac_contr_cof e fkb_existe_rel_vlr_contr_cof.
--
-- Em 17/11/2016 - Angela In�s.
-- Redmine #25369 - Altera��o em fun��o que recupera C�digo de Contribui��o Social.
-- 1) Alterar a rotina que recupera o identificador da contribui��o social, incluindo o par�metro que indica qual o bloco a ser gerado devido ao processo do
-- Bloco F200. Rotina: pk_csf_efd_pc.fkg_relac_cons_contr_id.
-- 2) Alterar a rotina que retorna o identificador do tipo de cr�dito para os impostos PIS/PASEP e COFINS atrav�s de par�metros, incluindo o identificador da
-- base de c�lculo de cr�dito como par�metro de entrada - en_basecalccredpc_id, que dever� ser utilizado somente para os dados do Bloco F150, caso contr�rio,
-- dever� ser enviado como 0(zero). Rotina: fkg_relac_tipo_cred_pc_id.
--
-- Em 20/12/2017 - Angela In�s.
-- Redmine #37054 - Criar processo de valida��o das informa��es dos Blocos A, C, D, F e I.
-- Rotinas criadas para retornar os identificadores do Plano de Contas e do Centro de Custo dos Impostos PIS e COFINS:
-- Fun��es: fkb_recup_pcta_pis, fkb_recup_pcta_cofins, fkb_recup_ccust_pis e fkb_recup_ccust_cofins.
--
-- Em 09/01/2018 - Angela In�s.
-- Redmine #38308 - Corre��es nos processos de valida��o.
-- Passar a considerar os par�metros de entrada para recupera��o dos planos de contas e centros de custos da seguinte forma e ordem:
-- 1) Todos os par�metros iguais seguindo a ordem: en_dm_ind_emit, en_dm_ind_oper, en_modfiscal_id, en_pessoa_id, en_cfop_id, en_item_id, en_ncm_id e en_tpservico_id.
-- 2) N�o encontramos estaremos recuperando na mesma ordem do item 1, por�m eliminando do �ltimo campo at� o primeiro, comparando na igualdade (=).
-- 3) N�o encontrando nos itens 1 e 2, estaremos recuperando na mesma do item 1, por�m do primeiro at� o �ltimo, mas com apenas um dos campos enviado no
-- par�metro, e os outros como sendo nulos. Exemplo: en_dm_ind_emit = tabela, e os outros campos da tabela como sendo nulos (is null).
-- Fun��es: fkb_recup_pcta_pis, fkb_recup_pcta_cofins, fkb_recup_ccust_pis e fkb_recup_ccust_cofins.
--
-- Em 10/01/2018 - Angela In�s.
-- Redmine #38364 - Corre��o na recupera��o dos par�metros - Planos de Contas e Centros de Custos - PIS e COFINS.
-- 1) Atender a recupera��o dos planos de contas e centros de custos atrav�s dos par�metros enviados dos documentos fiscais e registros dos Blocos F e I.
-- 2) N�o encontrando par�metros atrav�s do item 1, o processo ir� recuperar os planos de contas e centros de custos com apenas um dos campos enviado no par�metro, e os outros como sendo nulos. Exemplo: en_dm_ind_emit = tabela, e os outros campos da tabela como sendo nulos (is null).
-- Fun��o: fkb_recup_pcta_ccto_pc.
--
-- Em 13/03/2018 - Angela In�s.
-- Redmine #40467 - Altera��o dos Registro C110 e 0450 do Sped Contribui��es que as informa��es adicionais sejam exportadas de forma integral no arquivo Texto.
-- Criar fun��o para recuperar par�metro em "Par�metros EFD PIS/COFINS": param_efd_contr.dm_quebra_infadic_spedc - 0-N�o, 1-Sim.
-- Fun��o: fkg_parefdcontr_dmqueinfadi.
--
-- Em 23/03/2018 - Angela In�s.
-- Redmine #40901 - Corre��o nas fun��es que recuperam Plano de Contas de Centros de Custos.
-- 1) Eliminar as fun��es: fkb_recup_pcta_pis, fkb_recup_pcta_cofins, fkb_recup_ccust_pis e fkb_recup_ccust_cofins.
-- 2) Alterar a fun��o que retorna ou plano de conta para PIS ou COFINS, ou, centro de custo para PIS ou COFINS, considerando os valores enviados dos documentos
-- fiscais, por�m nos par�metros os valores possam estar nulos.
-- Fun��es eliminadas: fkb_recup_pcta_pis, fkb_recup_pcta_cofins, fkb_recup_ccust_pis e fkb_recup_ccust_cofins.
-- Fun��o: fkb_recup_pcta_ccto_pc.
--
-- Em 11/04/2018 - Marcos Ferreira
-- Redmine #41435 - Processos - Cria��o de Par�metros CST de PIS e COFINS para Gera��o e Apura��o do EFD-Contribui��es.
-- Inclus�o das vari�veis globais para tratar log_gen�rico
-- Altera��o na Fun��o fkg_gera_recisen_cfop_empr
-- Altera��o na Fun��o fkg_gera_escr_efdpc_cfop_empr
-- Altera��o na Fun��o fkg_dmgeraajusm210_parcfopempr
--
-- Em 27/04/2018 - Angela In�s.
-- Redmine #42250 - Parametriza��o de Conta Cont�bil SPED - PIS/COFINS.
-- A fun��o que recupera o plano de conta para atualiza��o dos documentos fiscais, ir� recuperar o plano de conta mais recente (max planoconta_id), quando
-- houver mais de um registro de acordo com os par�metros enviados para consulta.
-- Rotina: fkb_recup_pcta_ccto_pc.
--
-- Em 16/05/2018 - Angela In�s.
-- Redmine #42924 - Corre��es nos processos de Valida��o e Atualiza��o de Plano de Contas e Centros de Custos - Sped EFD-Contribui��es.
-- Corre��o na recupera��o dos identificadores de Plano de Contas e Centros de Custos.
-- Quando existem mais de um registro, com duplicidade de informa��es, a recupera��o ser� feita considerando todos os campos enviados, por�m ordenados por:
-- tpservico_id, ncm_id, item_id, cfop_id, pessoa_id, modfiscal_id, dm_ind_oper e dm_ind_emit. Consideramos do �ltimo par�metro enviado at� o primeiro.
-- Rotina: fkb_recup_pcta_ccto_pc.
--
-- Em 29/06/2018 - Angela In�s.
-- Redmine #44515 - Processo do Sped EFD-Contribui��es: C�lculo, Valida��o e Gera��o do Arquivo.
-- Revisar todos os processos de C�lculo, Valida��o e Gera��o do Arquivo Sped EFD-Contribui��es.
-- Rotinas: fkg_gera_recisen_cfop_empr, fkg_gera_cred_nfpc_cfop_empr, fkg_gera_escr_efdpc_cfop_empr, fkg_dmgeraajusm210_parcfopempr, fkb_gerainssdeson_cfop, e
-- fkb_paramcfopempr_emprcfop.
--
-- Em 20/07/2018 - Angela In�s.
-- Redmine #45001 - Corre��es nos processos de Apura��o e Gera��o do EFD-Contribui��es.
-- Corre��o na fun��o que recupera o Tipo de Cr�dito para os Impostos PIS e COFINS.
-- Na montagem da Apura��o dos PIS e COFINS - Blocos M100 e M500, considerar os 3(tr�s) lan�amentos, com os Tipos de Cr�ditos 108, 208 e 308, para os registros
-- informados no Bloco F130 - Bens incorporados ao ativo imobilizado - Aquisi��o/Contribui��o, quando a Origem de Cr�dito for Opera��o de Importa��o, que n�o
-- possui CST e nem possui CFOP. Atualmente o processo considera apenas um lan�amento com o Tipo de Cr�dito 108.
-- Rotina: fkg_relac_tipo_cred_pc_id.
--
-- Em 24/07/2018 - Angela In�s.
-- Redmine #45297 - Alterar as fun��es utilizadas nas Apura��es e Gera��es do Arquivo Sped EFD-Contribui��es.
-- Alterar as fun��es que recuperam os valores dos Par�metros de CFOP e CST, para comp�r os valores de Apura��o e Gera��o do Arquivo.
-- Rotinas: fkg_gera_recisen_cfop_empr, fkg_gera_cred_nfpc_cfop_empr, fkg_gera_escr_efdpc_cfop_empr, fkg_dmgeraajusm210_parcfopempr, fkb_gerainssdeson_cfop, e
-- fkb_paramcfopempr_emprcfop.
--
-- Em 15/08/2018 - Marcos Ferreira.
-- Redmine #45660 - R-2060 - Parametriza��o por NCM
-- Solicita��o: Atualmente para realizarmos o calculo da CPRB da Reinf est� sendo utilizada a configura��o que era utilizada no c�lculo do bloco P, ou seja, por parametriza��o dos itens que ficam sujeitos a CPRB.
--              Como a configura��o atual � massificante e demanda uma manuten��o maior, sugerimos que a regra de parametriza��o seja feita por NCM conforme especificado no projeto inicial da REINF e em complemento utilize a configura��o por item para filtrar as notas sujeitas a CPRB.
-- Altera��o: Ap�s Inclu�do coluna nova ncm_id na tabela EMPRESA_ATIVCPRB, alterado a fun��o fkg_codativcprb_id_empativcprb para buscar por ncm caso n�o encontre por item_id
--            Inlcu�do novo parametro de entrada na fun��o: ncm_id
--
-- Em 17/09/2018 - Karina de Paula
-- Redmine #46949 - fkg_gera_escr_efdpc_cfop_empr => Alterada a pk_csf_efd_pc.fkg_gera_escr_efdpc_cfop_empr para retornar valor do dm_gera_escr_efd
-- como "zero" qdo o impostos CST de PIS e/ou COFINS estiver cadastrado na tab de par�metros param_cfop_empr_cst.
--
-- Em 15/10/2018 - Angela In�s.
-- Redmine #47800 - Corre��o na recupera��o dos par�metros de CFOP para PIS e COFINS.
-- Recuperar os valores gerados para o par�metro param_cfop_empresa.dm_gera_escr_efd, e n�o atribuir 0(zero), quando existir informa��o de CST.
-- Rotina: fkg_gera_escr_efdpc_cfop_empr.
--
-------------------------------------------------------------------------------------------------------

   gv_mensagem_log       log_generico.mensagem%type := null;
   gv_obj_referencia     log_generico.obj_referencia%type := null;
   gn_referencia_id      log_generico.referencia_id%type := null;
   gv_resumo_log         log_generico.resumo%type := null;

-------------------------------------------------------------------------------------------------------

-- Declara��o de constantes
   erro_de_validacao     constant number := 1;
   erro_de_sistema       constant number := 2; -- 2-Erro geral do sistema
   erro_inform_geral     constant number := 35; -- 35-Informa��o Geral

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID do Registro do Bloco da EFD Pis/Cofins conforme c�digo do bloco
function fkg_registr_efd_pc_id ( ev_cd in registr_efd_pc.cd%type )
         return registr_efd_pc.id%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna o ID da tabela Base de C�lculo de Cr�dito
function fkg_base_calc_cred_pc_id ( ev_cd in base_calc_cred_pc.cd%type )
         return base_calc_cred_pc.id%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna o CD da tabela Base de C�lculo de Cr�dito, conforme ID
function fkg_base_calc_cred_pc_cd ( en_id in base_calc_cred_pc.id%type )
         return base_calc_cred_pc.cd%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o confirma o ID da tabela Base de C�lculo de Cr�dito
function fkg_id_base_calc_cred_pc_id ( en_id in base_calc_cred_pc.id%type )
         return base_calc_cred_pc.id%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o que recupera a descri��o do "C�digo da Base de C�lculo do Cr�dito" atrav�s do identificador
function fkg_descr_basecalccredpc ( en_basecalccredpc_id in base_calc_cred_pc.id%type )
         return base_calc_cred_pc.descr%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna o ID do C�digo do Grupo por Marca Comercial/Refrigerantes
function fkg_id_item_marca_comerc ( en_item_id in item.id%type )
         return item_marca_comerc.id%type;

---------------------------------------------------------------------------------------------------------------
-- Fun��o retorna o identificador do tipo de cr�dito para os impostos PIS/PASEP e COFINS atrav�s de par�metros
function fkg_relac_tipo_cred_pc_id ( en_empresa_id        in empresa.id%type      -- identificador da empresa
                                   , en_tipoimp_id        in tipo_imposto.id%type -- identificador do tipo de imposto (pis ou cofins)
                                   , en_codst_id          in cod_st.id%type       -- identificador do c�digo ST
                                   , en_ncm_id            in ncm.id%type          -- identificador do c�digo ncm
                                   , en_cfop_id           in cfop.id%type         -- identificador do c�digo cfop
                                   , en_ind_orig_cred     in number               -- indicador de cr�dito 0-Oper.Mercado Interno, 1-Oper.Importa��o
                                   , en_vl_aliq           in number               -- valor de al�quota dos impostos: identificar b�sica ou diferenciada
                                   , en_qt_bc_imp         in number               -- valor da base de c�lculo - por unidade de produto
                                   , en_vl_bc_imp         in number               -- valor da base de c�lculo - por valor
                                   , en_seq_lancto        in number               -- sequ�ncia de lan�amento
                                   , en_basecalccredpc_id in number               -- identificador da base de c�lculo de cr�dito para Bloco F150
                                   , en_pessoa_id         in pessoa.id%type )     -- identificador da pessoa do documento fiscal								   
         return tipo_cred_pc.id%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o para retornar o identificador do tipo de cr�dito para os impostos pis/cofins
function fkg_tipo_cred_pc_id ( ev_cd in tipo_cred_pc.cd%type )
         return tipo_cred_pc.id%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o para retornar o c�digo do identificador do tipo de cr�dito para os impostos pis/cofins
function fkg_cd_tipo_cred_pc ( en_tipocredpc_id in tipo_cred_pc.id%type )
         return tipo_cred_pc.cd%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o para retornar o c�digo do identificador da Contribui��o Social para os Impostos PIS e COFINS
function fkg_cd_contr_soc_apur_pc ( en_contrsocapurpc_id in contr_soc_apur_pc.id%type )
         return contr_soc_apur_pc.cd%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o para retornar o identificador do C�digo de Contribui��o Social para os Impostos PIS e COFINS
function fkg_contr_soc_apur_pc_id ( ev_cd in contr_soc_apur_pc.cd%type )
         return contr_soc_apur_pc.id%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna o c�digo de contribui��o social atrav�s de par�metros
function fkg_relac_cons_contr_id ( en_tipoimp_id      in tipo_imposto.id%type -- identificador do tipo de imposto (pis ou cofins)
                                 , en_ind_orig_cred   in number               -- indicador de cr�dito 0-Oper.Mercado Interno, 1-Oper.Importa��o
                                 , en_codst_id        in cod_st.id%type       -- identificador do c�digo ST
                                 , en_vl_aliq         in number               -- valor de al�quota em percentual
                                 , en_vl_aliq_quant   in number               -- valor da al�quota por unidade de produto
                                 , en_dm_cod_inc_trib in abertura_efd_pc_regime.dm_cod_inc_trib%type -- indicador da incid�ncia tribut�ria
                                 , ev_bloco           in varchar2 default null ) -- c�digo do bloco a ser processado
         return contr_soc_apur_pc.id%type;

------------------------------------------------------------------------------------------------------------------------
-- Fun��o retorna o c�digo de contribui��o social atrav�s de par�metros para ajustes autom�ticos dos blocos M200 e M600
function fkg_ajuste_cons_contr_id ( en_tipoimp_id      in tipo_imposto.id%type                        -- identificador do tipo de imposto (pis ou cofins)
                                  , en_dm_ind_ativ     in abertura_efd_pc.dm_ind_ativ%type            -- indicador de atividade
                                  , en_dm_cod_inc_trib in abertura_efd_pc_regime.dm_cod_inc_trib%type -- indicador da incid�ncia tribut�ria
                                  , en_cd_codst        in cod_st.cod_st%type                          -- c�digo ST
                                  , en_aliq            in imp_itemnf.aliq_apli%type )                 -- valor de al�quota em percentual
         return contr_soc_apur_pc.id%type;

--------------------------------------------------------------------------------------------------------------
-- Fun��o para retornar a descri��o do c�digo do identificador do tipo de cr�dito para os impostos PIS/COFINS
function fkg_descr_tipo_cred_pc ( en_tipocredpc_id in tipo_cred_pc.id%type )
         return tipo_cred_pc.descr%type;

------------------------------------------------------------------------------------------------------------------
-- Fun��o para retornar o identificador da Natureza de Receita Conforme C�digo de Situa��o Tribut�ria e Al�quotas
function fkg_nat_rec_pc_id ( en_multorg_id in nat_rec_pc.multorg_id%type
                           , en_codst_id   in cod_st.id%type
                           , en_aliq_apli  in number
                           , en_aliq_qtde  in number
                           , en_ncm_id     in number   default 0
                           , ev_cod_ncm    in varchar2 default null )
         return nat_rec_pc.id%type;

------------------------------------------------------------------------------------------------------
-- Fun��o para confirmar o identificador da Natureza de Receita
function fkg_conf_id_nat_rec_pc ( en_natrecpc_id in nat_rec_pc.id%type )
         return nat_rec_pc.id%type;

------------------------------------------------------------------------------------------------------------------
-- Fun��o para retorar o "c�digo" da Natureza da Receita do Pis/COFINS
function fkg_cod_id_nat_rec_pc ( en_natrecpc_id in nat_rec_pc.id%type )
         return nat_rec_pc.cod%type;

------------------------------------------------------------------------------------------------------------------
-- Fun��o para retorar o "ID" da Natureza da Receita do Pis/COFINS pelo Cod_st e cod
function fkg_codst_id_nat_rec_pc ( en_multorg_id        in nat_rec_pc.multorg_id%type
                                 , en_natrecpc_codst_id in nat_rec_pc.codst_id%type
                                 , en_natrecpc_cod      in nat_rec_pc.cod%type )
          return nat_rec_pc.id%type;

------------------------------------------------------------------------------------------------------
-- Fun��o para retornar a situa��o da apura��o de cr�dito
function fkg_sit_apur_pis ( en_apurcredpis_id in apur_cred_pis.id%type )
         return apur_cred_pis.dm_situacao%type;

------------------------------------------------------------------------------------------------------
-- Fun��o para retornar a quantidade de registros relacionados ao per�odo da apura��o de cr�dito - PIS
function fkg_qtde_apur_pis ( en_perapurcredpis_id in per_apur_cred_pis.id%type )
         return number;

------------------------------------------------------------------------------------------------------
-- Fun��o para retornar a quantidade de registros relacionados a apura��o de cr�dito - PIS
function fkg_qtde_det_apur_pis ( en_apurcredpis_id in apur_cred_pis.id%type )
         return number;

------------------------------------------------------------------------------------------------------
-- Fun��o para retornar a quantidade de registros relacionados ao per�odo de consolida��o do imposto PIS
function fkg_qtde_cons_pis ( en_perconscontrpis_id in per_cons_contr_pis.id%type )
         return number;

------------------------------------------------------------------------------------------------------
-- Fun��o para retornar a quantidade de registros relacionados a consolida��o do imposto PIS
function fkg_qtde_det_cons_pis ( en_conscontrpis_id in cons_contr_pis.id%type )
         return number;

------------------------------------------------------------------------------------------------------
-- Fun��o para retornar a quantidade de registros relacionados ao per�odo das receitas isentas - PIS
function fkg_qtde_per_rec_pis ( en_perrecisentapis_id in per_rec_isenta_pis.id%type )
         return number;

------------------------------------------------------------------------------------------------------
-- Fun��o para retornar a quantidade de registros relacionados a receitas isentas do imposto PIS
function fkg_qtde_det_rec_pis ( en_recisentapis_id in rec_isenta_pis.id%type )
         return number;

------------------------------------------------------------------------------------------------------
-- Fun��o para retornar a situa��o da apura��o de cr�dito para o imposto COFINS
function fkg_sit_apur_cofins ( en_apurcredcofins_id in apur_cred_cofins.id%type )
         return apur_cred_cofins.dm_situacao%type;

----------------------------------------------------------------------------------------------------------
-- Fun��o para retornar a quantidade de registros relacionados ao per�odo da apura��o de cr�dito - COFINS
function fkg_qtde_apur_cofins ( en_perapurcredcofins_id in per_apur_cred_cofins.id%type )
         return number;

------------------------------------------------------------------------------------------------------
-- Fun��o para retornar a quantidade de registros relacionados a apura��o de cr�dito - COFINS
function fkg_qtde_det_apur_cofins ( en_apurcredcofins_id in apur_cred_cofins.id%type )
         return number;

------------------------------------------------------------------------------------------------------------
-- Fun��o para retornar a quantidade de registros relacionados ao per�odo da consolida��o do imposto COFINS
function fkg_qtde_cons_cofins ( en_perconscontrcofins_id in per_cons_contr_cofins.id%type )
         return number;

----------------------------------------------------------------------------------------------------------
-- Fun��o para retornar a quantidade de registros relacionados a consolida��o do imposto COFINS
function fkg_qtde_det_cons_cofins ( en_conscontrcofins_id in cons_contr_cofins.id%type )
         return number;

----------------------------------------------------------------------------------------------------------
-- Fun��o para retornar a quantidade de registros relacionados ao per�odo das receitas isentas - COFINS
function fkg_qtde_per_rec_cofins ( en_perrecisentacofins_id in per_rec_isenta_cofins.id%type )
         return number;

----------------------------------------------------------------------------------------------------------
-- Fun��o para retornar a quantidade de registros relacionados a receitas isentas do imposto COFINS
function fkg_qtde_det_rec_cofins ( en_recisentacofins_id in rec_isenta_cofins.id%type )
         return number;

----------------------------------------------------------------------------------------------------------
-- Fun��o retorna o CD da tabela Orig_Proc
function fkg_cd_orig_proc ( en_origproc_id  in orig_proc.id%type )
         return orig_proc.cd%type;

----------------------------------------------------------------------------------------------------------
-- Fun��o confirma o ID da tabela Plano de Conta
function fkg_id_plano_conta_id ( en_id in plano_conta.id%type )
         return plano_conta.id%type;

----------------------------------------------------------------------------------------------------------
-- Fun��o confirma o ID da tabela Centro de Custo
function fkg_id_centro_custo_id ( en_id in centro_custo.id%type )
         return centro_custo.id%type;

----------------------------------------------------------------------------------------------------------
-- Procedimento para gravar o log/altera��o das notas fiscais de servi�os cont�nuos
procedure pkb_inclui_log_nf_serv_cont( en_notafiscal_id in nota_fiscal.id%type
                                     , ev_resumo        in log_nf_serv_cont.resumo%type
                                     , ev_mensagem      in log_nf_serv_cont.mensagem%type
                                     , en_usuario_id    in neo_usuario.id%type
                                     , ev_maquina       in varchar2 );

----------------------------------------------------------------------------------------------------------
-- Fun��o verifica se o CFOP gera receita isenta para a empresa
-- O sistema busca na empresa, seja filial, ou busca na matriz -> 0-n�o, 1-sim -> valor default 1-sim
function fkg_gera_recisen_cfop_empr ( en_empresa_id      in param_cfop_empresa.empresa_id%type
                                    , en_cfop_id         in param_cfop_empresa.cfop_id%type
                                    , en_codst_id_pis    in param_cfop_empr_cst.codst_id_pis%type    default null
                                    , en_codst_id_cofins in param_cfop_empr_cst.codst_id_cofins%type default null
                                    )
         return param_cfop_empresa.dm_gera_receita%type;

----------------------------------------------------------------------------------------------------------
-- Fun��o verifica se o CFOP gerou cr�dito de pis/cofins para nota fiscal de entrada de pessoa f�sica e n�o deveria
-- O sistema busca na empresa, seja filial, ou busca na matriz -> 0-n�o, 1-sim -> valor default 0-n�o
function fkg_gera_cred_nfpc_cfop_empr ( en_empresa_id      in param_cfop_empresa.empresa_id%type
                                      , en_cfop_id         in param_cfop_empresa.cfop_id%type
                                      , en_codst_id_pis    in param_cfop_empr_cst.codst_id_pis%type    default null
                                      , en_codst_id_cofins in param_cfop_empr_cst.codst_id_cofins%type default null
                                      )
         return param_cfop_empresa.dm_gera_cred_pf_pc%type;

----------------------------------------------------------------------------------------------------------
-- Fun��o verifica se o CFOP gera escritura��o fiscal - gera��o do arquivo texto de pis/cofins
-- O sistema busca na empresa, seja filial, ou busca na matriz -> 0-n�o, 1-sim -> valor default 1-sim
function fkg_gera_escr_efdpc_cfop_empr ( en_empresa_id      in param_cfop_empresa.empresa_id%type
                                       , en_cfop_id         in param_cfop_empresa.cfop_id%type
                                       , en_codst_id_pis    in param_cfop_empr_cst.codst_id_pis%type    default null
                                       , en_codst_id_cofins in param_cfop_empr_cst.codst_id_cofins%type default null
                                       )
         return param_cfop_empresa.dm_gera_escr_efd_pc%type;

----------------------------------------------------------------------------------------------------------
-- Fun��o retorna id da tabela REGISTRO_DACON conforme o c�digo.
function fkg_registrodacon_id ( ev_cod  in  registro_dacon.cd%type )
         return registro_dacon.id%type;

----------------------------------------------------------------------------------------------------------
-- Fun��o retorna c�digo da tabela REGISTRO_DACON conforme o id.
function fkg_registrodacon_cd ( en_registrodacon_id  in  registro_dacon.id%type )
         return registro_dacon.cd%type;

----------------------------------------------------------------------------------------------------------
-- Fun��o retorna id da tabela PROD_DACON conforme o c�digo e o dm_tabela.
function fkg_proddacon_id ( ev_cod        in  prod_dacon.cd%type
                          , ev_dm_tabela  in  prod_dacon.dm_tabela%type )
         return prod_dacon.id%type;

----------------------------------------------------------------------------------------------------------
-- Fun��o retorna c�digo da tabela PROD_DACON conforme o id.
function fkg_proddacon_cd ( en_proddacon_id  in  prod_dacon.id%type )
         return prod_dacon.cd%type;

----------------------------------------------------------------------------------------------------------
-- Fun��o para retornar se o CFOP gera valor como ajuste na consolida��o para PIS e COFINS.
function fkg_dmgeraajusm210_parcfopempr ( en_empresa_id      in empresa.id%type
                                        , en_cfop_id         in cfop.id%type
                                        , en_codst_id_pis    in param_cfop_empr_cst.codst_id_pis%type    default null
                                        , en_codst_id_cofins in param_cfop_empr_cst.codst_id_cofins%type default null
                                        )
         return param_cfop_empresa.dm_gera_ajuste_contr%type;

----------------------------------------------------------------------------------------------------------
-- Fun��o para retornar o identificador do c�digo de ajuste de contribui��o ou cr�dito atrav�s do c�digo.
function fkg_id_cd_ajustcontrpc ( en_cd in ajust_contr_pc.cd%type )
         return ajust_contr_pc.id%type;

----------------------------------------------------------------------------------------------------------
-- Fun��o para retornar o par�metro que indica gera��o de receita para CST atrav�s da Natureza de Receita
function fkg_dm_gerareceita_natrecpc( en_natrecpc_id in nat_rec_pc.id%type )
         return nat_rec_pc.dm_gera_receita%type;

----------------------------------------------------------------------------------------------------------
-- Fun��o para retornar o par�metro de C�lculo autom�tico do Bloco M
function fkg_dmcalcblocomaut_empresa( en_empresa_id in param_efd_contr.empresa_id%type )
         return param_efd_contr.dm_calc_bloco_m_aut%type;

----------------------------------------------------------------------------------------------------------
-- Fun��o retorna se existe per�odo de abertura efd pis/cofins com arquivo gerado
function fkb_existe_perarq_gerado( en_empresa_id in empresa.id%type
                                 , ed_data       in date
                                 )
         return boolean;

------------------------------------------------------------------------------------------------------------------------
-- Fun��o retorna o identificador do c�digo de atividade incidente da contribui��o previdenci�ria sobre a receita bruta
function fkg_codativcprb_id_empativcprb( en_empresa_id   in empresa.id%type
                                       , en_item_id      in item.id%type default null
                                       , en_ncm_id       in ncm.id%type  default null
                                       , en_tpservico_id in tipo_servico.id%type default null 
                                       , en_cnae_id      in cnae.id%type default null
                                       )
         return empresa_ativcprb.codativcprb_id%type;

--------------------------------------------------------------------------------------------------------------------------------
-- Fun��o retorna o c�digo da atividade incidente da contribui��o previdenci�ria sobre a receita bruta atrav�s do identificador
function fkg_cd_codativcprb( en_codativcprb_id in cod_ativ_cprb.id%type
                           )
         return cod_ativ_cprb.cd%type;

-------------------------------------------------------------------------------------------------------------------------
-- Fun��o retorna o c�digo de Detalhamento da contribui��o previdenci�ria sobre a receita bruta atrav�s do identificador
function fkg_cd_coddetcprb( en_coddetcprb_id in cod_det_cprb.id%type
                          )
         return cod_det_cprb.cd%type;

-----------------------------------------------------------------------------------------------
-- Fun��o para retornar o c�digo de ajuste de contribui��o ou cr�dito atrav�s do identificador
function fkg_cd_ajustcontrpc ( en_ajustcontrpc_id in ajust_contr_pc.id%type )
         return ajust_contr_pc.cd%type;

----------------------------------------------------------------------------------------------------------------
-- Fun��o para retornar se o CFOP gera INSS desonerado, por�m sem utilizar os par�metros de CST de PIS e COFINS
function fkb_gerainssdeson_cfop ( en_empresa_id      in empresa.id%type
                                , en_cfop_id         in cfop.id%type
                                , en_codst_id_pis    in param_cfop_empr_cst.codst_id_pis%type    default null
                                , en_codst_id_cofins in param_cfop_empr_cst.codst_id_cofins%type default null
                                )
         return param_cfop_empresa.dm_gera_inss_deson%type;

---------------------------------------------------------------------------------------------------------------
-- Fun��o para retornar se a Empresa permite valida��o com registro de log/inconsist�ncia para INSS desonerado
function fkb_valinssdeson_empr ( en_empresa_id empresa.id%type )
         return param_efd_contr.dm_valida_inss_deson%type;

---------------------------------------------------------------------------------------------------------------
-- Fun��o para retornar se o c�digo de atividade incidente CPRB est� v�lido dentro do per�odo da apura��o
function fkb_valida_codativcprb_id ( en_codativcprb_id in cod_ativ_cprb.id%type
                                   , ed_dt_inicial     in date
                                   , ed_dt_final       in date )
         return cod_ativ_cprb.id%type;

---------------------------------------------------------------------------------------------------------------
-- Fun��o para retornar a al�quota vinculada ao c�digo da atividade da previd�ncia (cod_ativ_cprb.aliq)
function fkb_aliq_codativcprb_id( en_codativcprb_id in cod_ativ_cprb.id%type )
         return cod_ativ_cprb.aliq%type;

---------------------------------------------------------------------------------------------------------------------
-- Fun��o para retornar os par�metros de CFOP para os ajustes da CPRB atrav�s de Empresa e CFOP (param_cfop_empresa)
function fkb_paramcfopempr_emprcfop ( en_empresa_id          in  param_cfop_empresa.empresa_id%type
                                    , en_cfop_id             in  param_cfop_empresa.cfop_id%type
                                    , sn_dm_gera_receita     out param_cfop_empresa.dm_gera_receita%type
                                    , sn_dm_gera_inss_deson  out param_cfop_empresa.dm_gera_inss_deson%type
                                    , sn_dm_gera_ajuste_cprb out param_cfop_empresa.dm_gera_ajuste_cprb%type
                                    , sn_dm_tipo_ajuste      out param_cfop_empresa.dm_tipo_ajuste%type
                                    , sn_dm_ind_aj           out param_cfop_empresa.dm_ind_aj%type
                                    , sn_ajustcontrpc_id     out param_cfop_empresa.ajustcontrpc_id%type )
         return number;

----------------------------------------------------------------------------------------------------------------------------
-- Fun��o retorna se existe Obriga��es a Recolher da Apura��o de PIS das consolida��es de contribui��es com origem Digitado
function fkb_existe_pisor_gerado( en_perconscontrpis_id in per_cons_contr_pis.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------------------------------
-- Fun��o retorna se existe Obriga��es a Recolher da Apura��o de COFINS das consolida��es de contribui��es com origem Digitado
function fkb_existe_cofinsor_gerado( en_perconscontrcofins_id in per_cons_contr_cofins.id%type )
         return boolean;

----------------------------------------------------------------------------------------------------------------------
-- Fun��o retorna se existe Relacionamento entre Apura��o de Cr�dito (M100) e Controle de Cr�dito Fiscal (1100) - PIS
function fkb_existe_relac_apur_pis( en_apurcredpis_id in apur_cred_pis.id%type )
         return boolean;

---------------------------------------------------------------------------------------------------------------------------------
-- Fun��o retorna se existe Valores de Relacionamento entre Apura��o de Cr�dito (M100) e Controle de Cr�dito Fiscal (1100) - PIS
function fkb_existe_rel_apur_contr_pis( en_apurcredpis_id in apur_cred_pis.id%type )
         return boolean;

---------------------------------------------------------------------------------------------------------------------------------------------
-- Fun��o retorna se existe Relacionamento entre Apura��o de Cr�dito (M100) e Controle de Cr�dito Fiscal (1100) - Controle de Cr�dito Fiscal
function fkb_existe_relac_contr_pis( en_contrcredfiscalpis_id in contr_cred_fiscal_pis.id%type )
         return boolean;

--------------------------------------------------------------------------------------------------------------------------------------------------------
-- Fun��o retorna se existe Valores de Relacionamento entre Apura��o de Cr�dito (M100) e Controle de Cr�dito Fiscal (1100) - Controle de Cr�dito Fiscal
function fkb_existe_rel_vlr_contr_pis( en_contrcredfiscalpis_id in contr_cred_fiscal_pis.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------------------------
-- Fun��o retorna se existe Relacionamento entre Apura��o de Cr�dito (M500) e Controle de Cr�dito Fiscal (1500) - COFINS
function fkb_existe_relac_apur_cof( en_apurcredcofins_id in apur_cred_cofins.id%type )
         return boolean;

------------------------------------------------------------------------------------------------------------------------------------
-- Fun��o retorna se existe Valores de Relacionamento entre Apura��o de Cr�dito (M500) e Controle de Cr�dito Fiscal (1500) - COFINS
function fkb_existe_rel_apur_contr_cof( en_apurcredcofins_id in apur_cred_cofins.id%type )
         return boolean;

---------------------------------------------------------------------------------------------------------------------------------------------
-- Fun��o retorna se existe Relacionamento entre Apura��o de Cr�dito (M500) e Controle de Cr�dito Fiscal (1500) - Controle de Cr�dito Fiscal
function fkb_existe_relac_contr_cof( en_contrcredfiscalcofins_id in contr_cred_fiscal_cofins.id%type )
         return boolean;

--------------------------------------------------------------------------------------------------------------------------------------------------------
-- Fun��o retorna se existe Valores de Relacionamento entre Apura��o de Cr�dito (M500) e Controle de Cr�dito Fiscal (1500) - Controle de Cr�dito Fiscal
function fkb_existe_rel_vlr_contr_cof( en_contrcredfiscalcofins_id in contr_cred_fiscal_cofins.id%type )
         return boolean;

---------------------------------------------------------------------------------------------------------------
-- Fun��o para retornar: ou plano de conta para PIS ou COFINS; ou, centro de custo para PIS ou COFINS
function fkb_recup_pcta_ccto_pc( en_empresa_id   in param_efd_contr_geral.empresa_id%type
                               , en_dm_ind_emit  in param_efd_contr_geral.dm_ind_emit%type default null
                               , en_dm_ind_oper  in param_efd_contr_geral.dm_ind_oper%type default null
                               , en_modfiscal_id in param_efd_contr_geral.modfiscal_id%type default null
                               , en_pessoa_id    in param_efd_contr_geral.pessoa_id%type default null
                               , en_cfop_id      in param_efd_contr_geral.cfop_id%type default null
                               , en_item_id      in param_efd_contr_geral.item_id%type default null
                               , en_ncm_id       in param_efd_contr_geral.ncm_id%type default null
                               , en_tpservico_id in param_efd_contr_geral.tpservico_id%type default null
                               , ed_dt_ini       in param_efd_contr_geral.dt_ini%type
                               , ed_dt_final     in param_efd_contr_geral.dt_final%type default null
                               , en_cod_st_piscofins  in param_efd_contr_geral.cod_st_piscofins%type default null
                               , ev_ret          in varchar2 ) -- 'PCTA_PIS', 'PCTA_COF', 'CCTO_PIS', 'CCTO_COF'
         return number; -- planoconta_id_pis, centrocusto_id_pis, planoconta_id_cofins, centrocusto_id_cofins

---------------------------------------------------------------------------------------------------------------
-- Procedimento retorna o par�metro que Permite a quebra da Informa��o Adicional no arquivo Sped Contribui��es
function fkg_parefdcontr_dmqueinfadi ( en_empresa_id in empresa.id%type )
         return param_efd_contr.dm_quebra_infadic_spedc%type;

----------------------------------------------------------------------------------------------------------

end pk_csf_efd_pc;
/
