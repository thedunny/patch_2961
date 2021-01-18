CREATE OR REPLACE PACKAGE CSF_OWN.PK_APUR_COFINS IS

-------------------------------------------------------------------------------------------------------------------------------
-- Especifica��o do pacote de procedimentos de Gera��o da Apura��o de Cr�dito de Cofins - Bloco M  
-------------------------------------------------------------------------------------------------------------------------------
--
-- Em 05/01/2021   - Luis Marques - 2.9.5-4 / 2.9.6-1 / 2.9.7
-- Redmine #74674  - Gera��o do registro M100 - C�digo do Tipo de Cr�dito para servicos de transporte gerando como agroindustria
-- Rotina alterada - PKB_MONTA_DADOS_M500 - Inclus�o do parametro en_pessoa_id na chamada da fun��o "fkg_relac_tipo_cred_pc_id"
--                   para ser usado nma verifica��o para os CST de 60 a 66.
--
-- Em 23/12/2020 - Eduardo Linden
-- Redmine #74516 - Altera��o na rotina de gera��o do registro M100 e M500 - codigo 201
-- Para metodo de Apropria��o Direta e c�digo 201, a montagem dos registros M500 e M505 ter�o alguns campos zerados.
-- Rotina alterada: pkb_monta_dados_m500
-- Liberado para o Release 2.9.6 e os Patches 2.9.5.3 e 2.9.4.6
--
-- Em 23/11/2020 - Eduardo Linden
-- Redmine #73614 - Altera��o na rotina de gera��o do registro M100 e M500
-- Altera��o da rotina a fim de nivelar os registros para tabela mem_calc_apur_cofins e o array vt_tab_reg_m500
-- Rotina Alterada: pkb_monta_dados_m500
-- Liberado para o Release 2.9.6 e os Patches 2.9.5.2 e 2.9.4.5
--
-- Em 23/10/2020 - Renan Alves  
-- Redmine #72973 - Erro persiste 
-- Foi alterado o cursor C_VL_DED_COF/C_VL_DED_COFINS para que realize o c�lculo da matriz e filiais.
-- Rotina: PKB_CALCULA_BLOCO_1700,
--         PKB_VALIDAR_CONS_COFINS_M600
-- Patch_2.9.5.2 / Patch_2.9.4.5 / Release_2.9.6
--
-- Em 23/11/2020 - Eduardo Linden
-- Redmine #73614 - Altera��o na rotina de gera��o do registro M100 e M500
-- Altera��o da rotina a fim de nivelar os registros para tabela mem_calc_apur_cofins e o array vt_tab_reg_m500
-- Rotina Alterada: pkb_monta_dados_m500
-- Liberado para o Release 2.9.6 e os Patches 2.9.5.2 e 2.9.4.5
--
-- Em 02/10/2020     - Luis Marques - 2.9.4-5 / 2.9.5-1 / 2.9.6
-- Redmine #71597    - Duplicidades nos registros do M400/M800 com base no F100
-- Rotina Alterada   - PKB_MONTA_DADOS_M800 - Incluido no cursor "c_f100_planoconta" verifica��o atrav�s das tabelas
--                     NAT_REC_PC, COD_ST e TIPO_IMPOSTO a qual imposto se refere neste caso ao PIS.
--
-- Em 01/10/2020 - Renan Alves
-- Redmine #71983 - Erro de c�lculo no SPED Contribui��es (pk_valida_abertura_efd_pc.pkb_gera_apur_pis fase(65))
-- Foi inclu�do um NVL nas colunas que alimentam as colunas vt_mem_calc_apur_cofins.aliq_perc, vt_mem_calc_apur_cofins.aliq_prod
-- vt_mem_calc_apur_cofins.vl_imp_trib do vetor da mem�ria de c�lculo
-- Rotina: PKB_MONTA_DADOS_M500, 
--         PKB_MONTA_DADOS_M600_F,
--         PKB_MONTA_DADOS_M600_ACD, 
--         PKB_CALCULA_BLOCO_1700
-- Patch_2.9.5.1 / Patch_2.9.4.4 / Release_2.9.6
--
-- Em 04/08/2020     - Luis Marques
-- Redmine #65981    - Ajustar controle de credito de Pis e Cofins
-- Rotinas alteradas - PKB_CALCULAR_CONS_COFINS_M600 - Colocada nova vari�vel na chamada da rotina "pkb_calcula_bloco_1500"
--                     de controle de saldo que devolve valor utilizado nos registros 1500 com saldo. 
--                     PKB_CALCULA_BLOCO_1500 - Nova vari�vel para devolver total utilizado pelo(s) registros 1500 com
--                     saldo, ajustado processo de calculo para devolver o total utilizado pelos registro 1500 com saldo.
--
-- Em 20/07/2020   - Luis Marques - 2.9.3-5 / 2.9.4-2 / 2.9.5
-- Redmine #69083  - Ajuste de regra de gera��o do M400 e M800
-- Rotina alterada - PKB_MONTA_DADOS_M800 - Incluido cursor para ler registros F100 sem item s� por plano de contabil
--                   e parametrizado na tabela "PLANO_CONTA_NAT_REC_PC". 
--
-- Em 02/06/2020 - Renan Alves
-- Redmine #68016 - Erro no M400 com NCM preenchido no item da nota fiscal
-- Foi alterado a mensagem de erro dos pontos que verificam se existe conta cont�bil para a nota fiscal.
-- Rotina: pkb_monta_dados_m800   
-- Patch_2.9.3.3 / Patch_2.9.2.6 / Release_2.9.4   
--
-- Em 30/04/2020 - Eduardo Linden
-- Redmine #64368 - Erro ao gerar EFD contribui��es referente a M400/800 com F500 tributado
-- Incluir tratamento sobre gera��o do M800 para CST's '04', '06', '07', '08', '09' e '05' sobre aliquota PIS zerada
-- Rotina: pkb_monta_dados_m800
-- Disponivel para os patch's 2.9.2.5 e 2.9.3.2 e release 2.9.4
--
-- Em 13/04/20120 - Marcos Ferreira
-- Distribui��es: 2.9.2-3 / 2.9.3
-- Redmine #66751 - Erro na Gera��o do Sped Contribui��es - Mem�ria de Calculo
-- Rotina: pkb_grava_vet_mem_calc_cofins
-- Altera��es: Tratativa de campo que n�o estava sendo populado
--
-- Em 13/04/2020 - Renan Alves
-- Redmine #65928 - Erro ao gerar M400_M800 empresa Cumulativo
-- Foi inclu�do o Regime de Compet�ncia - Escritura��o detalhada, com base nos registros dos Blocos A, C, D e F (DM_IND_REG_CUM = 9)
-- no IF que verifica a escritura��o de opera��es com incid�ncia (gn_dm_cod_inc_trib in = 1 ou 3).
-- Rotina: pkb_monta_dados_m800  
-- Patch_2.9.3.1 / Release_2.9.4 
--
-- Em 03/03/2020 - Renan Alves
-- Redmine #64870 - Erro no M400/410 - M800/810 para modelo 59 (SAT) - RELATO DE BUG [200213-1200]
-- Foi implementado a gera��o do cupom fiscal sat (modelo 59).  
-- Rotina: pkb_monta_dados_m800   
-- Patch_2.9.3.1 / Release_2.9.4 
--
-- Em 26/02/20120 - Marcos Ferreira
-- Redmine #49905: - especifica��o Mem�ria de C�lculo EFD Contribui��es
-- Rotinas: PKB_MONTA_DADOS_M500
--          PKB_MONTA_DADOS_M600_F
--          PKB_MONTA_DADOS_M600_ACD
--          PKB_RET_PERCONSCONTRCOFINS
--          FKG_RET_REGISTREFDPC_ID 
--          PKB_MONTA_VET_MEM_CALC_COFINS 
--          PKB_GRAVA_VET_MEM_CALC_COFINS
--          PKB_EXCLUI_MEM_CALC_COFINS 
--          PKB_DESPR_PER_APUR_COFINS_M500
--          PKB_DESPR_PER_CONS_COFINS_M600  
-- Altera��es: Cria��o de funcionalidade para gera��o de mem�ria de calculo
--
-- Em 07/01/2020 - Eduardo Linden
-- Redmine #63309 - Feed - gera��o do M400/M800 
-- Rotina alterada: PKB_MONTA_VETOR_M800_PREGC - Ajuste para que seja feito era feita nas ativ anteriores (#61542, #61589, #62183 e #62444), e acrescentando nova function 
--                                               para obter o primeiro plano de conta a partir da conta contabil (plano_conta_nat_rec_pc).
--
-- Em 03/01/2020 - Eduardo Linden
-- Redmine #63246 - Altera��o da gera��o do M400/M800 a partir do F500/F550
-- Rotina alterada: PKB_MONTA_VETOR_M800_PREGC - Corre��o na gera��o do registro M800 a partir do registro F500/F550. 
--                                               O id do plano de conta vir� a partir da tabela plano_conta_nat_rec_pc.
--
-- Em 11/12/2019 - Eduardo Linden
-- Redmine #62444: Corre��o sobre valida��o do c�digo de plano de conta - M400/M800
-- Rotina alterada: PKB_MONTA_DADOS_M800 - Ajuste feito sobre valida��o do id do plano de conta, a fim de evitar erro ORA-06502: PL/SQL numeric or value error.
--
-- Em 09/12/2019 - Eduardo Linden
-- Redmine #62183 - Corre��o para os registros M400/800 - EFD PIS/COFINS
-- Rotina Alterada: PKB_MONTA_DADOS_M800 - Incluir valida��o sobre id do plano de conta. Se preenchido, ir� prosseguir na gera��o do registro.
--                                         Caso contr�rio, ser� gerado um log informando que plano de conta n�o � valido ou n�o est� preenchido. 
--
-- Em 03/12/2019 - Luis Marques
-- Redmine #61854 - Registro M100/M500 - Sped contribui��es
-- Rotina Alterada: PKB_MONTA_DADOS_M500 - Colocado distinct no cursor "c_d100" pois estva trazendo registro duplicado,
--                  dois registros analiticos como o mesmo CFOP.
--
-- Em 22/11/2019 - Eduardo Linden
-- Redmine #61589 - feed - M400/410 e M800/810
-- Troca de mensagem e dos ids dos planos de conta nos registros M800 e M810.
-- Rotina Alterada: PKB_MONTA_VETOR_M800_PREGC
--
-- Em 22/11/2019 - Eduardo Linden
-- Redmine #61542 - feed - N�o est� enxergando que h� parametro na nat receita
-- Troca de mensagem sobre por n�o encontrar registro na tabela PLANO_CONTA_NAT_REC_PC (pk_csf.fkg_ncmnatrecpc_npp_id)  
-- Rotina Alterada: PKB_MONTA_VETOR_M800_PREGC
--
-- Em 21/11/2019 - Eduardo Linden
-- Redmine #61496 - feed - Erro gera��o
-- Foram feitos ajustes na gera��o dos logs sobre os planos de conta n�o estar parametrizado no Regime de Caixa Escritura��o consolidada 
-- e na gera��o dos registros M400 e M800 atrav�s dos registros F500 e F550.
-- Rotinas Alteradas: PKB_MONTA_DADOS_M800 e PKB_MONTA_VETOR_M800_PREGC
--
-- Em 20/11/2019 - Eduardo Linden
-- Redmine #61429 - feed - Erro no processo
-- Inclus�o de log de erro sobre a gera�ao do M800/M810 e corre��o dos cursores de F500 e F550.
-- Rotinas corrigidas: PKB_MONTA_VETOR_M800_PREGC e PKB_MONTA_DADOS_M800 
--
-- Em 08/11/2019 - Eduardo Linden
-- Redmine #57982 - [PLSQL] Gera��o do M400/800 a partir do F500
-- Inclus�o da gera��o dos registros M800 e M810, a partir dos registros F500 e F550.
-- Altera��o na Gera��o dos registros M800 e M810, ser� considerado id do plano de conta a partir das tabelas
-- NAT_REC_PC e NCM_NAT_REC_PC
-- Rotinas Alteradas: PKB_MONTA_DADOS_M800 e PKB_MONTA_VETOR_M800.
-- Rotina Criada    : PKB_MONTA_VETOR_M800_PREGC (para regime cumulativo)
--
-- Em 05/11/2019 - Luis Marques
-- Redmine #60540 - SPED contribui��es receitas isentas M400/M410 e M800/810
-- Rotina Alterada: PKB_MONTA_DADOS_M800 - Colocada verifica��o se gera receita para n�o considerar receitas isentas.
--
-- Em 06/11/2019 - Allan Magrini
-- Redmine #60888 - Valor Contabil SAT
-- Corre��o no cursor c_c860, foi alterado o campo na busca de item_cupom_fiscal.VL_PROD
-- para item_cupom_fiscal.VL_ITEM_LIQ
-- Rotina: PKB_MONTA_DADOS_M600_ACD 
--
-- Em 22/05/2019 - Renan Alves
-- Redmine #54480 - Mais de um registro M200/M600 no mesmo arquivo.
-- Foi declarada a vari�vel VN_CH_CONC_CS_CR_ALIQ_M600 para ser utilizada na posi��o do vetor VT_TAB_REG_M600
-- pois o mesmo deve ter apenas uma posi��o, segundo o guia pr�tico.
-- Rotina: pkb_monta_vetor_m600
--
-- Em 24/04/2019 - Marcos Ferreira
-- Redmine #53749 - ERRO DE CALCULO M200/600
-- Solicita��o: Corrigir erro de Valida��o para os registros M600 quando utilizado quantidade na base de calculo do Cofins
-- Altera��es: Inclus�o de Calculo para vl_cont_apur quando utilizado quantidade na base de calculo de Cofins
-- Procedures Alteradas: PKB_CALCULAR_CONS_COFINS_M600
--
-- Em 05/04/2019 - Renan Alves
-- Redmine #53146 - Erro ao Gerar EFD Contribui��es.
-- Foi inclu�do mais um REPLACE, removendo o "-", "/", "\" do par�metro COD_CTA na chamada da PKB_MONTA_VETOR_M800
-- Rotina: pkb_monta_dados_m800 
--
-- Em 20/03/2019 - Renan Alves 
-- Redmine #51130 - Sped Contribui��es - Regime Cumulativo.
-- Foram inclu�dos os novos c�digos '03' e '05' na natureza da pessoa jur�dica (gv_dm_ind_nat_pj).
-- Rotinas: pkb_monta_dados_m600_f e pkb_monta_dados_m600_acd
--
-- Em 15/03/2019 - Angela In�s.
-- Redmine #52518 - Ajuste nos valores de Apura��o do PIS e da COFINS - Blocos M105 e M505.
-- Ap�s recuperar os valores dos documentos fiscais para gera��o das Apura��es de PIS e COFINS, verificar se o valor no detalhe dos Blocos M105 e M505, est�o de
-- acordo com os valores apurados na Receita Bruta - Registro 0111.
-- M505 - VL_BC_PIS_CUM = (m505.vl_bc_pis_tot * 0111.rec_bru_cum / 0111.rec_bru_total)
-- M505 - VL_BC_PIS_NC = (m505.vl_bc_pis_tot - m505.vl_bc_pis_cum)
-- A toler�ncia utilizada para refazer o c�lculo � de at� 0,50. Caso a diferen�a seja maior que 0,50, o processo n�o far� altera��o e a diferen�a ir� continuar
-- aparecendo na valida��o do PVA.
-- Rotina: pkb_grava_dados_m500.
--
-- Em 11/03/2019 - Angela In�s.
-- Redmine #52217 - Performance - Processo de Gera��o de Dados do Sped EFD-Contribui��es.
-- Eliminar os coment�rios devido as mudan�as nos c�digos.
-- Rotinas: pkb_monta_dados_m500, pkb_dados_per_apur_cofins_m500, pkb_monta_dados_m600_f, pkb_monta_dados_m600_acd, pkb_dados_per_cons_cofins_m600,
-- pkb_monta_dados_m800, e pkb_dados_per_rec_cofins_m800.
--
-- Em 08/03/2019 - Angela In�s.
-- Redmine #52217 - Performance - Processo de Gera��o de Dados do Sped EFD-Contribui��es.
-- 1) Verificar os processos de gera��o dos dados para o arquivo do Sped EFD-Contribui��es: utiliza��o do comando TRUNC em datas e Fun��es utilizadas nos
-- comandos SELECT.
-- 2) Verificar os processos de valida��o dos dados para o arquivo do Sped EFD-Contribui��es: utiliza��o do comando TRUNC em datas e Fun��es utilizadas nos
-- comandos SELECT.
-- Rotinas: pkb_monta_dados_m500, pkb_dados_per_apur_cofins_m500, pkb_monta_dados_m600_f, pkb_monta_dados_m600_acd, pkb_dados_per_cons_cofins_m600,
-- pkb_monta_dados_m800, e pkb_dados_per_rec_cofins_m800.
--
-- Em 08/03/2019 - Renan Alves
-- Redmine #52219 - Erro ao calcular per�odo - SPED Contribui��es
-- Foi inclu�do mais um REPLACE, removendo o espa�o do par�metro COD_CTA na chamada da PKB_MONTA_VETOR_M800
-- Rotina: pkb_monta_dados_m800
--
-- Em 13/02/2019 - Marcos Ferreira
-- Redmine #51462 - Altera��es PLSQL para atender layout 005 (vig�ncia 01/2019)
-- Altera��es: 1) PKB_CALCULAR_CONS_COFINS_M600: Cria��o de Vari�veis para o controle de Ajustes
--             2) Criado Cursor c_vl_ajus_acres_bc_cofins para buscar valores de ajuste da Base de Calculo
--             3) Alterado Update da tabela det_cons_contr_cofins com inclus�o de novos campos do ajuste da Base de Calculo
--
-- Em 03/12/2018 - Angela In�s.
-- Redmine #49297 - Especifica��o para gera��o do registro D200.
-- 1) Apura��o de COFINS - Bloco M500.
-- Considerar para apura��o somente os conhecimentos de transporte cuja opera��o seja "Entrada" (conhec_transp.dm_ind_oper=0), podendo ser de "Emiss�o Pr�pria"
-- ou de "Terceiro" (conhec_transp.dm_ind_emit=0/=1). Os modelos fiscais "63-Bilhete de Passagem Eletr�nico � BP-e" e "67-Conhecimento de Transporte Eletr�nico -
-- Outros Servi�os", passam a ser recuperados.
-- Rotina: pkb_monta_dados_m500.
-- 2) Consolida��o de COFINS - Bloco M600.
-- Considerar para consolida��o os conhecimentos de transporte autorizados (conhec_transp.dm_st_proc=4), n�o seja de armazenamento (conhec_transp.dm_arm_nf_terc=0),
-- opera��o de "Sa�da" (conhec_transp.dm_ind_oper=1), e emiss�o seja de "Emiss�o Pr�pria" (conhec_transp.dm_ind_emit=0). Para os modelos fiscais, considerar: "07-
-- Nota Fiscal de Servi�o de Transporte", "08-Conhecimento de Transporte Rodovi�rio de Cargas", "8B-Conhecimento de Transporte de Cargas Avulso", "09-Conhecimento
-- de Transporte Aquavi�rio de Cargas", "10-Conhecimento A�reo", "11-Conhecimento de Transporte Ferrovi�rio de Cargas", "26-Conhecimento de Transporte Multimodal
-- de Cargas", "27-Nota Fiscal De Transporte Ferrovi�rio De Carga", "57-Conhecimento de Transporte Eletr�nico", "63-Bilhete de Passagem Eletr�nico � BP-e" e "67-
-- Conhecimento de Transporte Eletr�nico - Outros Servi�os". Considerar os conhecimentos que possuem Impostos PIS e/ou COFINS com as CSTs: "01-Opera��o Tribut�vel
-- (base de c�lculo = valor da opera��o al�quota normal (cumulativo/n�o cumulativo))", "02-Opera��o Tribut�vel (base de c�lculo = valor da opera��o (al�quota
-- diferenciada))", "03-Opera��o Tribut�vel (base de c�lculo = quantidade vendida x al�quota por unidade de produto)", "05-Opera��o Tribut�vel (substitui��o
-- tribut�ria)".
-- Rotina: pkb_monta_dados_m600_acd.
--
-- Em 14/11/2018 - Angela In�s.
-- Redmine #48717 - Apura��o do PIS e da COFINS - Bloco M100 e M500.
-- Considerar a Empresa Matriz para apura��o do PIS e da COFINS, ao recuperar atrav�s do CFOP, a base de c�lculo de cr�dito. O processo est� considerando a
-- empresa vinculada aos documentos fiscais, que pode ser a matriz ou suas filiais, e o cadastro est� vinculado somente as empresas matrizes.
-- Rotina: pkb_monta_dados_m500.
--
-- Em 13/11/2018 - Angela In�s.
-- Redmine #48693 - Corre��o na gera��o do Bloco M100 - Vari�vel Array - �ndice.
-- Alterar o �ndice que armazena os valores dos Blocos M100 e M500, para tipo caracter.
-- O processo armazena com o tipo num�rico, e devido ao tamanho, quantidade de n�meros para gerar o �ndice, o processo t�cnico n�o aceita, devendo ser alterado
-- para tipo caracter, com tamanho de 20 posi��es.
-- Vari�vel/array: vt_tab_reg_m500.
--
-- Em 31/10/2018 - Angela In�s.
-- Redmine #48321 - Inclus�o do processo de F600 em gera��o do 1300 e/ou 1700.
-- Na gera��o do c�lculo dos Blocos 1300 para PIS e 1700 para COFINS, considerar os valores da Contribui��o Retida na Fonte - Bloco F600, que foram integrados
-- atrav�s de View de Integra��o, onde a situa��o do registro � "7-Integra��o por view de banco de dados".
-- Rotina: pkb_calcula_bloco_1700.
--
-- Em 29/10/2018 - Eduardo Linden
-- Redmine #48152 - Tabela de Opera��es Geradoras de Cr�dito de PIS/COFINS - Incluir Identificador da Empresa.
-- Inclus�o da coluna empresa_id da tabela oper_ger_cred_pc nas clausulas dos cursores c_c100 e c_c100_ee.
-- Rotina: PKB_MONTA_DADOS_M500.
--
-- Em 17/08/2018 - Angela In�s.
-- Redmine #46140 - Processos de Apura��o e Gera��o do Sped EFD-Contribui��es.
-- 1) Incluir as NF Mercantil de modelo 55, com CFOP vinculado a Energia El�trica, nas apura��es de PIS e COFINS - Blocos M100 e M500.
-- 2) Considerar o par�metro de Gerar Escritura��o como Sim, para fazer a apura��o dos Blocos M100 e M500.
-- Rotina: pkb_monta_dados_m500.
--
-- Em 13/08/2018 - Angela In�s.
-- Redmine #45912 - Agrupamento para apura��o dos Blocos M400 e M800 - Plano de Contas.
-- Utilizar o C�digo do Plano de Conta para fazer o agrupamento, e n�o mais o identificador do plano de conta. Fazer a corre��o para PIS e COFINS.
-- Vari�vel Global: vt_tab_reg_m800.
-- Rotina: pkb_monta_dados_m800.
--
-- Em 24/07/2018 - Angela In�s.
-- Redmine #45284 - Corre��o na Apura��o de PIS e COFINS - Blocos 1300 e 1700.
-- A) Os valores a serem lan�ados no arquivo dos registros do Bloco 1300 e 1700, ser�o do m�s corrente, do m�s da abertura do arquivo.
-- B) Verificar o processo da Consolida��o para gera��o autom�tica dos Blocos 1300 e 1700.
--
-- Em 06/07/2018 - Karina de Paula
-- Redmine #44759 - Melhoria Apura��o PIS/COFINS - Bloco F100
-- Rotina Alterada: PKB_MONTA_DADOS_M500 / PKB_MONTA_DADOS_M600_F / PKB_MONTA_DADOS_M800 => Retirada a verifica��o dm_gera_receita
--
-- Em 29/06/2018 - Angela In�s.
-- Redmine #44515 - Processo do Sped EFD-Contribui��es: C�lculo, Valida��o e Gera��o do Arquivo.
-- Revisar todos os processos de C�lculo, Valida��o e Gera��o do Arquivo Sped EFD-Contribui��es.
-- Rotinas: pkb_monta_dados_m600_acd e pkb_monta_dados_m800.
--
-- Em 24/04/2018 - Karina de Paula
-- Redmine #41878 - Novo processo para o registro Bloco F100 - Demais Documentos e Opera��es Geradoras de Contribui��es e Cr�ditos.
-- Inclu�da a verifica��o do campo dm_gera_receita = 1, nos objetos abaixo:
-- -- Rotina Alterada: PKB_MONTA_DADOS_M500   - Alterado o select do cursor c_f100
-- -- Rotina Alterada: PKB_MONTA_DADOS_M600_F - Alterado o select do cursor c_f100
-- -- Rotina Alterada: PKB_MONTA_DADOS_M800   - Alterado o select do cursor c_f100 / no select q conta a qtd N�o validados - COFINS / Sem item e sem ncm - COFINS
--
-- Em 16/04/2018 - Marcos Ferreira.
-- Redmine: #41435 - Processos - Cria��o de Par�metros CST de PIS e COFINS para Gera��o e Apura��o do EFD-Contribui��es.
-- Alterado Procedure PKB_MONTA_DADOS_M800, inclu�do parametros de cst na chamada da fun��o fkg_gera_escr_efdpc_cfop_empr
-- dos cursores
-- Em 11/04/2018 - Marcos Ferreira.
-- Redmine: #41435 - Processos - Cria��o de Par�metros CST de PIS e COFINS para Gera��o e Apura��o do EFD-Contribui��es.
-- Alterado a Procedure PKB_MONTA_DADOS_M200_ACD:
--   1) Inclu�do campo cst.id cst_id_pis no cursor c_a100_aj
--   2) Inclu�do campo cst.id cst_id_pis no cursor c_c100_aj
--   3) Inclu�do campo cst.id cst_id_pis no cursor c_c400_aj
--   4) Inclu�do campo cst.id cst_id_pis no cursor c_c380_aj
--   5) Inclu�do campo cst.id cst_id_pis no cursor c_c860_aj
--   6) Inclu�do campo cst.id cst_id_pis no cursor c_d600_aj
--   7) Modificado a estrutura de par�metros do if da vn_fase := 3.1;
--   8) Modificado a estrutura de par�metros do if da vn_fase := 6.1;
--   9) Modificado a estrutura de par�metros do if da vn_fase := 9.1;
--  10) Modificado a estrutura de par�metros do if da vn_fase := 12.1;
--  11) Modificado a estrutura de par�metros do if da vn_fase := 15.1;
--  12) Modificado a estrutura de par�metros do if da vn_fase := 18.1;
--
-- Em 29/09/2017 - Angela In�s.
-- Redmine #35139 - Corre��o na Apura��o do PIS e da COFINS - Valores da Receita Bruta.
-- Na recupera��o dos dados da abertura, para apura��o do PIS e da COFINS - Blocos M100/M500, corrigir a compara��o do per�odo, data inicial e final,
-- com o per�odo da apura��o. Quando houver abertura dos registros Original e Retifica��o, iremos recuperar o registro que n�o tenha arquivo gerado (dm_situacao
-- difere de 1-erro de valida��o, 3-gerado arquivo, 4-Erro na gera��o do arquivo, 5-Erro de c�lculo, 7-Em gera��o).
-- Rotina: pkb_dados_abert_empr.
--
-- Em 18/09/2017 - Marcelo Ono.
-- Redmine #32616 - Corre��o nas mensagens de logs do bloco M500.
-- Alterado a fun��o TO_DATE pelo TO_CHAR nas mensagens de log do bloco M500.
-- Rotinas: pkb_monta_dados_m500
--
-- Em 30/08/2017 - Angela In�s.
-- Redmine #34186 - Corre��o na gera��o da consolida��o do Bloco M200/M600 com apropria��o de cr�dito do Bloco 1100/1500.
-- 1) A gera��o do M�s 05/2014 n�o gerou apura��o de valores M100, por isso n�o foi poss�vel recuperar os valores para utiliza��o dos cr�ditos do Bloco 1100.
-- Utilizamos o tipo de cr�dito do M100 para recuperar o mesmo tipo de cr�dito do 1100.
-- Corre��o: Corrigir a recupera��o do valores de cr�ditos do Bloco 1100/1500, sem considerar a apura��o do Bloco M100/M500. Ordenar do mais antigo para o mais
-- recente (ano/mes), e em seguida pelo tipo de cr�dito.
-- 2) Corrigir o processo de recupera��o dos valores de cr�dito do 1100/1500, considerando somente os valores que foram utilizados para o per�odo em quest�o para
-- comp�r o valor do cr�dito descontado de per�odo anterior.
-- Rotinas: pkb_calcular_cons_cofins_m600 e pkb_calcula_bloco_1500.
--
-- Em 28/08/2017 - Angela In�s.
-- Redmine #34082 - Corre��o na Consolida��o - Blocos M200 e M600, e arquivo Sped EFD - Valores de Cr�dito dos Blocos 1100 e 1500.
-- Alterar nos processos da Consolida��o do PIS e da COFINS:
-- 1) Valores de cr�dito utilizados dos Blocos 1100/1500.
-- 2) Exclus�o de dados.
-- 3) Desprocessamento da consolida��o.
-- Rotinas: pkb_calcula_bloco_1500, pkb_excl_per_cons_cofins_m600 e pkb_desproc_cons_cofins_m600.
--
-- Em 23/05/2017 - Angela In�s.
-- Redmine #31360 - Processo de Consolida��o do M200/M600 - Recupera��o dos valores do Bloco F600.
-- Considerar os registros do Bloco F600, com situa��o de integra��o sendo 0-Indefinido (que seriam os digitados), e 10-Gerado por Impostos Retidos sobre
-- Receita. Ao recuperar os valores de reten��o, considerar o valor reten��o de pis/cofins do Imposto retido quando a situa��o de integra��o for 10-Gerado por
-- Impostos Retidos sobre Receita; e, considerar o valor de reten��o de pis/cofins do pr�prio registro com situa��o de integra��o 0-Indefinido.
-- Rotina: pkb_calcular_cons_cofins_m600, cursores c_vl_ret_apu e c_vl_imp_cofins.
--
-- Em 19/04/2017 - Angela In�s.
-- Redmine #30373 - Alterar o processo de valida��o - Bloco M200/M600 - Valor retido na fonte deduzido no per�odo - n�o-cumulativo e cumulativo.
-- 1) Para Bloco M200: Al�m dos valores recuperados do Bloco F600, recuperar tamb�m os valores do Bloco 1300, n�o-cumulativo e cumulativo.
-- 2) Para Bloco M600: Al�m dos valores recuperados do Bloco F600, recuperar tamb�m os valores do Bloco 1700, n�o-cumulativo e cumulativo.
-- Rotina: pkb_validar_cons_cofins_m600 - cursores: c_vl_ret_apu_nc e c_vl_ret_apu_cum.
--
-- Em 17/04/2017 - Angela In�s.
-- Redmine #30237 - Recuperar os valores dos Registros 1300 (PIS), e 1700 (COFINS) - Composi��o dos valores retidos em fonte deduzidos no per�odo - Cumulativo e
-- N�o-Cumulativo - Bloco M200/M600.
-- A) Para montar o valor do campo CONS_CONTR_COFINS.VL_RET_NC - Bloco M600 - Valor Retido na Fonte Deduzido no Periodo N�o-Cumulativo.
-- B) Para montar o valor do campo CONS_CONTR_COFINS.VL_RET_CUM - Bloco M600 - Valor Retido na Fonte Deduzido no Per�odo Cumulativo.
-- Utilizar os valores dos registros dos Blocos F600 e 1700.
-- Rotina: pkb_calcular_cons_cofins_m600 - cursor c_vl_ret_apu.
--
-- Em 22/12/2016 - Angela In�s.
-- Redmine #26515 - Corre��o no processo de consolida��o - Blocos M200/M600 e Blocos 1100/1500.
-- No processo de c�lculo da consolida��o: N�o gerar valores para utiliza��o futura no Bloco 1100/1500 quando houver saldo na consolida��o do Bloco M200/M600.
-- Somente gerar valores para utiliza��o futura no Bloco 1100/1500 quando houver saldo na apura��o do Bloco M100/M500.
-- Rotina: pkb_calcula_bloco_1500.
--
-- Em 20/12/2016 - Angela In�s.
-- Redmine #8147 - Bloco M. Processo da Apura��o da COFINS.
-- Implementar no processo da apura��o da COFINS os novos registros M515 e M625, descritos no Bloco M do Guia Pr�tico da EFD Contribui��es.
-- Rotinas: pkb_excl_per_apur_cofins_m500, pkb_calcular_apur_cofins_m500, pkb_validar_apur_cofins_m500, pkb_grava_dados_m600, pkb_excl_per_cons_pis_m600,
-- pkb_calcular_cons_cofins_m600, pkb_validar_cons_cofins_m600
--
-- Em 09/12/2016 - Angela In�s.
-- Redmine #26165 - Gera��o dos Blocos M200/M600 - Saldos utilizados nos Blocos M100/M500.
-- Considerar os c�digos de tipo de cr�dito gerados na apura��o de pis/cofins (m100/m500), ordenados pela ordem crescente de c�digos, para serem utilizados na
-- consolida��o de pis/cofins (m200/m600). Hoje o processo ordena pelo primeiro d�gito do c�digo.
-- Rotina: pkb_calcular_cons_cofins_m600.
--
-- Em 05/12/2016 - Angela In�s.
-- Redmine #26007 - Gerar o valor do saldo apurado - Bloco M100/M500, quando maior que zero(0), como cr�dito futuro em Bloco 1100/1500.
-- Rotinas: pkb_exclui_bloco_1500_m500, pkb_gera_bloco_1500_m500, pkb_calcula_bloco_1500 e pkb_calcular_cons_cofins_m600.
--
-- Em 30/11/2016 - Angela In�s.
-- Redmine #25896 - Corre��o na gera��o dos valores de consolida��o - Bloco M200/M600, relacionado aos valores dos controles de cr�ditos fiscais do Bloco 1100/1500.
-- Rotinas: pkb_calcula_bloco_1500 e pkb_calcular_cons_cofins_m600.
--
-- Em 22/11/2016 - Angela In�s.
-- Redmine #25627 - Gera��o autom�tica dos Blocos 1100/1500 atrav�s da Consolida��o dos Blocos M200/M600.
-- Gerar as informa��es do Bloco 1100/1500 atrav�s do c�lculo dos Blocos M200/M600, somente se n�o houver lan�amento com saldo nos meses anteriores dos Blocos
-- 1100/1500. Gerar o saldo n�o atendido pelos lan�amentos dos Blocos 1100/1500, para utiliza��es futuras, ou seja, para os meses posteriores.
-- Rotina: pkb_calcula_bloco_1500.
--
-- Em 17/11/2016 - Angela In�s.
-- Redmine #25444 - Processo de PIS e COFINS - Gera��o Geral.
-- Adaptar os processos de PIS e COFINS de acordo com manual do Sped EFD-Contribui��es e Programa Validador do Governo, para atender aos Regime de Caixa
-- Escritura��o consolidada (Registro F500), Regime de Compet�ncia - Escritura��o consolidada (Registro F550), e Regime de Compet�ncia - Escritura��o detalhada,
-- com base nos registros dos Blocos A, C, D e F.
--
-- Em 19/10/2016 - Angela In�s.
-- Redmine #24520 - Corre��o na gera��o da consolida��o de PIS e COFINS - Blocos 1100 e 1500.
-- No c�lculo do Bloco 1100 e 1500, considerar somente os valores de saldo de cr�dito dispon�vel das apura��es M100 e M500.
-- Rotina: pkb_calcula_bloco_1500.
--
-- Em 10/10/2016 - Angela In�s.
-- Redmine #24269 - Corre��o na gera��o da consolida��o de PIS e COFINS - Blocos 1100 e 1500.
-- Refazer a recupera��o dos valores dos Blocos 1100 e 1500 para comp�r os valores da consolida��o dos Blocos M200 e M600.
-- Quando for utilizar parte do valor do bloco 1100/1500, gerar outra linha no bloco 1100/1500 com o valor a utilizar, e subtrair do registro digitado o valor
-- parcial utilizado.
-- Rotina: pkb_calcular_cons_pis_m600.
--
-- Em 05/10/2016 - Angela In�s.
-- Redmine #22803 - NFE de energia el�trica informada no reg. C500.
-- N�o considerar as Notas Fiscais de Modelo 55, com itens de CFOP vinculados ao tipo de opera��o 4-Energia El�trica, para comp�r os valores da apura��o do
-- pis e da cofins - Blocos M100 e M500.
-- Rotina: pkb_monta_dados_m500.
--
-- Em 26/09/2016 - Angela In�s.
-- Redmine #23791 - Corre��o nas apura��es de PIS e COFINS e gera��o do arquivo Sped EFD-Contribui��es.
-- Considerar os registros com data anterior ao per�odo em quest�o e de origem digita��o.
-- Rotina: pkb_calcular_cons_cofins_m600/cursor c_vl_cred_desc.
-- Revisar os processos considerando o c�lculo somente se houver registros do Bloco 1500 com saldo para serem utilizados.
-- Rotina: pkb_calcular_bloco_1500.
--
-- Em 21/09/2016 - Angela In�s.
-- Redmine #23644 - Processo de Exclus�o dos Blocos M200/M600 e Desprocesssamento dos Blocos M100/M500.
-- 1) Processo de desprocessar por apura��o - Bloco M500. Verificar se existem relacionamentos gerados pelo Bloco M600, entre os Blocos M500 e 1500, e n�o
-- permitir o desprocessar. Rotina: pkb_despr_apur_cofins_m500.
-- 2) Processo de excluir a consolida��o por per�odo - Bloco M600. Excluir/Alterar os relacionamentos entre os Blocos M500 e 1500. Rotina: pkb_excl_per_cons_cofins_m600.
--
-- Em 14/07/2016 - Angela In�s.
-- Redmine #21324 - Corre��o na Gera��o dos Blocos 1100/1500 e Gera��o do Arquivo.
-- Na apura��o do cr�dito, Blocos M100/M500, considerar o valor do cr�dito descontado na gera��o do Bloco 1100/1500, quando o saldo de cr�dito dispon�vel
-- estiver zerado.
-- Rotina: pkb_calcula_bloco_1500.
--
-- Em 12/07/2016 - Angela In�s.
-- Redmine #21255 - Corre��o na gera��o do Bloco 1100/1500 autom�tico pelos Blocos M200/M600 e Gera��o do Arquivo.
-- Gera��o do Bloco 1100/1500 autom�tico pelos Blocos M200/M600:
-- Considerar os valores a ser utilizados no bloco 1100/1500 somando o saldo que estiver no mesmo m�s.
-- Rotina: pkb_calcula_bloco_1500.
--
-- Em 01/07/2016 - Angela In�s.
-- Redmine #20872 - Gera��o do Arquivo Sped EFD-Contribui��es. Blocos 1100/1500.
-- No c�lculo do Bloco M600, recuperar o valor de cr�dito descontado no Bloco 1500 (contr_cred_fiscal_cofins.vl_cred_desc_efd), caso seja maior que zero, de
-- per�odos anteriores at� o per�odo em quest�o. Utilizar os valores at� que o saldo fique zerado ou maior que zero (cons_contr_cofins.vl_tot_cred_desc_ant).
-- Alterar o registro do Bloco 1500 com o identificador do Bloco M600 (contr_cred_fiscal_cofins.conscontrcofins_id).
-- Rotinas: pkb_calcular_cons_pis_m600, pkb_excl_per_cons_cofins_m600 e pkb_despr_per_cons_cofins_m600.
--
-- Em 30/06/2016 - Angela In�s.
-- Redmine #20737 - Processo de PIS e COFINS - Gera��o autom�tica do Bloco 1100/1500.
-- Inclus�o do processo para gerar registros de controle de cr�ditos fiscais - bloco 1500.
-- Rotina: pkb_calcular_cons_pis_m600/pkb_calcula_bloco_1500.
-- Inclus�o das novas tabelas para excluir os registros e desfazer os processos.
-- Rotinas: pkb_excl_per_cons_cofins_m600 e pkb_despr_per_cons_cofins_m600.
-- Redmine #20812 - Processo de PIS e COFINS - Gera��o do Bloco M100/M500.
-- Inclus�o das novas tabelas para excluir os registros e desfazer os processos.
-- Rotinas: pkb_excl_per_apur_cofins_m500 e pkb_despr_per_apur_cofins_m500.
--
-- Em 12/05/2016 - Angela In�s.
-- Redmine #18819 - Corre��o na gera��o do SPED EFD-Contribui��es - Bloco M200 e M600.
-- Apura��o da COFINS: Considerar a montagem do registro M610 quando o documento fiscal s� possui informa��es que geram apenas ajustes - bloco M620.
-- Rotina: pkb_monta_vetor_m620.
--
-- Em 03/05/2016 - Angela In�s.
-- Redmine #18448 - Corre��o na gera��o do EFD-Contribui��es - Blocos M200 e M600.
-- 1) Excluir somente os registros gerados automaticamente do Bloco M605 (cons_contr_cofins_or.dm_origem=1).
-- Rotina: pkb_excl_per_cons_cofins_m600.
-- 2) Somar os valores Digitados do bloco M605 - Contribui��o para o COFINS a Recolher, para comp�r os valores da contribui��o n�o-cumulativa e cumulativa a recolher
-- e o total da contribui��o a recolher.
-- Rotina: pkb_calcular_cons_cofins_m600.
--
-- Em 15/04/2016 - Angela In�s.
-- Redmine #17699 - Corre��o na gera��o do arquivo Sped-EFD, Apura��o do PIS e Apura��o da COFINS.
-- Recupera��o das notas fiscais de modelo '21' e '22' para a consolida��o - Bloco M600.
-- Rotina: pkb_monta_dados_m600.
--
-- Em 07/04/2016 - Angela In�s.
-- Redmine #17136 - Corre��o na gera��o dos blocos D500 e D600 - Notas Fiscais de Comunica��o - Sped EFD-Contribui��es.
-- Considerar para o cursor c_d500, somente as notas fiscais de ENTRADA de modelos '21' e '22' - Servi�o Cont�nuo de Comunica��o.
-- Rotina: pkb_monta_dados_m500.
--
-- Em 04/03/2016 - F�bio Tavares
-- Redmine #8096 - Processo de Apura��o do COFINS � Blocos M, Implementar as mudan�as de acordo com o Sped para recupera��o dados da Apura��o das Opera��es
-- das Institui��es Financeiras, Seguradoras, Entidades de Previd�ncia Privada, Operadoras de Planos de Assist�ncia � Sa�de e demais Pessoas Jur�dicas.
-- Rotina: pkb_monta_dados_m800.
--
-- Em 28/10/2015 - Angela In�s.
-- Redmine #12470 - Verificar/Alterar o processo de gera��o do Bloco M610 - Sped EFD-Contribui��es.
-- Fazer a corre��o necess�ria para atender os registros do Cupom Fiscal Eletr�nico (CFe/SAT), de acordo com o arquivo do Sped EFD:
-- REGISTRO C870: RESUMO DI�RIO DE DOCUMENTOS EMITIDOS POR EQUIPAMENTO SAT-CF-E (C�DIGO 59) � PIS/PASEP E COFINS
-- REGISTRO C880: RESUMO DI�RIO DE DOCUMENTOS EMITIDOS POR EQUIPAMENTO SAT-CF-E (C�DIGO 59) � PIS/PASEP E COFINS APURADO POR UNIDADE DE MEDIDA DE PRODUTO
-- Os valores escriturados nos campos de bases de c�lculo 07 (VL_BC_PIS) e 11 (VL_BC_COFINS) correspondentes a itens vendidos com CST representativos de receitas
-- tributadas, ser�o recuperados no Bloco M, para a demonstra��o das bases de c�lculo do PIS/Pasep e da Cofins, nos Campos �VL_BC_CONT� dos registros M210 e M610,
-- respectivamente.
-- Rotina: pkb_monta_dados_m600.
--
-- Em 22/09/2015 - Angela In�s.
-- Redmine #11794 - Gera��o dos Blocos M100 e M500 - PIS/COFINS.
-- Ao recuperar os valores da apura��o de pis e cofins - bloco m100 e m500, n�o considerar as notas fiscais de modelo '55' e os itens que possuem a CFOP 1252.
-- Rotina: pkb_monta_dados_m500 - cursor c_c100.
-- Redmine #11795 - Gera��o dos Blocos M200 e M600 - PIS/COFINS.
-- Ao recuperar os valores dos Bloco 1100 e 1500, para consolida��o da contribui��o - Blocos M200 e M600, considerar os valores de todos os meses anteriores
-- ao do c�lculo em quest�o. O processo recuperava os valores do m�s do c�lculo.
-- Rotinas: pkb_calcular_cons_cofins_m600 e pkb_validar_cons_cofins_m600 - cursor c_vl_cred_desc.
--
-- Em 27/07 e 13/08/2015 - Angela In�s.
-- Redmine #10117 - Escritura��o de documentos fiscais - Processos.
-- Inclus�o do novo conceito de recupera��o de data dos documentos fiscais para retorno dos registros.
--
-- Em 08/07/2015 - Angela In�s.
-- Redmine #9934 - Corre��o no Ajuste autom�tico Blocos M210 e M610.
-- Corre��o: O processo n�o estava executando o cursor correto para recupera��o das notas fiscais mercantis. Houve um erro de desenvolvimento na chamada do processo.
-- Essa corre��o dever� ser efetuada nas vers�es 265, 266, 267 e 268; e, alterar o FTP nas vers�es 265 e 266.
-- Rotina: pkb_monta_dados_m600, cursor de: c_a100_aj para: c_c100_aj.
--
-- Em 09-11/06/2015 - Angela In�s.
-- Redmine #9024 - Apura��o autom�tica dos ajustes dos Blocos M200 e M600 - Sped EFD-Contribui��es.
-- 1) Ao calcular os valores de ajuste dever�amos recuperar as notas fiscais com cfop de entrada (1,2,3), com os par�metros gera_receita=0-n�o / gera_escr=0-n�o /
--    ajuste_m210=1-sim, e de acordo com as al�quotas comparar na tabela do COD_CONTR, em qual c�digo ser� relacionado o valor, e armazenar em VL_AJUS_REDUC,
--    somando os valores tributados de PIS (m200) e COFINS (m600).
-- 2) Para essas notas fiscais com cfop de entrada (1,2,3), e todos os itens citados acima, verificar se o CST for 75, armazenar no c�digo de situa��o tribut�ria
--    (31 ou 32-SUFRAMA).
-- 3) Ao calcular os valores de ajuste dever�amos recuperar as notas fiscais com cfop de sa�da (5,6,7), com os par�metros gera_receita=0-n�o / gera_escr=0-n�o /
--    ajuste_m210=1-sim, e de acordo com as al�quotas comparar na tabela do COD_CONTR, em qual c�digo ser� relacionado o valor, e armazenar em VL_AJUS_ACRES,
--    somando os valores tributados de PIS (m200) e COFINS (m600).
-- 4) Para ambos os casos, considerar valores cumulativos e n�o-cumulativos, considerar as al�quotas, e se for al�quota diferenciada, considerar o campo
--    relacionado na abertura do arquivo que indica se � cumulativo ou n�o-cumulativo, se o regime for cumulativo e n�o-cumulativo, armazenar nos c�digos que
--    forem n�o-cumulativos.
-- 5) Recuperar em pkb_dados_abert_empr, o indicador da atividade abertura_efd_pc.dm_ind_ativ, para identificar se a abertura � de atividade imobili�ria.
-- Rotinas: pkb_monta_dados_m200, pkb_monta_vetor_m200 e pkb_monta_vetor_m220.
--
-- Em 19/05/2015 - Angela In�s.
-- Redmine #8519 - Sped contribui��es M205/M605
-- Atualizar a gera��o dos pagamentos autom�ticos - Bloco M200/M205 e Bloco M600/M605.
-- Informar o n�mero do campo do registro �M200�: Campo 08-contribui��o n�o-cumulativa ou Campo 12-contribui��o cumulativa.
-- Rotina: pkb_calcular_cons_cofins_m600 e pkb_validar_cons_cofins_m600.
--
-- Em 26/02/2015 - Angela In�s.
-- Redmine #6583 - Erro na gera��o do bloco M400 - Rotina Program�vel.
-- Incluir o par�metro de entrada MULTORG_ID nas rotinas que utilizam a fun��o pk_csf_efd_pc.fkg_nat_rec_pc_id.
--
-- Em 22/01/2015 - Angela In�s.
-- Redmine #5972 - EFD Contribui��es - pagtos autom�ticos - Altera��es nos processos de apura��o.
-- Alterar os processos para as novas colunas:
-- Diferenciar nos processos os par�metros de acordo com os valores a serem gerados - valor cumulativo e/ou valor n�o-cumulativo.
-- Rotina: pkb_calcular_cons_cofins_m600.
--
-- Em 21/01/2015 - Angela In�s.
-- Redmine #5873 - Os blocos M300 e M700 est�o excluindo o registro mesmo o EFD fechado.
-- Rotina: pkb_excluir_contr_cofins_m700.
--
-- Em 12/01/2015 - Angela In�s.
-- Redmine #5799 - Erro na tela ao excluir bloco M com o per�odo fechado.
-- Rotinas: pkb_excl_per_apur_cofins_m500, pkb_excl_per_cons_cofins_m600 e pkb_excl_per_rec_cofins_m800.
--
-- Em 06/01/2015 - Angela In�s.
-- Redmine #5616 - Adequa��o dos objetos que utilizam dos novos conceitos de Mult-Org.
--
-- Em 26/12/2014 - Angela In�s.
-- Redmine #5622 - Gera��o dos Blocos M200 e M600 com os valores do Bloco F700.
-- Corre��o: Considerar o valor de dedu��o de COFINS do Bloco F700, quando n�o houver impostos retidos para serem deduzidos.
-- Rotina: pkb_calcular_cons_cofins_m600.
--
-- Em 05/12/2014 - Angela In�s.
-- Redmine #5355 - Diferen�a na soma das receitas isentas nos blocos M800 e M400, no SPED contribui��es.
-- Corre��o: N�o somar o valor do imposto IPI tributado ao valor do item bruto, para comp�r o valor da receita.
-- Rotina: pkb_monta_dados_m800.
--
-- Em 26/11/2014 - Angela In�s.
-- Redmine #5002/#4591 - EFD contribui��es est� validado, mas est� deixando incluir registro novo, processar e excluir.
-- Confer�ncia dos blocos M/PIS.
-- 1) Processos M500/M600/M700/M800: N�o permitir c�lculo/valida��o/exclus�o do Per�odo de Apura��o se houver Arquivo gerado ou validado.
-- 2) Processos M500/M600/M700/M800: N�o permitir c�lculo/valida��o/exclus�o da Apura��o se houver Arquivo gerado ou validado.
--
-- Em 22/10/2014 - Angela In�s.
-- Redmine #4878 - Corre��o no c�lculo do Bloco M600 - Consolida��o da Contribui��o do COFINS.
-- Totalizar os valores gerados no rateio relacionados aos campos: Valor de Reten��o N�o-Cumulativo e Valor de Outras Dedu��es.
-- Rotina: pkb_calcular_cons_cofins_m600.
--
-- Em 13/10/2014 - Angela In�s.
-- Redmine #4725 - C�lc. Consol. da Contribui��o do COFINS - Bloco M600 - C�lculo.
-- Corre��o no processo para gera��o dos dados do Registro M605: Contribui��o para a COFINS a recolher - Detalhamento por c�digo de receita.
-- 1) Alterar a gera��o dos dados no processo de c�lculo do bloco M600: Considerar os registros conforme os valores dos campos N�o-Cumulativo e Cumulativo.
-- 2) Alterar o processo de valida��o do bloco M605: valores cumulativo e valores n�o-cumulativos; dm_num_campo; e, dm_origem.
-- Rotina: pkb_calcular_cons_cofins_m600 e pkb_validar_cons_cofins_m600.
--
-- Em 01/10/2014 - Angela In�s.
-- Redmine #4569 - Alterar o processo do Bloco M600 com rela��o a gera��o do Bloco 1700 - Controle de Reten��o na Fonte do COFINS.
-- Os valores de reten��o ser�o rateados por DM_IND_NAT_RET, e os valores de dedu��o ser�o rateados por Data de Reten��o e CNPJ, para lan�amentos no Bloco 1700.
-- Rotina: pkb_calcular_cons_cofins_m600.
-- Alterar o processo de exclus�o e desfazer, considerando contr_vlr_ret_fonte_cofins.dm_origem = 1-Gerado no Bloco M600.
-- Rotina: pkb_excl_per_cons_cofins_m600 e pkb_desproc_cons_cofins_m600.
--
-- Em 12/09/2014 - Angela In�s.
-- Redmine #4159 - Notas Fiscais de Servi�o sem Itens - Recupera��o dos valores de PIS e COFINS.
-- 1) Ao recuperar o identificador do tipo de cr�dito para as notas fiscais mercantis, considerar como valor de base de c�lculo, o campo de valor de base de
--    c�lculo total.
-- 2) Ao recuperar os valores do bloco M505 de acordo com o rateio proporcional para o valor VL_BC_COFINS, considerar como valor base o valor do campo VL_BC_COFINS_NC.
-- Rotinas: pkb_monta_dados_m500 e fkg_recup_vl_bc_cofins.
-- 3) Ao recuperar os valores do controle de valores retidos da fonte de cofins, cumulativo e n�o-cumulativo - Bloco F600, considerar da empresa matriz e filiais.
-- Rotinas: pkb_calcular_cons_pis_m600 e pkb_validar_cons_pis_m600.
--
-- Em 05/09/2014 - Angela In�s.
-- Redmine #4097 - Erro de valida��o Bloco M100 e M500.
-- Corre��o nos processos de gera��o do Bloco M500 - Apura��o da COFINS:
-- 1) Para o valor de "vl_bc_cofins_nc", considerar o campo "vl_bc_cofins_cum" para subtrair do valor da base de cr�dito.
-- Rotina: pkb_monta_dados_m500.
--
-- Em 07/08/2014 - Angela In�s.
-- Redmine #3704 - Processo de Apura��o do COFINS - Gera��o do Bloco M600.
-- 1) Gerar os valores dos Pagamentos - Bloco M605, ap�s gerar o Bloco M600, desde que o valor da contribui��o n�o cumulativa seja maior que zero
-- (cons_contr_cofins.vl_cont_nc_rec > 0), ou que o valor da contribui��o cumulativa seja maior que zero (cons_contr_cofins.vl_cont_cum_rec > 0).
-- Recuperar os valores informados nos par�metros de EFD-Contribui��es (tabela: param_efd_contr).
-- Considerar para as colunas:
-- cons_contr_cofins_or.id                   = conscontrcofinsor_seq.nextval
-- cons_contr_cofins_or.conscontrcofins_id   = cons_contr_cofins.id
-- cons_contr_cofins_or.dt_vencto            = param_efd_contr.dia_pagto||(to_number(to_char(per_cons_contr_cofins.dt_ini,'mm')) + param_efd_contr.qtde_mes_subsq)||to_char(per_cons_contr_cofins.dt_ini,'rrrr')
-- cons_contr_cofins_or.vl_rec               = cons_contr_cofins.vl_cont_nc_rec > 0 ou cons_contr_cofins.vl_cont_cum_rec > 0
-- cons_contr_cofins_or.tiporetimp_id        = param_efd_contr.tiporetimp_id_cof
-- cons_contr_cofins_or.tiporetimpreceita_id = param_efd_contr.tiporetimpreceita_id_cof
-- Obs.: Para cons_contr_cofins_or.dt_vencto verificar se a soma do m�s n�o ultrapasse 12, e neste caso, alterar o m�s para 01 e somar um ao ano em quest�o.
-- 2) Fazer a valida��o dos valores dos Pagamentos:
-- a) Tabela.coluna: cons_contr_cofins_or.tiporetimp_id. Tipo de Reten��o do Imposto COFINS - Valida��o: consistir o imposto COFINS.
-- b) Tabela.coluna: cons_contr_cofins_or.tiporetimpreceita_id. Tipo de Reten��o do Imposto COFINS de Receita - Valida��o: consistir se est� relacionado com o Tipo de Reten��o do Imposto COFINS (cons_contr_cofins_or.tiporetimp_id).
-- 3) Ao desfazer a situa��o da consolida��o, excluir os registros de Pagamentos.
--
-- Em 25/06/2014 - Angela In�s.
-- Redmine #3163 - Altera��es da EFD Contribui��es (Pis/Cofins) - Apura��o da COFINS.
-- 1) Registro M505: Preenchimento facultativo do Campo 06 (VL_BC_COFINS_NC), uniformizando com a regra de n�o obrigatoriedade de campo j� especificada.
--    Alterar a recupera��o dos valores de DET_APUR_CRED_COFINS.VL_BC_COFINS_CUM, para que sejam recuperados se o campo ABERTURA_EFD_PC_REGIME.DM_COD_INC_TRIB
--    for 3-Escritura��o de opera��es com incid�ncia nos regimes n�ocumulativo e cumulativo.
--    Rotina: pk_apur_cofins.pkb_monta_dados_m500.
--
-- Em 22/04/2014 - Angela In�s.
-- Redmine #2692 - Valida��o Indevida dos registro M400 e M800.
-- Altera��o: No final da gera��o dos registros M800 verificamos se ficaram algum registro com situa��o <> Validado e/ou com situa��o = Validado mas sem
-- Item/NCM, e retornamos uma mensagem do tipo informa��o.
-- Nessas verifica��es n�o estava sendo considerado o c�digo ST de acordo com a regra de neg�cio: CST 04, 06, 07, 08, 09 e 05 com Al�quota Zero(0).
-- Rotina: pkb_monta_dados_m800.
--
-- Em 14/04/2014 - Angela In�s.
-- Redmine #2672 - N�o est� sendo mostrado o CFOP que foi gerado o ajuste M610.
-- Rotina: pkb_monta_vetor_m600.
--
-- Em 08/04/2014 - Angela In�s.
-- Redmine #2454 - Embora a Gera��o do EFD Contribui��es est� com o status Validado ou Gerado o Portal permite que o usu�rio abra o Bloco M.
-- Rotinas: pkb_despr_apur_cofins_m500, pkb_desproc_cons_cofins_m600, pkb_desproc_contr_cofins_m700 e pkb_desproc_rec_cofins_m800.
--
-- Em 03/04/2014 - Angela In�s.
-- Redmine #2576 - Feedback - N�o pode criar mais de um registro 1300 e 1700 para o mesmo per�odo de escritura��o.
-- 1) Quando � utilizada toda a contribui��o retida na fonte n�o deve ser gerado registro no bloco 1700. Rotina: pkb_calcular_cons_pis_m600.
-- 2) Ao desprocessar M600 apagar o registro do bloco 1700. Rotina: pkb_desproc_cons_cofins_m600.
-- 3) Ao desprocessar a abertura do EFD apagar o registro do bloco 1700. Rotina: pkb_excl_per_cons_cofins_m600.
--
-- Em 02/04/2014 - Angela In�s.
-- Redmine #2573 - Alterar o tipo de indexador da gera��o dos blocos M505 para VARCHAR2, pois como num�rico o valor n�o comporta o tamanho.
-- Rotina: pkb_monta_vetor_m500.
-- Ao gerar M600 atualizar os valores da apura��o M500 quando o valor da contribui��o n�o-cumulativa estiver zerado e deixar como utiliza��o de valor parcial.
-- Rotina: pkb_calcular_cons_cofins_m600.
--
-- Em 27/03/2014 - Angela In�s.
-- Redmine #2429 - N�o pode criar mais de um registro 1300 e 1700 para o mesmo per�odo de escritura��o.
-- Rotina: pkb_calcular_cons_cofins_m600.
-- Redmine #2416 - Processo de c�lculo do M105 e M505.
-- No "Processo de c�lculo do M110 e M510", foi decidido que quando o "C�digo da Base de C�lculo do Cr�dito" for "13-Outras Opera��es com Direito a Cr�dito",
-- atribuir a pr�pria descri��o na "justificativa do cr�dito".
-- Rotina: pkb_monta_vetor_m500.
--
-- Em 11/03/2014 - Angela In�s.
-- Redmine #2192 - Corre��o do Processo para Automatizar o calculo com registro F600.
-- Rotina: pkb_calcular_cons_cofins_m600.
--
-- Em 06/03/2014 - Angela In�s.
-- Redmine #2192 - Corre��o do Processo para Automatizar o calculo com registro F600.
-- Rotinas: pkb_calcular_cons_cofins_m600 e pkb_validar_cons_cofins_m600.
--
-- Em 21/02/2014 - Angela In�s.
-- Redmine #1810 - Corre��o no par�metro que "Gera Escritura��o" - Para os processos PIS/COFINS.
-- Se o par�metro estiver marcado como "N�O", o documento n�o deve ser gerado no arquivo texto, e tamb�m n�o deve gerar apura��o nos blocos M400 e M800.
-- Rotina: pkb_monta_dados_m800.
--
-- Em 10/02/2014 - Angela In�s.
-- Redmine #1887 - Gera��o Apura��o PIS/COFINS - valores gerados incorretos com c�digo 04 de base de cr�dito.
-- Corrigido processo para recuperar com distinct o c�digo CFOP nas rotinas de servi�o cont�nuo.
-- Rotina: pk_apur_cofins.pkb_monta_dados_m500.
--
-- Em 26/12/2013 - Angela In�s.
-- Redmine #1324 - Informa��o - Nova regra de valida��o CST 05 EFD Contribui��es Vers�o 2.0.5.
-- 1) Parametrizar na tabela NAT_REC_PC se o c�digo de situa��o tribut�ria vinculado (nat_rec_pc.codst_id), ir� gerar receita (blocos M400 e M800):
-- DM_GERA_RECEITA = 0-N�O, 1-SIM. Deixamos como Valor Inicial = 1-Sim.
-- Considerar se a natureza (nat_rec_pc) recuperada, est� com a nova coluna DM_GERA_RECEITA = 1-SIM.
-- Rotinas: pkb_monta_dados_m800.
--
-- Em 26/12/2013 - Angela In�s.
-- Redmine #1644 - Considerar os Conhecimentos de Transporte com dm_arm_cte_terc igual a 0.
--
-- Em 16/12/2013 - Angela In�s.
-- Redmine #1580 - Utiliza��o do F600 nos registro M200 e M600 - Ficha HD 67009.
-- Altera��o: Deve ser somado, tamb�m, os valores do Bloco F600 devido a regra.
-- Rotina: pkb_calcular_cons_cofins_m600 e pkb_validar_cons_cofins_m600.
--
-- Em 04/11/2013 - Angela In�s.
-- Redmine #1156 - Implementar o par�metro que indica gera��o autom�tica de ajuste no bloco M610 nos processos do PIS/COFINS.
-- Se o CFOP n�o permite credito, o valor de credito tem que ser gerado no ajuste autom�tico no M610.
-- Rotinas: pkb_calcular_cons_cofins_m600/pkb_validar_cons_cofins_m600 - Incluir situa��o na recupera��o dos valores que estejam processadas e/ou validadas.
-- Rotinas: pkb_dados_abert_empr - Incluir a recupera��o do identificador da gera��o (abertura_efd_pc.id).
-- Rotinas: pkb_gerar_per_apur_cofins_m500/pkb_gerar_per_cons_cofins_m600/pkb_calcular_cons_cofins_m600/pkb_gerar_per_rec_cofins_m800 - Verificar se existe gera��o da abertura do efd no mesmo per�odo e calculado.
-- Rotinas: pkb_monta_dados_m600/pkb_monta_vetor_m600/pkb_grava_dados_m600 - Incluir inclus�o do ajuste (ajust_contr_pis_apur).
-- Rotina: pkb_excl_per_cons_cofins_m600 - Excluir a tabela cons_contr_cofins_or - Obriga��es a Recolher da Apura��o de COFINS, ao excluir a consolida��o.
--
-- Em 16/10/2013 - Angela In�s.
-- Redmine #1141 - Gera��o do PIS/COFINS - Bloco M100/M500.
-- Est� sendo gerado tipo de cr�dito 199 e 299 e n�o deveria, pois os valores est�o vindo zerados.
-- Corre��o no nome da coluna ID do cursor dos cr�ditos presumidos.
-- Rotina: pkb_monta_dados_m500.
--
-- Em 09/10/2013 - Angela In�s.
-- Considerar valor = 1 para valor de receita bruta total no c�lculo da receita bruta cumulativa.
-- Rotina: pkb_dados_abert_empr.
--
-- Em 02/10/2013 - Angela In�s.
-- Redmine #1038 - Gera��o do Bloco M200 e M600 - Consolida��o de Pis e Cofins.
-- N�o separar gera��o da consolida��o quando o c�digo da contribui��o for 51-Contribui��o cumulativa apurada a al�quota b�sica.
-- Rotina: pkb_monta_dados_m600.
--
-- Em 27/09/2013 - Angela In�s.
-- Redmine #599 - Islaine - EFD Contribui��es Aceco Matriz - Ficha HD: 66843
-- Gera��o do Bloco M500: nos registros F100, o item/produto � necess�rio devido ao NCM para identificar a embalagem, caso n�o tenha item/produto
-- n�o ser� considerado embalagem, portanto n�o exigir o ITEM.
-- Gera��o do Bloco M500: nos cursores, recuperar o valor de receita bruta cumulativa e n�o cumulativa de acordo com o percentual do registro 0111.
-- Rotina: pkb_monta_dados_m500.
--
-- Em 04/09/2013 - Angela In�s.
-- Redmine #648 - Suporte - Tadeu/Verdemar - Gera��o do PIS/COFINS - Abertura do arquivo.
-- Ao desprocessar a abertura do status de calculado para n�o gerado, excluir os dados gerados automaticamente - blocos M100/M200/M400 e M500/M600/M800.
-- Para essa atividade foi necess�rio alterar os par�metros de mensagens.
-- Rotinas: pkb_excl_per_apur_cofins_m500, pkb_excl_per_cons_cofins_m600 e pkb_excl_per_rec_cofins_m800.
-- Considerar o par�metro da empresa que indica se ir� utilizar recupera��o do tipo de cr�dito com o processo Embalagem ou n�o.
-- Rotina: pkb_monta_dados_m500.
--
-- Em 19/08/2013 - Angela In�s.
-- Redmine #569 - Gera��o de Receitas Isentas Bloco M800.
-- Realizar a altera��o da recupera��o da "Natureza de Receita de Pis/Cofins" - Ordem de recupera��o:
-- 1) Imposto do Documento Fiscal, 2) Cadastro do Item (tabela item_compl), 3) Cadastro com o NCM (NAT_REC_PC)
-- Rotina: pkb_monta_dados_m800.
--
-- Em 01/08/2013 - Angela In�s.
-- Redmine #406 - Alterar os processos de c�lculo do Pis/Cofins, bloco M.
-- Referente a atividade #403: Implementar o campo de "Flex Field" e campo definitivo para a "C�d. Nat. Rec" (Pis/Cofins).
-- Alterar os processos de c�lculo do Pis/Cofins, bloco M, para verificar primeiro o "c�digo de natureza de receita" no documento de origem.
-- Rotina: pkb_monta_dados_m800.
--
-- Ficha HD 66689 RC #206 - Configura��o do Portal para Gera��o do Bloco M.
-- Ao gerar os blocos M600 - Consolida��o, o mesmo n�o est� atualizando os valores da apura��o que se referem aos blocos M500, valores de cr�dito descontado.
-- Ao validar os valores de cr�dito descontado da apura��o, utilizar o total da consolida��o por per�odo e n�o por consolida��o.
-- Rotinas: pkb_calcular_cons_cofins_m600 e pkb_validar_cons_cofins_m600.
--
-- Em 17/05/2013 - Angela In�s.
-- Ficha HD 66689 - Configura��o do Portal para Gera��o do Bloco M.
-- Considerar o tipo de indicid�ncia tribut�ria = 3 para ratear os valores acumulados por tipo de cr�dito quando a CST for 53 ou 63.
-- Rotina: pkb_monta_dados_m500.
--
-- Em 02/05/2013 - Angela In�s.
-- Ficha HD 66673 - Considerar os valores de apura��o se a situa��o for 3-processada, para o c�lculo e valida��o do bloco M600.
-- Rotinas: pkb_calcular_cons_cofins_m600 e pkb_validar_cons_cofins_m600.
--
-- Em 29/04/2013 - Angela In�s.
-- Ficha HD 66642 - Bloco M800 - Ao recuperar os dados do F100 e o DM_ST_PROC <> VALIDADO, informar com mensagem no LOG/Informa��o geral do sistema.
--                  Bloco M800 - Ao recuperar os dados do F100 e o ITEM_ID = 0, informar com mensagem no LOG/Informa��o geral do sistema.
-- Rotinas: pkb_monta_dados_m800.
--
-- Em 25/03/2013 - Angela In�s.
-- Ficha HD 66442 - Implementar valida��es para os erros encontrados no PVA da EFD Pis/Cofins.
-- 1) Campo obrigat�rio para Natureza do Cr�dito igual a Outras Opera��es com Direito a Cr�dito.
-- Rotinas: pkb_validar_apur_cofins_m500.
--
-- Em 24/01/2013 - Angela In�s.
-- Ficha HD 65704 - Estrela - Bloco M500 e M600 - Cofins.
-- Corre��o na atualuza��o dos valores de cr�dito dispon�vel e saldo do bloco M500 atrav�s do bloco M600.
-- Rotina: pkb_calcular_cons_pis_m600.
--
-- Em 11/01/2013 - Angela In�s.
-- N�o incluir o valor de outras despesas nos itens das notas fiscais (item_nota_fiscal.vl_outro).
--
-- Em 08/11/2012 - Angela In�s.
-- Ficha HD 64080 - Escritura��o Doctos Fiscais e Bloco M. Nova tabela para considera��es de CFOP - param_cfop_empresa.
-- 1) Eliminada a verifica��o das cfops que geram receita isentas no bloco de consolida��o M600.  Rotina: pkb_monta_dados_m600.
-- 2) Eliminada a verifica��o das cfops que geram receita isentas no bloco de receitas isentas M800. Rotina: pkb_monta_dados_m800.
--
-- Em 17/10/2012 - Angela In�s.
-- Ficha HD 63978 - Considerar a coluna natrecpc_id para gerar os detalhes das receitas isentas - bloco M400.
-- Rotinas: pkb_grava_dados_m800 e pkb_monta_vetor_m800.
--
-- Em 11/10/2012 - Angela In�s.
-- Ficha HD 63865 - Considerar 0-Opera��o Mercado Interno, quando n�o houver indicador de origem de cr�dito.
-- Rotina: pkb_monta_dados_m600.
--
-- Em 10/10/2012 - Angela In�s.
-- 1) Ficha HD 63843 - Incluir nas inconsist�ncias de equipamento sem identificador de natureza de receita o c�digo do item e a data da redu��o Z.
--    Rotina: pkb_monta_dados_m800.
--
-- Em 03/10/2012 - Angela In�s.
-- 1) Ficha HD 63697 - Considerar o valor de frete/seguro/outros no valor do item bruto para comp�r os valores de receita e consolida��o.
--    Rotinas: pkb_monta_dados_m600 e pkb_monta_dados_m800.
--
-- Em 24/09/2012 - Angela In�s.
-- 1) Inclus�o de novos par�metros para recuperar o c�digo da natureza de receita ( en_ncm_id e ev_cod_ncm ). Deve existir o c�digo NCM.
--    Rotina: pkb_monta_dados_m800.
--
-- Em 10/09/2012 - Angela In�s.
-- 1) Atualizar a recupera��o do identificador da natureza de receita de pis/cofins para o bloco M810, enviando as al�quotas.
--    Rotina: pkb_monta_dados_m800.
-- 2) Alterar a verifica��o do identificador da natureza de receita de pis/cofins, utilizando a rotina pk_csf_efd_pc.fkg_conf_id_nat_rec_pc.
--    Rotina: pkb_validar_rec_cofins_m800.
--
-- Em 05/09/2012 - Angela In�s.
-- 1) Atualiza��o dos registros do bloco M500 atrav�s do c�lculo do bloco M600, com rela��o aos campos DM_IND_DESC_CRED, VL_CRED_DESC e VL_TOT_CRED_DESC.
--    Rotina: pkb_calcular_cons_cofins_m600.
--
-- Em 02/08/2012 - Angela In�s.
-- 1) N�o considerar o valor de imposto IPI caso a nota n�o tenha.
--   Rotina: pkb_monta_dados_m800.
--
-- Em 17/07/2012 - Angela In�s.
-- Ficha HD 61413:
-- 1) Ao calcular o registro M600 - verificar se a CFOP do registro faz parte dos valores da receita para os dados de resumo di�rio de venda.
--    Nova fun��o pk_csf_efd_pc.fkg_existe_cfop_rec_empr - Rotina PKB_MONTA_DADOS_M600.
-- 2) Ao calcular o registro M800 - verificar se a CFOP do registro faz parte dos valores da receita para os dados de sa�da.
--    Nova fun��o pk_csf_efd_pc.fkg_existe_cfop_rec_empr - Rotina PKB_MONTA_DADOS_M800.
--
-- Em 26/06/2012 - Angela In�s.
-- 1) Ao calcular o registro M600 - verificar se a CFOP do registro faz parte dos valores da receita.
--    Nova fun��o pk_csf_efd_pc.fkg_existe_cfop_rec_empr - Rotina PKB_MONTA_DADOS_M600.
--
-- Em 22/06/2012 - Angela In�s.
-- 1) Eliminar vari�veis declaradas e n�o utilizadas no processo.
--
-- Em 13/06/2012 - Angela In�s.
-- 1) Altera��o na montagem do bloco M500, considerar todos os c�digos de CST, n�o fazendo restri��o dos c�digos ('50', '51', '52', '53', '54', '55', '56').
--
-- Em 15/05/2012 - Angela In�s.
-- Ficha HD 58940 - Solicitante: Islaine
-- Solicita��o:
-- Para as notas fiscais de servi�os continuos criar a valida��o abaixo para o campo BASECALCCREDPC_ID da tabela nf_compl_oper_cofins:
-- 1) Para modelos documentos entre 06, 28 e 29 s� pode aceitar os c�digos de base de calculo entre: 01, 02, 04, 13 . Regra no manual do Contribuinte.
-- 2) Para modelos documentos entre 21 e 22 s� pode aceitar os c�digos de base de calculo entre: 03, 13. Regra no manual do Contribuinte.
--
-- Em 18/04/2012 - Angela In�s.
-- Nos processos de bloco M500 n�o estava sendo considerado a CST 64 e 55 corretamente.
--
-- Em 12/04/2012 - Angela In�s.
-- Incluir o valor do imposto tributado IPI no valor a ser gerado para o Bloco M800.
-- Referente aos valores de C100 - NOTA FISCAL (C�DIGO 01), NOTA FISCAL AVULSA (C�DIGO 1B), NOTA FISCAL DE PRODUTOR (C�DIGO 04) E NFE (C�DIGO 55).
--
-- Em 05/03/2012 - Angela In�s.
-- Ao gerar o bloco M500 considerar mais de um registro para as CSTs de mais de um tipo de regime (53, 54, 55, 56, 63, 64, 65, 66).
-- Ao gerar o bloco M600 considerar o campo da chave de contribui��o social como 01 para c�digos 01, 02, 03, 04, 32 e 71.
-- Ao gerar o bloco M610 considerar o campo da chave de contribui��o social como 01 para c�digos 01, 02, 03, 04, 32 e 71, mais o identificador da mesma.
--
-- Em 02/03/2011 - Angela In�s.
-- Acertar os par�metros que se referem a recupera��o das notas fiscais, conhecimentos de transporte, demais doctos, bens do ativo e cr�dtio de estoque.
--
-- Em 28/02/2012 - Angela In�s.
-- Atualizar a recupera��o dos dados na montagem do bloco M100 - m�s e ano de refer�ncia.
--
-- Em 24/02/2012 - Angela In�s.
-- Gerar consolida��o (bloco m600) mesmo n�o tendo detalhe, devido ao c�lculo de apura��o. O registro M600 � obrigat�rio.
-- N�o exigir detalhe de consolida��o (bloco m610) no c�lculo ou valida��o do bloco M600.
--
-- Em 03/02/2012 - Angela In�s.
-- N�o considerar o status 1-Calculada ou 2-Erro no c�lculo no processo do bloco M700.
--
-- Em 02/02/2012 - Angela In�s.
-- No processo de exclus�o por per�odo, excluir o registro do per�odo.
--
-- Em 31/01/2012 - Angela In�s.
-- Considerar a coluna chave do bloco M600 para montar o primeiro n�vel do processo.
--
-- Em 27/01/2012 - Angela In�s.
-- Passar a considerar ST espec�fica para recuperar os dados do bloco M500 (coment�rio detalhado na rotina PKB_MONTA_DADOS_M500).
--
-- Em 23/01/2012 - Angela In�s.
-- Inclu�do processo por per�odo de consolida��o da contribui��o - PER_CONS_CONTR_COFINS.
-- Eliminado as colunas EMPRESA_ID, DT_INI e DT_FIN da tabela de consolida��o CONS_CONTR_COFINS.
--
-- Em 18/01/2012 - Angela In�s.
-- Eliminado a coluna DM_SITUACAO da tabela de per�odo PER_APUR_CRED_COFINS
-- Eliminado as colunas EMPRESA_ID, DT_INI e DT_FIN da tabela de apura��o APUR_CRED_COFINS.
-- Inclu�do processo por per�odo de receita isenta da tabela de PER_REC_ISENTA_COFINS.
-- Eliminado as colunas EMPRESA_ID, DT_INI e DT_FIN da tabela de receitas isentas REC_ISENTA_COFINS.
--
-- Em 19/12/2011 - Angela In�s.
-- Altera��o nas casas decimais dos campos que se referem a al�quota em percentual e em quantidade.
--
-- Em 09/12/2011 - Angela In�s.
-- Inclus�o dos dados das Notas fiscais para as mensagens de erro.
--
-------------------------------------------------------------------------------------------------------------------------------
--
--| Apura��o de cr�dito
   gt_row_per_apur_cred_cofins  per_apur_cred_cofins%rowtype;
   gt_row_apur_cred_cofins      apur_cred_cofins%rowtype;
   gn_aberturaefdpc_id          abertura_efd_pc.id%type;
   gn_dm_cod_inc_trib           abertura_efd_pc_regime.dm_cod_inc_trib%type;
   gn_dm_ind_apro_cred          abertura_efd_pc_regime.dm_ind_apro_cred%type;
   gn_dm_ind_reg_cum            abertura_efd_pc_regime.dm_ind_reg_cum%type;
   gn_recbru_nc_trntr_tri       number;
   gn_recbru_nc_trntr_ntr       number;
   gn_recbru_nc_trexp_tri       number;
   gn_recbru_nc_trexp_exp       number;
   gn_recbru_nc_ntrexp_ntr      number;
   gn_recbru_nc_ntrexp_exp      number;
   gn_recbru_nc_trntrexp_tri    number;
   gn_recbru_nc_trntrexp_ntr    number;
   gn_recbru_nc_trntrexp_exp    number;
   gn_recbru_cum                number := 0;
   gn_vl_aj_redu                ajust_apur_cred_cofins.vl_aj%type;
   gn_vl_aj_acre                ajust_apur_cred_cofins.vl_aj%type;
   gn_tipoimp_id                tipo_imposto.id%type;

