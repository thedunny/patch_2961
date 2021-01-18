create or replace package csf_own.pk_apur_icms is

-------------------------------------------------------------------------------------------------------
--| Especifica��o do pacote de procedimentos de Gera��o da Apura��o de ICMS
-------------------------------------------------------------------------------------------------------
--
-- Em 24/11/2020 - Renan Alves  
-- Redmine #73726 - Relat�rio P9 
-- Foi tratado o select que recupera o valor do FCP do imposto ICMS do item da nota fiscal,
-- incluindo um NVL, para situa��es da qual a coluna estiver nula.
-- Rotinas: fkg_modp9_cred_c190_c_d_590
-- Patch_2.9.6.1 / Patch_2.9.5.4 / Release_2.9.7 
--
-- Em 27/08/2020 - Marcos Ferreira
-- Distribui��es: 2.9.5 / 2.9.4.2
-- Redmine #70628 - Ajuste em tabelas de apura��o
-- Rotinas Criadas: pkb_grava_log_generico, pkg_gera_guia_pgto
-- Rotinas Alteradas:
--
-- Em 07/07/2020 - Allan Magrini
-- Redmine #68776: Analisar procedure exporta��o relat�rio P9
-- Rotinas Alteradas: pkb_monta_reg_modp9
-- Altera��es: Inclus�o dos ctes no cursor c_aj_debito
-- Distribui��es: 2.9.5 - 2.9.4.2 - 2.9.3.5
--
-- Em 07/07/2020 - Marcos Ferreira
-- Distribui��es: 2.9.4
-- Redmine #68776: Estrutura para integrar guia da PGTO_IMP_RET
-- Rotinas Alteradas: pkb_desfazer, pkb_monta_desenvolve_ba
-- Altera��es: Adequa��o a nova estrutura de tabela
--
-- Em 20/12/2019   - Karina de Paula
-- Redmine #62788  - Diverg�ncia de valores da Tela de Apura��o do ICMS e o Relat�rio de Resumo por CFOP
-- Rotina Alterada - fkg_tot_cred_c190_c590_d590 => Inclu�da a valida��o de valores de FCP qdo n�o existir valor para ICMS
--
-- Em 13/12/2019 - Luis Marques
-- Redmine #50385 - Escritura��o Fiscal a fim atender Notas Fiscais com Antecipa��o de Cr�dito de ICMS
-- fun��es Alteradas: fkg_tot_cred_c190_c590_d590, fkg_modp9_cred_c190_c_d_590 - colocado verifica��o se o documento
--                    � de antecipa��o de cr�dito n�o soma para notas de entrada.
--
-- Em 16/07/2019 - Renan Alves
-- Redmine #55715 - Valor de apura��o do ICMS com um campo sem recalcular
-- Foi inclu�do a coluna VL_SALDO_CREDOR_ANT no momento que realizar o update para zerar as colunas 
-- da tabela APURACAO_ICMS.
-- Rotinas: pkb_desfazer
--
-- Em 17/06/2019 - Renan Alves
-- Redmine #55482 - Erro Apura��o ICMS CFOP 3551 e 3556 com cr�dito indevido no calculo
-- Foi inclu�do uma condi��o (NOT IN) para os CFOPs 3551 e 3556 nos selects das fun��es, pois, os mesmos 
-- n�o devem ser considerados na soma dos valores. 
-- Rotinas: fkg_tot_cred_c190_c590_d590 e fkg_tot_cred_d190 
--
-- Em 29/11/2018 - Angela In�s.
-- Redmine #49206 - Ajuste nos valores do Imposto ICMS e ICMS-ST incluindo os valores de FCP.
-- Na Apura��o do ICMS, montagem do Livro de Apura��o de ICMS Modelo P9, incluir a soma do valor de FCP do Imposto ICMS, ao Valor Tributado de ICMS, para os
-- campos: Valor "001-Por sa�das com d�bito do imposto" e Valor "006-Por entradas com cr�dito do imposto".
-- Rotinas: fkg_som_vl_icms_c190_c590_d590, fkg_tot_cred_c190_c590_d590, fkg_totcredc190_c590_d590_5605, fkg_soma_cred_ext_op_c, fkg_tot_deb_ext_ent_c,
-- fkg_modp9_cred_c190_c_d_590 e fkg_modp9_vlicms_c190_c_d_590.
--
-- Em 22/01/2018 - Angela In�s.
-- Redmine #48915 - ICMS FCP e ICMS FCP ST.
-- Considerar a data de in�cio da apura��o como sendo a partir de 01/08/2018, para recuperar os valores de FCP do Imposto ICMS.
-- Rotinas: fkg_som_vl_icms_c190_c590_d590, fkg_tot_cred_c190_c590_d590, fkg_totcredc190_c590_d590_5605, fkg_soma_cred_ext_op_c, fkg_tot_deb_ext_ent_c,
-- fkg_modp9_cred_c190_c_d_590 e fkg_modp9_vlicms_c190_c_d_590.
--
-- Em 22/08/2018 - Karina de Paula
-- Redmine: #46270 - Incluir o valor das DEDU��ES na soma dos cr�ditos
-- Rotina Alterada: pkb_monta_reg_modp9 => Inclu�do na soma do campo vl_016 o valor do campo vn_vl_014 conforme solicitado
--
-- Em 07/08/2018 - Marcos Ferreira
-- Redmine: #45760 - Erro de valida��o Apura��o do ICMS - Valor saldo a transportar para o per�odo seguinte
-- Procedure: pkb_validar_dados
-- Corre��o: Aplicado a mesma l�gica da corre��o acima do redmine: #40266
--
-- Em 22/05/2018 - Marcos Ferreira
-- Redmine: #40266 - Apura��o de ICMS com erro para calculo do campo 13) Valor total de 'Saldo credor a transportar para o per�odo seguinte'
-- Procedure: pkb_calc_apuracao_icms
-- Corre��o: A Vari�vel gt_row_apuracao_icms.vl_icms_recolher estava sendo zerada caso o o Valor do ICMS a recolher fosse negativo,
--           e estava zerando o valor do saldo credor a transportar para o mes seguinte.
--           Fiz o Reposicionamento do gt_row_apuracao_icms.vl_icms_recolher := 0; ap�s o calculo do gt_row_apuracao_icms.vl_saldo_credor_transp
--
-- Em 20/09/2017 - Marcelo Ono.
-- Redmine #34754 - Implementado a exclus�o dos ajustes de apura��o de ICMS para GIA do estado da Bahia no desprocessamento da apura��o de ICMS
-- e apenas para os c�digos de ajustes parametrizados nos par�metros desenvolve Bahia (PARAM_DESENV_BA).
-- Rotina: pkb_desfazer.
--
-- Em 20/09/2017 - Marcelo Ono.
-- Redmine #34754 - Corre��o no processo que insere o ajuste de apura��o de ICMS para GIA, inserindo a descri��o "fundamento legal" com apenas 100 caracteres.
-- Rotina: pkb_insere_ajust_apuracao_icms.
--
-- Em 21/08/2017 - Marcelo Ono.
-- Redmine #33587 - Implementa��o do c�lculo do Diferencial de Al�quota para Nota Fiscal de Servi�o Cont�nuo (Modelos 06, 29, 28, 21 e 22)
-- Rotina: pkb_criar_ajuste_difal.
--
-- Em 12/05/2017 - Leandro Savenhago
-- Redmine #16536 - TRATAR D197 IGUAL AO C197 NO SPED FISCAL
-- Implementado o registro D197
-- Rotina: fkg_soma_dep_esp_c197.
--
-- Em 24/04/2017 - Angela In�s.
-- Redmine #30487 - Processo de valida��o: PK_APUR_ICMS.
-- 1) Verificar se a empresa relacionada a abertura da GIA pertence ao estado do Rio de Janeiro (abertura_gia/empresa/pessoa/cidade/estado.ibge_estado=33).
-- 2) Caso n�o atenda ao item 1, os novos campos dever�o estar nulos. Enviar mensagem com erro de valida��o.
-- 3) Caso atenda ao item 1, verificar se foi informado c�digo de ajuste (ajust_apur_icms_gia/subitem_gia.cd), e se o c�digo atende as regras abaixo:
-- 3.1) Informar nos campos COMPL_DADOS_1 uma "Descri��o da Ocorr�ncia", e em COMPL_DADOS_2 uma "Legisla��o Tribut�ria", c�digos: 'N029999', 'N039999', 'N079999',
-- 'N089999', 'N149999', 'N309999', 'S029999', 'S039999', 'S079999', 'S089999', 'S149999', 'S309999'.
-- 3.2) Informar nos campos COMPL_DADOS_1 um "N�mero do Banco", e em COMPL_DADOS_2 uma "Data de Pagamento", c�digos: 'N140001', 'N140002', 'N140005', 'N140006'.
-- 3.3) Informar no campo COMPL_DADOS_1 um "N�mero do Processo", c�digos: 'N070005', 'N070006', 'N140003', 'N140008', 'N140009'.
-- 3.4) Informar nos campos COMPL_DADOS_1 uma "Data de In�cio do Per�odo", em COMPL_DADOS_2 um "Tipo de Per�odo", e em COMPL_DADOS_3 um valor de "Base de C�lculo",
-- c�digos: 'O350006'.
-- 3.5) Informar nos campos COMPL_DADOS_1 uma "Data do Desembara�o", em COMPL_DADOS_2 um "Tipo de Declara��o de Importa��o", e em COMPL_DADOS_3 um "N�mero de
-- Declara��o de Importa��o/Outros", c�digos: 'O350007', 'O350009'.
-- 3.6) Informar nos campos COMPL_DADOS_1 uma "Data de In�cio do Per�odo", e em COMPL_DADOS_2 um "Tipo de Per�odo", c�digos: 'O350011', 'O350014'.
-- 3.7) Informar no campo COMPL_DADOS_1 uma "Descri��o da Ocorr�ncia", c�digos: 'O350012', 'O350013'.
-- 4) Caso atenda ao item 3, os campos COMPL_DADOS_1, COMPL_DADOS_2 e COMPL_DADOS_3, que dever�o possuir informa��es e for DATA, consistir para que seja uma data
-- v�lida, por�m n�o gravar com "/", apenas no formato "ddmmrrrr". Caso contr�rio enviar mensagem com erro de valida��o.
-- Rotina: pkb_validar.
--
-- Em 19/10/2016 - Angela In�s.
-- Redmine #24457 - Erro de pk na geracao do sped fiscal.
-- Considerar as altera��es dos ajustes das apura��es de GIA (tabela: ajust_apur_icms_gia), somente se houver identificador de SubItem de GIA nos par�metros 
-- do Sped Fiscal (Menu: Sped/IcmsIpi/Par�metros do Sped ICMS/IPI).
-- Rotina: pkb_insere_ajust_apuracao_icms.
--
-- Em 08/07/2016 - Angela In�s.
-- Redmine #21111 - Corre��o na apura��o de icms - cupons fiscais - modelo 59.
-- N�o recuperar os valores dos cupons fiscais com situa��o 7-Cancelados.
-- Rotina: fkg_soma_vl_icms_c800.
--
-- Em 27/06/2016 - Angela In�s.
-- Redmine #20697 - Corre��o nos par�metros do Sped ICMS/IPI - DIFAL - Partilha de ICMS - Processos.
-- Alterar na apura��o do ICMS, a Rotina PKB_MONTA_DIFAL: eliminar a op��o param_efd_icms_ipi.dm_lcto_difal=3-Apura��o ICMS-DIFAL, e considerar a chamada da
-- rotina pkb_criar_ajuste_difal_apur_id, passando como par�metro a coluna CODAJSALDOAPURICMS_ID_DIFPART na tabela PARAM_EFD_ICMS_IPI, para gera��o do ajuste.
--
-- Em 02/03/2016 - Angela In�s.
-- Redmine #15952 - N�o est� saindo o valor "0,00" no campo 16 do relat�rio p9.
-- Corre��o no processo de apura��o de ICMS. Para os valores dos campos VL_15 e VL_16, considerar 0(zero) quando forem nulos.
-- Rotina: pkb_monta_reg_modp9.
--
-- Em 17/02/2016 - Leandro Savenhago.
-- Redmine #15444 - Saldo credor a transportar para o per�odo seguinte - LIVRO P9.
-- Foi verificado que n�o estava sendo somando os valores do modelo documento fiscal 59-SAT
-- Rotinas: pkb_monta_reg_modp9.
--
-- Em 25/11/2015 - Angela In�s.
-- Redmine #13125 - Feedback 12383.
-- 1) Corre��o na apura��o do ICMS - VL_TOT_DEBITOS. Incluir os valores de ICMS dos Cupons Fiscais Eletr�nicos.
-- Rotinas: fkg_soma_vl_icms_c800, pkb_validar_dados e pkb_apuracao.
--
-- Em 27/07 e 13/08/2015 - Angela In�s.
-- Redmine #10117 - Escritura��o de documentos fiscais - Processos.
-- Inclus�o do novo conceito de recupera��o de data dos documentos fiscais para retorno dos registros.
--
-- Em 08/06/2015 - Leandro Savenhago.
-- Redmine #9050 - Falha na impress�o LIVRO MODELO 9 - Valor Total das Dedu��es (ACECO)
-- Rotina: pkb_monta_reg_modp9
--
-- Em 06/01/2015 - Angela In�s.
-- Redmine #5616 - Adequa��o dos objetos que utilizam dos novos conceitos de Mult-Org.
--
-- Em 15/12/2014 - Angela In�s.
-- Redmine #5519 - Corre��o no processo de Apura��o de ICMS e Apura��o de IPI.
-- Os processos/fun��es que apuram os valores de icms das notas fiscais devem manter as mesmas regras das fun��es que retornam os valores para os relat�rios.
-- Como exemplo: o processo da pk_csf_api.pkb_vlr_fiscal_item_nf com os selects da apura��o pk_apur_icms.
-- Rotinas: fkg_som_vl_icms_c190_c590_d590, fkg_tot_cred_c190_c590_d590, fkg_soma_cred_ext_op_c, fkg_soma_cred_ext_op_d, fkg_tot_deb_ext_ent_c, 
--          fkg_modp9_cred_c190_c_d_590 e fkg_modp9_vlicms_c190_c_d_590.
--
-- Em 22/09/2014 - Angela In�s.
-- Redmine #4263 - Duplicidade de ajustes a cr�ditos ( CISNE ).
-- Retorno: Temos um par�metro para ICMS/IPI que indica qual ser� o c�digo de ajuste para CIAP.
-- O cliente est� informando outro ajuste manualmente com o mesmo c�digo de ajuste do parametrizado para CIAP.
-- 1) Identificar o registro gerado automaticamente atrav�s do Complemento da Descri��o do Ajuste para CIAP e/ou DIFAL (ajust_apuracao_icms.descr_compl_aj).
-- Rotina: pkb_insere_ajust_apuracao_icms.
-- 2) Corre��o nas mensagens relacionadas ao processo de Valida��o dos valores.
-- Rotina: pkb_validar_dados.
--
-- Em 03/07/2014 - Angela In�s.
-- Redmine #3261 - Valor de ajuste de nota CTE n�o foi para a apura��o do ICMS.
-- 1) Acertar as rotinas para que recuperem o valor do ICMS da tabela de informa��es fiscais (ct_inf_prov). Rotinas: fkg_soma_aj_credito e fkg_soma_aj_debito.
-- 2) Incluir a descri��o relacionada ao indicador de apura��o do icms para sub-apura��o. Rotina: pkb_cria_sub_apur.
--
-- Em 23/05/2014 - Angela In�s.
-- Redmine #2911 - Processo de Apura��o de ICMS - implementar a seguinte valida��o:
-- Caso exista registro na tabela "AJUST_APUR_ICMS_GIA", a soma dos valores deve ser igual ao campo VL_AJ_APUR da tabela AJUST_APURACAO_ICMS.
-- Rotina: pkb_validar.
--
-- Em 23/05/2014 - Angela In�s.
-- Corre��o interna: erro na escrita da palavra Estorno.
--
-- Em 13/05/2014 - Angela In�s.
-- Redmine ##2737 - Processo de Apura��o de ICMS - D197.
-- Rotinas: fkg_soma_aj_debito e fkg_soma_aj_credito.
--
-- Em 29/04/2014 - Angela In�s.
-- Redmine #2761 - Pode haver mais de um registro 1900 no mesmo per�odo e com agrupamento dos ajustes onde o quarto digito estiver entre 3, 4, 5, 6, 7 e 8.
-- Altera��o: Na apura��o do ICMS, cria��o do registro de Sub-apura��o, deve-se considerar como:
-- a) reflexo na apura��o do icms: 2-C-Estorno de D�bito e 5-D-Estorno de Cr�dito;
-- b) tipo de apura��o: 3-Apura��o 1, 4-Apura��o 2, 5-Apura��o 3, 6-Apura��o 4, 7-Apura��o 5 e 8-Apura��o 6.
-- Rotina: pkb_validar.pkb_cria_sub_apur.
--
-- Em 21/03/2014 - Angela In�s.
-- Redmine #2055 - Gera��o da Sub-Apura��o de ICMS. Incluir a cria��o do registro 1900 para sub-apura��o ap�s processamento de valida��o da apura��o do icms.
-- Rotina: pkb_validar.pkb_cria_sub_apur.
-- Passar a recuperar os valores de VL_AJUST_DEBITO e VL_AJUST_CREDITO com c�digo de ocorr�ncia de ajuste, os tipos de apura��o de icms = 3,4,5.
-- Sendo: 3-Apura��o 1, 4-Apura��o 2, 5-Apura��o 3.
-- Rotinas: fkg_soma_aj_debito e fkg_soma_aj_credito.
--
-- Em 26/12/2013 - Angela In�s.
-- Redmine #1644 - Considerar os Conhecimentos de Transporte com dm_arm_cte_terc igual a 0.
--
-- Em 18/10/2012 - Angela In�s - Ficha HD 63612.
-- Alterar o processo de Apura��o de ICMS, conforme descrito no MD.050: Recupera��o dos dados das tabelas REG_APUR_ICMS_MOD9 e REG_APUR_ICMS_MOD9_DET.
--
-- Em 10/10/2012 - Angela In�s.
-- Ficha HD 63179 - Eliminar a corre��o feita anteriormente: Os valores referente as notas com as caracter�sticas: entrada, cfop 1152 e
-- situa��o 01-Documento regular extempor�neo; passar�o a fazer parte do valor do campo 5-Valor total dos cr�ditos por "Entradas e aquisi��es com cr�dito do imposto".
-- Rotinas/Fun��es: fkg_tot_cred_c190_c590_d590.
--
-- Em 09/10/2012 - Angela In�s.
-- Ficha HD 63179 - Os valores referente as notas com as caracter�sticas: entrada, cfop 1152 e situa��o 01-Documento regular extempor�neo;
-- passar�o a fazer parte do valor do campo 5-Valor total dos cr�ditos por "Entradas e aquisi��es com cr�dito do imposto".
-- Rotinas/Fun��es: fkg_tot_cred_c190_c590_d590.
--
-- Em 13/07/2012 - Angela In�s.
-- 1) Corre��o nas mensagens de log gen�rico.
-- 2) Alterar as rotinas/fun��es que comp�em o valor da apura��o de d�bito (APURACAO_ICMS.VL_DEB_ESP).
--    Considerar o valor do icms como negativo para as entradas (d�bitos) e valores positivos para as sa�das (cr�ditos).
--    Rotinas/fun��es: fkg_soma_cred_ext_op_c, fkg_soma_cred_ext_op_d, fkg_tot_deb_ext_ent_c e fkg_tot_deb_ext_ent_d.
--
-- Em 12/07/2012 - Angela In�s.
-- 1) Considerar todos os valores de icms para comp�r o valor da apura��o de d�bito (APURACAO_ICMS.VL_DEB_ESP).
--    Rotinas/fun��es: fkg_soma_cred_ext_op_c, fkg_soma_cred_ext_op_d, fkg_tot_deb_ext_ent_c e fkg_tot_deb_ext_ent_d.
--    Foi alterado o comando UNION para UNION ALL.
--
-------------------------------------------------------------------------------------------------------

   gt_row_apuracao_icms    apuracao_icms%rowtype;
   gt_param_desenv_ba      param_desenv_ba%rowtype;
   gn_regapuricmsmod9_id   reg_apur_icms_mod9.id%type;
   gn_dm_dt_escr_dfepoe    empresa.dm_dt_escr_dfepoe%type;
   gn_estado_id            estado.id%type;
   gv_sigla_estado         estado.sigla_estado%type;
   gv_ibge_estado          estado.ibge_estado%type;
   gn_loggenerico_id       log_generico.id%TYPE;
   gn_empresa_id           empresa.id%type;
   gn_erro                 number := 0;