--| Consolida��o da contribui��o para o cofins do per�odo
   gt_row_per_cons_contr_cofins per_cons_contr_cofins%rowtype;
   gt_row_cons_contr_cofins     cons_contr_cofins%rowtype;
   gv_dm_ind_nat_pj             abertura_efd_pc.dm_ind_nat_pj%type;
   gn_dm_ind_ativ               abertura_efd_pc.dm_ind_ativ%type;

--| Contribui��o para o cofins diferido em per�odos anteriores
   gt_row_contr_cofins_difperant contr_cofins_dif_per_ant%rowtype;

--| Receitas isentas
   gt_row_per_rec_isenta_cofins  per_rec_isenta_cofins%rowtype;
   gt_row_rec_isenta_cofins      rec_isenta_cofins%rowtype;

-------------------------------------------------------------------------------------------------------

-- Declara��o de constantes
   erro_de_validacao     constant number := 1;
   erro_de_sistema       constant number := 2; -- 2-Erro geral do sistema
   erro_inform_geral     constant number := 35; -- 35-Informa��o Geral

-------------------------------------------------------------------------------------------------------

   gv_mensagem_log       log_generico.mensagem%type := null;
   gv_obj_referencia     log_generico.obj_referencia%type := null;
   gn_referencia_id      log_generico.referencia_id%type := null;
   gv_resumo_log         log_generico.resumo%type := null;

-------------------------------------------------------------------------------------------------------
-- Global Arrays
   ga_mem_calc_apur_cofins  tb_mem_calc_apur_cofins   := tb_mem_calc_apur_cofins();

-- Vari�veis para os vetores
   type tab_reg_m500 is record ( ch_cc_tpcr_or_tp_aliq number -- item 1 da chave -- foram concatenados os campos, pois as al�quotas podem estar zeradas
                                                                                 -- tipocredpc_id||dm_ind_cred_ori||tipo||aliq_cofins||vl_aliq_cofins_quant
                               , tipocredpc_id         number
                               , dm_ind_cred_ori       number(1)
                               , tipo                  number(1) -- 1-al�q.percentual, 2-al�q.quantidade
                               , aliq_cofins           number(8,4)
                               , vl_aliq_cofins_quant  number(9,4)
                               , apurcredcofins_id     number
                               , dm_situacao           number(1)
                               , vl_bc_cofins          number(15,2)
                               , quant_bc_cofins       number(15,3)
                               , vl_cred               number(15,2)
                               , vl_ajus_acres         number(15,2)
                               , vl_ajus_reduc         number(15,2)
                               , vl_cred_dif           number(15,2)
                               , vl_cred_disp          number(15,2)
                               , dm_ind_desc_cred      number(1)
                               , vl_cred_desc          number(15,2)
                               , vl_sld_cred           number(15,2) );
   --
   type t_tab_reg_m500 is table of tab_reg_m500 index by varchar2(20); -- binary_integer;
   vt_tab_reg_m500        t_tab_reg_m500;
   --
   type tab_reg_m505 is record ( apurcredcofins_id    number -- item 1 da chave -- a chave est� concatenada dentro do processo
                               , basecalccredpc_id    number -- item 2 da chave -- a chave est� concatenada dentro do processo
                               , codst_id             number -- item 3 da chave -- a chave est� concatenada dentro do processo
                               , detapurcredcofins_id number
                               , vl_bc_cofins_tot     number(15,2)
                               , vl_bc_cofins_cum     number(15,2)
                               , vl_bc_cofins_nc      number(15,2)
                               , vl_bc_cofins         number(15,2)
                               , quant_bc_cofins_tot  number(15,3)
                               , quant_bc_cofins      number(15,3)
                               , desc_cred            varchar2(255) );
   --
   type t_tab_reg_m505 is table of tab_reg_m505 index by varchar2(20); -- binary_integer;
   vt_tab_reg_m505        t_tab_reg_m505;
   --
   type tab_reg_m600 is record ( ch_conc_cs_cr_aliq    number -- foram concatenados os campos, pois as al�quotas podem estar zeradas
                                                              -- contrsocapurpc_id||aliq_cofins||aliq_cofins_quant
                               , conscontrcofins_id   number
                               , dm_situacao          number(1)
                               , vl_tot_cont_nc_per   number(15,2)
                               , vl_tot_cred_desc     number(15,2)
                               , vl_tot_cred_desc_ant number(15,2)
                               , vl_tot_cont_nc_dev   number(15,2)
                               , vl_ret_nc            number(15,2)
                               , vl_out_ded_nc        number(15,2)
                               , vl_cont_nc_rec       number(15,2)
                               , vl_tot_cont_cum_per  number(15,2)
                               , vl_ret_cum           number(15,2)
                               , vl_out_ded_cum       number(15,2)
                               , vl_cont_cum_rec      number(15,2)
                               , vl_tot_cont_rec      number(15,2) );
   --
   type t_tab_reg_m600 is table of tab_reg_m600 index by binary_integer;
   vt_tab_reg_m600        t_tab_reg_m600;
   --
   type tab_reg_m610 is record ( conscontrcofins_id      number
                               , contrsocapurpc_id       number      -- item 1 da chave
                               , aliq_cofins             number(8,4) -- item 2 da chave
                               , aliq_cofins_quant       number(9,4) -- item 3 da chave
                               , detconscontrcofins_id   number
                               , vl_rec_brt              number(15,2)
                               , vl_bc_cont              number(15,2)
                               , quant_bc_cofins         number(15,3)
                               , vl_cont_apur            number(15,2)
                               , vl_ajust_acrec          number(15,2)
                               , vl_ajust_reduc          number(15,2)
                               , vl_cont_difer           number(15,2)
                               , vl_cont_difer_ant       number(15,2)
                               , vl_cont_per             number(15,2) 
                               , vl_ajus_acres_bc_cofins number(15,2)
                               , vl_ajus_reduc_bc_cofins number(15,2)
                               , vl_bc_cont_ajus         number(15,2)
                               );
   --
   type t_tab_reg_m610 is table of tab_reg_m610 index by binary_integer;
   type t_bi_tab_reg_m610 is table of t_tab_reg_m610 index by binary_integer;
   vt_bi_tab_reg_m610        t_bi_tab_reg_m610;
   --
   type tab_reg_m620 is record ( ajustcontrcofinsapur_id number
                               , dm_ind_aj               number
                               , vl_ajuste               number(15,2)
                               , cd_cfop                 varchar2(1000) );
   --
   type t_tab_reg_m620     is table of tab_reg_m620 index by binary_integer;
   type t_bi_tab_reg_m620  is table of t_tab_reg_m620 index by binary_integer;
   type t_tri_tab_reg_m620 is table of t_bi_tab_reg_m620 index by binary_integer;
   vt_tri_tab_reg_m620        t_tri_tab_reg_m620;
   --
   type tab_reg_m800 is record ( ch_rec_cstplacta   varchar2(100) -- foram concatenados os campos, pois o plano de contas pode estar zerado
                                                                  -- codst_id||plano_conta.cod_cta - alteramos para varchar2 devido ao tamanho
                               , codst_id           number -- item 1 da chave
                               , planoconta_id      number -- item 2 da chave sendo o c�digo da conta e n�o o ID
                               , recisentacofins_id number
                               , dm_situacao        number(1)
                               , vl_tot_rec         number(15,2)
                               , desc_compl         varchar2(255) );
   --
   type t_tab_reg_m800 is table of tab_reg_m800 index by varchar2(100);
   vt_tab_reg_m800        t_tab_reg_m800;
   --
   type tab_reg_m810 is record ( recisentacofins_id    number -- item 1 da chave
                               , planoconta_id         number -- item 2 da chave
                               , natrecpc_id           number -- item 3 da chave
                               , detrecisentacofins_id number
                               , vl_rec                number(15,2)
                               , desc_compl            varchar2(255)  );
   --
   type t_tab_reg_m810     is table of tab_reg_m810   index by varchar2(100);
   type t_bi_tab_reg_m810  is table of t_tab_reg_m810 index by varchar2(100);
   type t_tri_tab_reg_m810 is table of t_bi_tab_reg_m810 index by varchar2(100);
   vt_tri_tab_reg_m810        t_tri_tab_reg_m810;
   --