-------------------------------------------------------------------------------------------------------

-- Declara��o de constantes

   ERRO_DE_VALIDACAO       CONSTANT NUMBER := 1;
   ERRO_DE_SISTEMA         CONSTANT NUMBER := 2;
   INFO_APUR_IMPOSTO       CONSTANT NUMBER := 33;

-------------------------------------------------------------------------------------------------------

   gv_cabec_log            log_generico.mensagem%type;
   gv_cabec_log_item       log_generico.mensagem%type;
   gv_mensagem_log         log_generico.mensagem%type;
   gv_resumo_log           log_generico.resumo%type;
   gn_usuario_id           neo_usuario.id%type;
   gv_obj_referencia       log_generico.obj_referencia%type default null;
   gn_referencia_id        log_generico.referencia_id%type := null;
   
   gt_row_param_efd_icms_ipi param_efd_icms_ipi%rowtype;

-------------------------------------------------------------------------------------------------------
--| Procedimento valida as informa��es da Apura��o de ICMS
procedure pkb_validar ( en_apuracaoicms_id in apuracao_icms.id%type );

-------------------------------------------------------------------------------------------------------
--| Procedimento desfaz a situa��o da Apura��o de ICMS e volta para seu anterior
procedure pkb_desfazer ( en_apuracaoicms_id in apuracao_icms.id%type );

-------------------------------------------------------------------------------------------------------
--| Procedimento faz a apura��o do ICMS
procedure pkb_apuracao ( en_apuracaoicms_id in apuracao_icms.id%type );

-------------------------------------------------------------------------------------------------------
--| Procedimento faz a execu��o da montagem de dados para o relat�rio de resumo por cfop
procedure pkb_rel_resumo_cfop ( en_apuracaoicms_id in apuracao_icms.id%type
                              , en_usuario_id      in neo_usuario.id%type );

-------------------------------------------------------------------------------------------------------
-- Procedure para Gera��o da Guia de Pagamento de Imposto
--
procedure pkg_gera_guia_pgto (en_apuracaoicms_id apuracao_icms.id%type,
                              en_usuario_id      neo_usuario.id%type); 
-------------------------------------------------------------------------------------------------------
-- Procedure para Estorno da Guia de Pagamento de Imposto
procedure pkg_estorna_guia_pgto (en_apuracaoicms_id apur_iss_simplificada.id%type,
                                 en_usuario_id neo_usuario.id%type);  

end pk_apur_icms;
/