-------------------------------------------------------------------------------------------------------

--| CR�DITO DE COFINS RELATIVO AO PER�ODO - BLOCO M500
--| Procedimento para gerar por per�odo a apura��o do cr�dito do COFINS - Bloco M500
--| Ser�o gerados os blocos M500 e M505
PROCEDURE PKB_GERAR_PER_APUR_COFINS_M500( EN_PERAPURCREDCOFINS_ID IN PER_APUR_CRED_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para excluir por per�odo a apura��o do cr�dito do COFINS - Bloco M500
PROCEDURE PKB_EXCL_PER_APUR_COFINS_M500( EN_PERAPURCREDCOFINS_ID IN PER_APUR_CRED_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para calcular por per�odo a apura��o do cr�dito do COFINS - Bloco M500
--| Ser�o calculados alguns campos dos blocos M500, M505 e M550
PROCEDURE PKB_CALC_PER_APUR_COFINS_M500( EN_PERAPURCREDCOFINS_ID IN PER_APUR_CRED_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para validar por per�odo a apura��o do cr�dito do COFINS - Bloco M500
--| Ser�o validados alguns campos dos blocos M500, M505 e M550
PROCEDURE PKB_VAL_PER_APUR_COFINS_M500( EN_PERAPURCREDCOFINS_ID IN PER_APUR_CRED_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para desprocessar por per�odo a apura��o do cr�dito do COFINS - Bloco M500
PROCEDURE PKB_DESPR_PER_APUR_COFINS_M500( EN_PERAPURCREDCOFINS_ID IN PER_APUR_CRED_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para calcular a apura��o do cr�dito do COFINS - Bloco M500
--| Ser�o calculados alguns campos dos blocos M500, M505 e M510
PROCEDURE PKB_CALCULAR_APUR_COFINS_M500( EN_APURCREDCOFINS_ID IN APUR_CRED_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para validar a apura��o do cr�dito do COFINS - Bloco M500
--| Ser�o validados alguns campos dos blocos M500, M505 e M510
PROCEDURE PKB_VALIDAR_APUR_COFINS_M500( EN_APURCREDCOFINS_ID IN APUR_CRED_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para desprocessar a apura��o do cr�dito do COFINS - Bloco M500
PROCEDURE PKB_DESPR_APUR_COFINS_M500( EN_APURCREDCOFINS_ID IN APUR_CRED_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

--| CONSOLIDA��O DA CONTRIBUI��O PARA O COFINS DO PER�ODO - BLOCO M600
--| Procedimento para gerar por per�odo a consolida��o do COFINS - Bloco M600
--| Ser�o gerados os blocos M600 e M610
PROCEDURE PKB_GERAR_PER_CONS_COFINS_M600( EN_PERCONSCONTRCOFINS_ID IN PER_CONS_CONTR_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para excluir por per�odo a consolida��o do COFINS - Bloco M600
PROCEDURE PKB_EXCL_PER_CONS_COFINS_M600( EN_PERCONSCONTRCOFINS_ID IN PER_CONS_CONTR_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para calcular por per�odo a consolida��o do COFINS - Bloco M600
--| Ser�o calculados alguns campos dos blocos M600, M610 e M620
PROCEDURE PKB_CALC_PER_CONS_COFINS_M600( EN_PERCONSCONTRCOFINS_ID IN PER_CONS_CONTR_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para validar por per�odo a consolida��o do COFINS - Bloco M600
--| Ser�o validados alguns campos dos blocos M600, M610 e M620
PROCEDURE PKB_VAL_PER_CONS_COFINS_M600( EN_PERCONSCONTRCOFINS_ID IN PER_CONS_CONTR_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para desprocessar por per�odo a consolida��o do COFINS - Bloco M600
PROCEDURE PKB_DESPR_PER_CONS_COFINS_M600( EN_PERCONSCONTRCOFINS_ID IN PER_CONS_CONTR_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para calcular a consolida��o do COFINS - Bloco M600
--| Ser�o calculados alguns campos dos blocos M600, M610 e M620
PROCEDURE PKB_CALCULAR_CONS_COFINS_M600( EN_CONSCONTRCOFINS_ID IN CONS_CONTR_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para validar a consolida��o do COFINS - Bloco M600
--| Ser�o validados alguns campos dos blocos M600, M610, M611, M620 e M630
PROCEDURE PKB_VALIDAR_CONS_COFINS_M600( EN_CONSCONTRCOFINS_ID IN CONS_CONTR_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para desprocessar a consolida��o do COFINS - Bloco M600
PROCEDURE PKB_DESPROC_CONS_COFINS_M600( EN_CONSCONTRCOFINS_ID IN CONS_CONTR_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

--| Procedimento para validar a contribui��o do COFINS diferida em per�odos anteriores
--| valores a pagar no per�odo - Bloco M700
PROCEDURE PKB_VALIDAR_CONTR_COFINS_M700( EN_CONTRCOFINSDIFPERANT_ID IN CONTR_COFINS_DIF_PER_ANT.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para desprocessar a contribui��o do COFINS diferida em per�odos anteriores
--| valores a pagar no per�odo - Bloco M700
PROCEDURE PKB_DESPROC_CONTR_COFINS_M700( EN_CONTRCOFINSDIFPERANT_ID IN CONTR_COFINS_DIF_PER_ANT.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para excluir a contribui��o do COFINS diferida em per�odos anteriores
--| valores a pagar no per�odo - Bloco M700
PROCEDURE PKB_EXCLUIR_CONTR_COFINS_M700( EN_CONTRCOFINSDIFPERANT_ID IN CONTR_COFINS_DIF_PER_ANT.ID%TYPE );

-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

--| Procedimento para gerar por per�odo as receitas isentas n�o alcan�adas pela incid�ncia da
--| contribui��o, sujeitas a al�quota zero ou de vendas com suspens�o - COFINS - Bloco M800
--| Ser�o gerados os blocos M800 e M810
PROCEDURE PKB_GERAR_PER_REC_COFINS_M800( EN_PERRECISENTACOFINS_ID IN PER_REC_ISENTA_COFINS.ID%TYPE );
-------------------------------------------------------------------------------------------------------

--| Procedimento para excluir por per�odo as receitas isentas n�o alcan�adas pela incid�ncia da
--| contribui��o, sujeitas a al�quota zero ou de vendas com suspens�o - COFINS - Bloco M800
PROCEDURE PKB_EXCL_PER_REC_COFINS_M800( EN_PERRECISENTACOFINS_ID IN PER_REC_ISENTA_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para calcular por per�odo as receitas isentas n�o alcan�adas pela incid�ncia da
--| contribui��o, sujeitas a al�quota zero ou de vendas com suspens�o - COFINS - Bloco M800
--| Ser�o calculados alguns campos dos blocos M800 e M810
PROCEDURE PKB_CALC_PER_REC_COFINS_M800( EN_PERRECISENTACOFINS_ID IN PER_REC_ISENTA_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para validar por per�odo as receitas isentas n�o alcan�adas pela incid�ncia da
--| contribui��o, sujeitas a al�quota zero ou de vendas com suspens�o - COFINS - Bloco M800
--| Ser�o validados alguns campos dos blocos M800 e M810
PROCEDURE PKB_VAL_PER_REC_COFINS_M800( EN_PERRECISENTACOFINS_ID IN PER_REC_ISENTA_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para desprocessar por per�odo as receitas isentas n�o alcan�adas pela incid�ncia da
--| contribui��o, sujeitas a al�quota zero ou de vendas com suspens�o - COFINS - Bloco M800
PROCEDURE PKB_DESPR_PER_REC_COFINS_M800( EN_PERRECISENTACOFINS_ID IN PER_REC_ISENTA_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para calcular as receitas isentas - Bloco M800
--| Ser�o calculados alguns campos dos blocos M800 e M810
PROCEDURE PKB_CALCULAR_REC_COFINS_M800( EN_RECISENTACOFINS_ID IN REC_ISENTA_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para validar as receitas isentas - Bloco M800
--| Ser�o validados alguns campos dos blocos M800 e M810
PROCEDURE PKB_VALIDAR_REC_COFINS_M800( EN_RECISENTACOFINS_ID IN REC_ISENTA_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para desprocessar as receitas isentas - Bloco M800
PROCEDURE PKB_DESPROC_REC_COFINS_M800( EN_RECISENTACOFINS_ID IN REC_ISENTA_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para descarregar o vetor de mem�ria de calculo na tabela f�sica
PROCEDURE PKB_GRAVA_VET_MEM_CALC_COFINS;

-------------------------------------------------------------------------------------------------------
END PK_APUR_COFINS;
/
