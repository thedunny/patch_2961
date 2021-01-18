create or replace package csf_own.pk_csf_api_nfs is

-------------------------------------------------------------------------------------------------------
-- Especifica��o do pacote de integra��o de notas fiscais de servi�os para o CSF
-------------------------------------------------------------------------------------------------------
--
-- Em 07/01/2021   - Eduardo Linden
-- Redmine #74979  - Corre��o sobre Flexfield - Notas fiscais de servicos
-- Rotina alterada - pkb_integr_imp_itemnf_ff => Troca do tipo numerico para caracter para FF CD_TIPO_RET_IMP 
-- Patch_2.9.6.1 / Patch_2.9.5.4 / Release_2.9.7
--
-- Em 05/01/2021   - Karina de Paula
-- Redmine #74840  - Base Imposto, Al�quota e Valor do Imposto
-- Rotina Alterada - pkb_solic_calc_imp => Inclu�dos os campos aliq_apli e vl_imp_trib para buscar do imposto de origem
--
-- Em 04/01/2021 - Renan Alves 
-- Redmine #74823 - Erro de valida��o NF_e - Servi�os (Modelo 99)
-- Foi incluido um novo select na tabela IMP_ITEMNF para o imposto ISS(6) para o tipo (DM_TIPO)
-- reten��o (1), para que o mesmo seja validado juntamente com o tipo imposto (0).
-- Rotina: pkb_valida_imposto_item 
-- Patch_2.9.6.1 / Patch_2.9.5.4 / Release_2.9.7
--
-- Em 16/12/2020   - Wendel Albino
-- Redmine #74172  - Valida��o indevida - Imposto de ISS (ACECO)
-- Rotina Alterada - pkb_valida_imposto_item -> retirada a clausula(imp.dm_tipo = 0) do select  que recupera o
--                 -  valor de vn_qtde_iss. O select deve recuperar se existe imposto ou reten��o iss e nao s� imposto.
--
-- Em 06/12/2020   - Karina de Paula
-- Redmine #72698  - Ajuste em calculodora impostos INSS e ISS Retidos
-- Rotina Alterada - pkb_integr_Imp_ItemNf_ff => Inclu�do o campo DM_MANTER_BC_INT na integra��o FF
-- pkb_solic_calc_imp
--
-- Em 11/11/2020   - Luis Marques - 2.9.5-2 / 2.9.6
-- Redmine #73049  - STATUS DA NFSE N�O BATE COM O LOG
-- Rotina Alterada - pkb_integr_Imp_ItemNf - Colocada tolerancia para valida��o de INSS retido por causa do trunc 
--                   usado no REINF para quem informa.
--
-- Em 07/10/2020 - Eduardo Linden
-- Redmine #72181 - valor imposto tributado INSS est� sendo arredondado
-- Ajuste sobre o calculo do INSS Retido para truncar o valor e revis�o da valida��o para o campo Imp_ItemNf.vl_imp_trib
-- Rotina alterada - pkb_integr_Imp_ItemNf
-- Liberado para o release 296 e patches 2.9.4.4 e 2.9.5.1
--
-- Em 25/09/2020 - Eduardo Linden
-- Redmine #67715 - Criar regra de valida��o
-- Inclus�o para calculo do campo Imp_ItemNf.vl_imp_trib para as notas de servi�os de terceiros.
-- Rotina alterada - pkb_integr_Imp_ItemNf
-- Liberado para o release 296 e patches 2.9.4.4 e 2.9.5.1
--
-- Em 16/09/2020   - Wendel Albino
-- Redmine #71510  - Notas de servi�o nao integram
-- Rotina Alterada - pkb_integr_Nota_Fiscal_serv -> inclusao dos contadores de qtd.
--
-- Em 11/09/2020   - Luis Marques - 2.9.5
-- Redmine #69657  - Incluir objeto integra��o 17 na mesma valida��o do objeto 7
-- Rotina Alterada - pkb_consistem_nf - Incluido objeto de Integra��o 17 junto com o objeto de integra��o 7
--
-- Em 26/08/2020  - Karina de Paula
-- Redmine #70837 - integra��o nfs-e
-- Altera��es     - pkb_integr_Nota_Fiscal_serv => Inclus�o do dom�nio 17 na verifica��o dos valores da vari�vel vn_dm_st_proc
--                - pkb_integr_Nota_Fiscal_serv => Quando n�o encontrado o cod_mod da nota era atribu�do o valor do modelo "55"
--                - foi alterada para receber o valor "99" 
-- Liberado       - Release_2.9.5, Patch_2.9.4.2 e Patch_2.9.3.5
--
-- Em 14/08/2020   - Karina de Paula
-- Redmine #69701  - Criar valida��o de NFS-e
-- Rotina Alterada - pkb_integr_Nota_Fiscal_serv => Inclu�da valida��o "N�o permitida opera��o de entrada para uma NFS-e de emiss�o pr�pria" 
-- Liberado        - Release_2.9.5, Patch_2.9.4.2 e Patch_2.9.3.5
--
-- Em 13/08/2020 - Eduardo Linden
-- Redmine #69462 - Calculo das Informa��es Totais
-- Foi feita altera��o na obten��o dos valores de soma do item, desconto e de abatimento.
-- Rotina alterada: pkb_gera_total_nfs
-- Disponivel para Release 2.9.5 e os patchs 2.9.4.2 e 2.9.3.5.
--
-- Em 10/08/20120 - Marcos Ferreira
-- Distribui��es: 2.9.4-2 / 2.9.5
-- Redmine #69597 - Falha na integra��o de notas de d�bito - modelo ND - 2.9.4.2 (EQUINIX)
-- Rotina: pkb_integr_nota_fiscal_serv_ff
-- Altera��es: Inclus�o de exce��o no update do dm_st_proc para n�o considerar notas fiscais de d�bito
--
-- Em 02/07/2020  - Karina de Paula
-- Redmine #57986 - [PLSQL] PIS e COFINS (ST e Retido) na NFe de Servi�os (Bras�lia)
-- Altera��es     - pkb_gera_total_nfs/pkb_solic_calc_imp => Inclus�o dos campos vl_pis_st e vl_cofins_st
-- Liberado       - Release_2.9.5, Patch_2.9.4.1 e Patch_2.9.3.4
--
-- Em 23/06/2020   - Wendel Albino
-- Redmine #68193  - CFOP 2933 Integra��o NFSe - MIDAS
-- Rotina Alterada - comentada chamada da pkb_valida_cfop_por_dest na procedure PKB_CONSISTEM_NF .
--
-- Em 14/05/2020 - Allan Magrini
-- Redmine #65711 - Informa��es Adicionais de NFSE n�o est� pulando linhas 
-- Na fase 1.1 foi alterado o valor do parametro en_ret_tecla de 1 para 0 na pk_csf.fkg_converte
-- Rotina Alterada: pkb_integr_NFInfor_Adic
--
-- Em 14/05/2020   - Karina de Paula
-- Redmine #67086  - Melhoria no Relat�rio Comparativo de Impostos Calculadora Fiscal x Impostos Integrados
-- Rotina Alterada - pkb_solic_calc_imp => Inclu�do o par�metro cd_lista_serv na chamada da pkb_grava_impostos_orig
-- Liberado nas vers�es -
--
-- Em 12/05/2020 - Allan Magrini
-- Redmine #67502 - Problemas com caracteres especiais.
-- Foi alterado parametro de 2 para 1 na pk_csf.fkg_converte 
-- Rotina Alterada: pkb_integr_NFInfor_Adic 
--
-- Em 06/05/2020  - Karina de Paula
-- Redmine #65401 - NF-e de emiss�o pr�pria autorizada indevidamente (CERRAD�O)
-- Altera��es     - Inclu�do para o gv_objeto o nome da package como valor default para conseguir retornar nos logs o objeto;
-- Liberado       - Release_2.9.4, Patch_2.9.3.2 e Patch_2.9.2.5
--
-- Em 27/04/2020        - Wendel Albino
-- Redmine 67114        - Calculo da Declan
-- Rotina Criada        - pkb_vlr_fiscal_item_nfs_declan => Procedimento que retorna os valores fiscais 
--                      -   de um item de nota fiscal de servi�o SOMENTE para o declan-rj que deve retornar 
--                      -   o valor total sem descontos.
-- patch 2.9.3.2 e 2.9.2.5 release 2.9.4
--
-- Em 16/04/2020        - Karina de Paula
-- Redmine 66925        - Preenchimento campo COD_TRIB_MUNICIPIO
-- Rotina Alterada      - pkb_solic_calc_imp => Inclu�do retorno de valor para o vetor vt_row_item_solic_calc.cod_trib_municipio    
-- Liberada nas vers�es -
--
-- Em 16/03/2020 - Eduardo Linden
-- Redmine #65710 - Integra��o NFSe Emiss�o Pr�pria no Padr�o Open Interface - Campo Natureza da Opera��o
-- Inclus�o de nova condi��o emiss�o pr�pria para nota de Florianopolis.
-- Rotina Alterada: pkb_integr_Nota_Fiscal_serv
-- Disponivel para Release 2.9.3.9 e os patchs 2.9.1.6 e 2.9.2.3.
--
-- Em 13/03/2020 - Luis Marques - 2.9.3
-- Redmine #63776 - Integra��o de NFSe - Aumentar Campo Razao Social do Destinat�rio e Logradouro
-- Rotina Alterada: pkb_reg_pessoa_dest_nf - Alterado para recuperar 60 caracteres dos campos nome e lograd da 
--                  nota_fiscal_dest para todas as valida��es.
--
-- Em 13/03/2020 - Allan Magrini
-- Redmine #65711 - Informa��es Adicionais de NFSE n�o est� pulando linhas 
-- Na fase 1.1 foi adicionado o parametro en_ret_chr10 na pk_csf.fkg_converte com valor 0
-- Rotina Alterada: pkb_integr_NFInfor_Adic
--
-- Em 10/03/20120 - Marcos Ferreira
-- Distribui��es: 2.9.2-3 / 2.9.3
-- Redmine #65543: Falha na integra��o de notas de d�bito - modelo ND (EQUINIX)
-- Rotina: pkb_integr_nota_fiscal_serv_ff
-- Altera��es: Inclus�o de exce��o no update do dm_st_proc para n�o considerar notas fiscais de d�bito
--
-- Em 06/03/2020 - Luiz Armando Azoni
-- Redmine #65578 - Valida��ao campo c�digo de tributa��o do munic�pio
-- Rotina Alterada: adequa��o para ajustar o recebimento do campo c�digo de tributa��o do munic�pio e altera��o em sua regra de valida��o. 
--				    Ser� validado o c�digo somente para as notas de emiss�o pr�pria, as de entrada ser�o registradas conforme cliente mandar.
--
-- Em 17/02/2020 - Luis Marques
-- Redmine #64479 - Valida��o do Campo Codstcidade_Id para NFSe
-- Rotina Alterada: pkb_integr_Imp_ItemNf - Alterado para verificar a existencia do CST de ISS para prefeitura
--                  de Florianopolis apenas se for emiss�o propria (DM_IND_EMIT=0) e n�o � legado (DM_LEGADO=0).
--
-- Em 03/02/2020 - Allan Magrini
-- Redmine #64100 - Caracter especial - fkg_converte_nfs (PWC/UNIP)  
-- Foi retirado o pk_csf_nfs.fkg_converte_nfs e colocado o pk_csf.fkg_converte
-- Rotina Alterada: pkb_integr_NFI
--
-- Em 29/01/2020   - Karina de Paula
-- Redmine 62831   - Integra��o de c�digo de tributa��o do munic�pio
-- Rotina Alterada - pkb_integr_itemnf_compl_serv => Retirada a verifica��o dm_ind_emit = 0 para poder validar tb p as outras formas de emiss�o
--                   Corrigada msg de erro com o nome da pk errada:pk_csf_api_nfserv - correto:pk_csf_api_nfs
--
-- Em 24/01/2020 - Allan Magrini
-- Redmine #64100 - Caracter especial - fkg_converte_nfs (PWC/UNIP)  
-- Foi alterado parametro de 2 para 1 na pk_csf_nfs.fkg_converte_nfs
-- Rotina Alterada: pkb_integr_NFInfor_Adic 
--
-- Em 24/01/2020 - Eduardo Linden
-- Redmine #64041 - feed - nao integrou no IMP_ITEMNF.CODSTCIDADE_ID
-- Rotina Alterada: pkb_integr_Imp_ItemNf - Melhora na mensagem de log e ajuste para carregar campo IMP_ITEMNF.CODSTCIDADE_ID. 
--
-- Em 23/11/2020 - Eduardo Linden
-- Redmine #63981 - feed - nao populado o campo IMP_ITEMNF.CODSTCIDADE_ID e nao validado quando est� sem
-- Rotina Alterada: pkb_integr_Imp_ItemNf - Foi alterado a gera��o do log (erro de valida��o) sobre o c�digo ST de 
--                                          Florian�polis estar nulo ou invalido.
--
-- Em 22/01/2020 - Luis Marques
-- Redmine #63755 - Falha na integra��o Open Interface - Emiss�o Pr�pria
-- Rotina Alterada: pkb_integr_nota_fiscal_serv_ff - Incluida verifica��o de DM_LEGADO x DM_ST_PROC para
--                  atualiza��o correta do DM_ST_PROC.
--
-- Em 15/01/2020 - Eduardo Linden
-- Redmine #63141 - Ajuste para emiss�o Florianopolis
-- Inclus�o do atributo COD_NAT_OPER na integra��o de NFS
-- Rotina Alterada - pkb_integr_nota_fiscal_serv_ff
-- Ajuste na integra��o na open interface , onde COD_IMPOSTO = 6 (ISS) e est_row_Imp_ItemNf.Codst_I estiver preenchido ser� feita uma 
-- busca na tabela COD_ST_CIDADE. Se encontrado o id na tabela COD_ST_CIDADE, ser� atribuido o campo Imp_ItemNf.Codstcidade_Id.
-- Incluida  a valida��o para Florianopolis, quanto ao preenchimento/valida��o do campo Imp_ItemNf.Codstcidade_Id
-- Rotina Alterada - pkb_integr_Imp_ItemNf
-- Valida��o para o campo NOTA_FISCAL.NATOPER_ID para Florianopolis (NOTA_FISCAL.CIDADE_IBGE_EMIT = 4205407).
-- Rotina Alterada - pkb_integr_Nota_Fiscal_serv
--
-- Em 25/11/2019 - Eduardo Linden
-- Redmine #61467 - Erro ORA-01843: not a valid month - PK_CSF_API_NFS.PKB_EXCLUIR_LOTE_SEM_NFS (ALTA)
-- Inclus�o da chamada da rotina pk_csf.fkg_param_global_csf_form_data.
-- Rotina Alterada - pkb_excluir_lote_sem_nfs
--
-- Em 12/11/2019        - Luiz Armando
-- Redmine #61161 - Gera��o do xml da de notas de servi�o
-- Logo no inicio da pkb_processar, adicionamos um update na nota_fiscal setando o campo DM_ST_PROC = 0 quando o mesmo for DM_ST_PROC IN ('5','10','18')
-- Esta altera��o se fez necess�ria pois n�o estava gerando o xml das notas de servi�o para retornar para a Midas.
-- Rotinas Alteradas    - pkb_processar
--
-- Em 24/10/2019        - Allan Magrini
-- Redmine #60308 - Avaliar o processo de integra��o de nota de servi�o
-- Na vn_fase 99.1 foi inserido no insert da tabela itemnf_compl_serv o campo cidade_id
-- Rotinas Alteradas    - pkb_integr_itemnf_compl_serv
--
-- Em 09/10/2019        - Karina de Paula
-- Redmine #52654/59814 - Alterar todas as buscar na tabela PESSOA para retornar o MAX ID
-- Rotinas Alteradas    - Trocada a fun��o pk_csf.fkg_Pessoa_id_cpf_cnpj_interno pela pk_csf.fkg_Pessoa_id_cpf_cnpj
-- N�O ALTERE A REGRA DESSAS ROTINAS SEM CONVERSAR COM EQUIPE
--
-- Em 05/09/2019   - Karina de Paula
-- Redmine #58459  - N�o est� integrando mais de um item de servi�o
-- Rotina Alterada - pkb_integr_Item_Nota_Fiscal => Exclu�da a verifica��o pk_csf.fkg_existe_item_nota_fiscal porque podemos ter mais
--                   de um item para a nota fiscal de servi�o. Criada a verifica��o de duplica��o da nota_fiscal_cobr (vn_nfcobr_id),
--                   para tratar a atividade 56740 que criou inicialmente a pk_csf.fkg_existe_item_nota_fiscal.
--
-- Em 05/09/2019   - Karina de Paula
-- Redmine #58328  - verificar erro no participante
-- Rotina Alterada - pkb_integr_Nota_Fiscal_serv => Alterada a verifica��o do pessoa_id referente ao COD_PART
--
-- Em 01/09/2019 - Luis Marques
-- Redmine #57717 - Alterar valida��o de alguns campos ap�s liberar #57714
-- Ajustadas as chamadas da fkg_converte para considerar novo valor de parametro dois (2) para convers�o de campo para NF-e.
-- Rotinas Alteradas: pkb_integr_nota_fiscal_serv, pkb_integr_nfinfor_adic
--
-- Em 30/08/2019 - Karina de Paula
-- Redmine #41413 - Lentid�o para execu��o da PK_INTEGR_VIEW_NFS e pk_valida_ambiente_nfs (UNIP)
-- Rotina Alterada: pkb_integr_Nota_Fiscal_serv => Foi inclu�da a procedure pk_csf.pkb_ret_dados_empresa para retornar todos 
--                  os dados da empresa de uma s� vez retirando as chamadas de functions. Organizado o c�digo para ajudar no entendimento 
--                  do c�digo e manuten��o quando necess�rio.
--
-- Em 26/08/2019 - Luis Marques
-- Redmine #57988 - Avaliar pkg de valida��o de nfse.
-- Rotina Alterada: pkb_integr_itemnf_compl_serv - ajustado para verificar o codigo de tributa��o do municipio apenas se
--                  for emiss�o propria.
--
-- Em 21/08/2019 - Luis Marques
-- Redmine #57141 - Valida��o nota fiscal servi�os
-- Rotinas Alteradas: pkb_integr_Imp_ItemNf, pkb_integr_Imp_ItemNf - ajustado para mostrar Informa��o Geral ao inves de
--                    Avisos Gen�ricos
--
-- Em 19/08/2019 - Luis Marques
-- Redmine #56740 - defeito - Nota est� ficando com erro de valida��o na duplicidade - Release 291
-- Rotina alterada: pkb_integr_Item_Nota_Fiscal - Colocada verifica��o se p item da nota j� existe vai para altera��o
--
-- Em 31/07/2019 - Karina de Paula
-- Redmine 56930 - Melhoria em procedimento de exclus�o de LOTES de NFS-e
-- Rotinas alteradas: pkb_excluir_lote_sem_nfs - Alterado o select do cursor para melhorar performance
--
-- Em 21/07/2019 - Luis Marques
-- Redmine #56565 - feed - Mensagem de ADVERTENCIA est� deixando documento com ERRO DE VALIDA��O
-- Rotinas alteradas: pkb_integr_Imp_ItemNf, pkb_integr_Nota_Fiscal_serv e pkb_consistem_nf
--                    Alterado para colocar verifica��o de falta de Codigo de base de calculo de PIS/COFINS
--                    como advertencia e n�o marcar o documento com erro de valida��o se for s� esse log.
-- Function nova: fkg_ver_erro_log_generico_nfs
--
-- Em 15/07/2019 - Luis Marques
-- Redmine #27836 Valida��o PIS e COFINS - Gerar log de advert�ncia durante integra��o dos documentos
-- Rotinas alterada: Incluido verifica��o de advertencia da falta de Codigo da base de calculo do credito
--                   se existir base e aliquota de imposto for do tipo imposto (0) e cliente juridico
--                   pkb_integr_Imp_ItemNf
--
-- Em 24/06/2019 - Luis Marques
-- Redmine #55214 - feed - n�o retornou os campos desejados
-- Incluido nro da CID para verifica��o conforme passado por processo de importa��o
-- Rotina Alterada pkb_integr_Nota_fiscal_dest
--
-- Em 07/06/2019 - Renan Alves
-- Redmine #55107 - [Falha] no campo ibgeCidade divergente do XML e na definitiva
-- Foram comentados os campos est_row_Nota_Fiscal.cidade_ibge_emit e est_row_Nota_Fiscal.uf_ibge_emit, pois,
-- os mesmo estavam com informa��es fixas, e foi inclu�do um select para retornar o IBGE Cidade e IBGE Estado
-- Rotina Criada: pkb_integr_nota_fiscal_serv 
--
-- Em 23/05/2019 - Karina de Paula
-- Redmine #54724 - Os zeros a esquerda n�o sendo desconsiderados.
-- Rotina Alterada: fkg_ff_ret_vlr_number  => Alterado fun��o fkg_ff_ret_vlr_caracter para fkg_ff_ret_vlr_number
--
-- Em 20/05/2019 - Karina de Paula
-- Redmine #41642 - Inconsist�ncia na VW_CSF_IMP_ITEMNF_SERV_FF
-- Rotina Alterada: pkb_integr_imp_itemnf_ff  => Alterado a verifica��o do valor da vari�vel vn_dmtipocampo de caracter para number
--
-- Em 02/04/2019 - Karina de Paula
-- Redmine #52997 - feed - erro na integra��o do imposto
-- Rotina Criada: vn_imp_itemnf 
--
-- Em 29/03/2019 - Karina de Paula
-- Redmine #52894 - feed - nao est� gerando informa��es na tabela imp_itemnf_orig
-- Rotina Alterada: pkb_solic_calc_imp => A rotina foi inclu�da na pks para poder ser usada em outros processos
--
-- Em 18/03/2019 - Angela In�s.
-- Redmine #46056 - Processo de Integra��o de NF de Servi�o.
-- Eliminar das rotinas pk_integr_view_nfs.pkb_ler_nota_fiscal_serv e pk_valida_ambiente.pkb_ler_nota_fiscal_serv, o select que recupera as informa��es de IBGE 
-- da cidade da empresa da nota fiscal, e incluir na rotina pk_csf_api_nfs.pkb_integr_itemnf_compl_serv.
-- Vari�veis utilizadas: gv_ibge_cidade_empr e gv_cod_mod.
-- Rotina: pkb_integr_itemnf_compl_serv.
--
-- Em 12/03/2019 - Angela In�s.
-- Redmine #52397 - Corre��o no processo de valida��o de impostos PIS e COFINS.
-- O valor do c�lculo do imposto para comparar com o que est� na valida��o, est� incorreto:
-- Atual/erro: round((base * aliq),2). Correto: round((base * aliq/100),2)
-- O teste acusa erro de valida��o porque verifica: vl_imp_trib <= 0 E vl_imp_recalculado > 0. Neste caso, o valor recalculado est� 0,22, seguindo o exemplo da atividade.
-- Rotina: pkb_valida_imposto_item.
--
-- Em 05/02/2019 - Eduardo Linden
-- Redmine #51128 - ID_Empresa divergente - tabela Log_generico_nf
-- Inclus�o da variavel vn_empresa_id para o parametro en_empresa_id da procedure pkb_log_generico_nf. 
-- Para evitar registro na tabela log_generico_nf com id_empresa diferente do que est� registrado na tabela nota_fiscal.
-- Rotina alterada: pkb_integr_Nota_Fiscal_Canc
--
-- Em 23/01/2019 - Karina de Paula
-- Redmine #49691 - DMSTPROC alterando para 1 ap�s update em NFSE - Dr Consulta
-- Criadas as vari�veis globais gv_objeto e gn_fase para ser usada no trigger T_A_I_U_Nota_Fiscal_02 tb alterados os objetos q
-- alteram ou incluem dados na nota_fiscal.dm_st_proc para carregar popular as vari�veis
--
-- Em 10/01/2019 - Karina de Paula
-- Redmine #50344 - Processo para gerar os dados dos impostos originais 
-- Rotina Alterada: pkb_solic_calc_imp => Inclu�da a chamada das rotinas: pk_csf.fkg_empresa_guarda_imporig e pk_csf.fkg_existe_nf_imp
-- para verificar se grava os dados dos impostos originais dos itens da nota fiscal de servi�o
--
-- Em 08/01/2019 - Marcos Ferreira
-- Redmine #36262 - 22273 - BASE DE C�LCULO PARA CST 70 - NAT. OPERA��O
-- Solicita��o: Para o cod_cst 73 - Opera��o de Aquisi��o a Al�quota Zero, dever� ser poss�vel a inser��o da Base de Calculo. Incluir a exce��o para este cst
-- Procedures Alteradas: pkb_valida_imposto_item
-- Altera��es: Inclu�do o cod_st 73 no not in da procedure de valida��o do imposto do �tem na situa��o tribut�ria isenta
-- Procedures Alteradas: pkb_gera_imposto_nfs
-- Altera��es: Zera a vari�vel vn_vl_base_calc quando for cod_st 73
-- 
-- Em 04/01/2019 - Karina de Paula
-- Redmine #49124 - Layout de Nota Fiscal de Servico campos nro_nfs e dt_emiss_nfs
-- Alterada a pkb_integr_nota_fiscal_serv_ff com a incluis�o do campo flex field dt_emiss_nfs na rotina de valida��o
--
-- Em 26/12/2018 - Angela In�s.
-- Redmine #49824 - Processos de Integra��o e Valida��es de Nota Fiscal (v�rios modelos).
-- Alterar os processos de integra��o, valida��es api e ambiente, que utilizam a Tabela/View VW_CSF_ITEM_NOTA_FISCAL_FF, para receber a coluna DM_MAT_PROP_TERC.
-- Rotina: pkb_integr_item_nota_fiscal_ff.
-- Alterar os processos de integra��o, valida��es api e ambiente, que utilizam a Tabela/View VW_CSF_ITEMNF_COMPL_SERV_FF, para receber a coluna VL_ABAT_NT.
-- Na valida��o da Nota Fiscal Total, considerar os valores do Item da Nota Fiscal para comp�r a coluna VL_ABAT_NT na Nota Fiscal Total.
-- Rotinas: pkb_int_itemnf_compl_serv_ff e pkb_gera_total_nfs.
--
-- Em 11/12/2018 - Eduardo Linden
-- Redmine #49445 - feed - est� validando para NFS-e modelo ND
-- Troca de variavel utilizada para identificar o c�digo do modelo da nota ( de gn_modfiscal_id para gt_row_nota_fiscal.modfiscal_id).
-- Rotina: pkb_integr_NFInfor_Adic
--
-- Em 16/11/2018  - Eduardo Linden
-- Redmine #48716 - Altera��o da package pk_csf_api_nfs - Retirar Valida��o de Nota de D�bito
-- Inclus�o de valida��o quanto ao modelo fiscal para Informa��es Complementares da NF-e com menos de 10 caracteres.
-- Caso o modelo fiscal for ND (Nota de D�bito), est� valida��o de qtde de caracteres n�o ser� executada.
-- Rotina: pkb_integr_NFInfor_Adic
--
-- Em 14/11/2018 - Angela In�s.
-- Redmine #35916 - Solicita��o de Melhoria: Cria��o de valida��o na NFSe para as Notas Fiscais de emiss�o pr�pria.
-- Fazer a valida��o, considerando a CIDADE_IBGE e a UF, por�m sem par�metro de empresa. De acordo com a Consultoria/Igor, identificamos que os Munic�pios que
-- possuem Distritos devem enviar como c�digo de IBGE, o c�digo do Munic�pio. N�o teremos par�metro por empresa para fazer a valida��o.
-- Ser� considerado a Nota Fiscal de modelo "99", de emiss�o pr�pria, verificar se o c�digo IBGE � "9999999", e nesse caso, verificar se a UF enviada n�o � "EX",
-- e n�o sendo, estaremos gerando um log/mensagem indicando "Erro de Valida��o", e consequentemente invalidando a nota fiscal.
-- Rotina: pkb_integr_nota_fiscal_dest.
--
-- Em 14/11/2018 - Karina de Paula
-- Redmine #48090 - Erro de Valida��o NFSe
-- Rotina Alterada: pkb_vld_infor_dupl => Retirada a subtra��o do valor de inss retido do valor total da nf (vn_vl_total_nf)
--
-- Em 02/10/2018 - Angela In�s.
-- Redmine #47465 - Altera��es na valida��o da NFS - Gera��o do LOTE.
-- 1) Eliminar a chamada da fun��o de cria��o do lote da Spec/PKS, pois a mesma dever� ser executada somente dentro desse contexto.
-- 2) Na cria��o do lote_nfs, incluir o registro com a nova situa��o, "7-Em gera��o do lote", enquanto as notas forem sendo vinculadas ao lote, para que o mesmo
-- seja liberado ap�s atualiza��o das datas e valores.
-- Rotina: fkg_integr_lote.
-- 3) Ao atualizar o lote_nfs com as datas inicial e final, os valores dos servi�os, e a qtde de nfs vinculadas ao lote, atualizar a situa��o do lote para 0-aberto.
-- Rotina: pkb_atual_dados_lote_nfs.
-- 4) Excluir os lotes que ficaram sem v�nculo com notas fiscais, e que a situa��o seja diferente de 3-Erro ao enviar Lote a SEFAZ, e 7-Em gera��o do lote.
-- Rotina: pkb_excluir_lote_sem_nfs.
--
-- Em 27/09/2018 - Angela In�s.
-- Redmine #47296 - Valida��o do C�digo do Item - NF de Servi�o.
-- Eliminar a fun��o de convers�o de caracteres especiais (pk_csf.fkg_converte), utilizada no campo de c�digo do item (item_nota_fiscal.cod_item).
-- Rotina: pkb_integr_Item_Nota_Fiscal.
--
-- Em 14/09/2018 - Marcos Ferreira
-- Redmine #46843 - NFS do Dr. Consulta com extrema lentid�o no processamento.
-- Solicita��o: Verificar processos que est�o gerando lentid�o no processamento de notas de servi�o
-- Altera��es: Melhoria na rotina para aumentar a performance do processamento de notas e gera��o de lotes
-- Procedures Alteradas: pkb_gera_lote_emissao_propria
--
-- Em 11/09/2018 - Marcos Ferreira
-- Redmine #46750 - NFS do Dr. Consulta com extrema lentid�o no processamento.
-- Solicita��o: Diminuir a quantidade de notas fiscais de servi�o por lote para tentar agilizar o processamento da fila
-- Altera��es: Limitado o lote a 50 notas
-- Procedures Alteradas: pkb_gera_lote_emissao_propria
--
-- Em 10/09/2018 - Marcos Ferreira
-- Redmine #46754 - Incluir novo dom�nio - 'N�o Incid�ncia
-- Solicita��o: Incluir o nono dom�nio 'N�o Incid�ncia', na estrutura: 'NF_COMPL_SERV.DM_NAT_OPER'.
-- Altera��es: Incluir o dominio NF_COMPL_SERV.DM_NAT_OPER - 8 'N�o Incid�ncia' nos ranges que utilizam este dominio
-- Procedures alteradas: pkb_integr_nf_compl_serv /
--
-- Em 31/08/2018 - Angela In�s.
-- Redmine #46526 - Corre��o na Valida��o de Nota Fiscal de Servi�o - Situa��o do Documento.
-- Considerar as informa��es da situa��o da nota fiscal e da finalidade da nota fiscal para comp�r a situa��o do documento.
-- Rotina: pkb_integr_Nota_Fiscal_serv.
--
-- Em 15/08/2018 - Angela In�s.
-- Redmine #46001 - Corre��es: Relat�rio de documentos fiscais (Item) e Integra��o de Notas Fiscais de Servi�o.
-- Na valida��o do destinat�rio, o processo est�, erroneamente, atualizando o identificador do pessoa/participante na nota fiscal, antes de identificar se o
-- participante existe no cadastro, portanto, se ele n�o existir, o cadastro est� ap�s a atualiza��o. Alterar para que esse processo esteja no final da rotina,
-- atualizando com o participante do CNPJ ou CPF, cadastrado como PESSOA (participante), caso n�o exista na nota (nota_fiscal.pessoa_id is null, indicando que n�o
-- foi enviado pela view da nota, o campo cod_part).
-- Rotina: pkb_reg_pessoa_dest_nf.
--
-- Em 06/08/2018 - Marcos Ferreira
-- Redmine #33155 - Adaptar Layout de Inttegra��o de Nota Fiscais de Servi�o para novo campo.
-- Rotinas: pkb_integr_Nota_Fiscal_Dest.
-- Altera��o: Inclus�o do campo "id_estrangeiro" no processo de integra��o
--
-- Em 30/07/2018 - Angela In�s.
-- Redmine #45458 - Melhoria em processo de montagem de lote_nfs.
-- Inclu�do o comando COMMIT na gera��o do Lote.
-- Rotinas: pkb_gera_lote_emissao_propria e pkb_gera_lote_emissao_terceiro.
--
-- Em 03/07/2018 - Marcelo Ono.
-- Redmine #41705 - Implementado a integra��o dos campos "tipo de servi�o Reinf e indicador do CPRB" no item da nota fiscal.
-- Rotina: pkb_int_itemnf_compl_serv_ff.
--
-- Em 25/06/2018 - Angela In�s.
-- Redmine #44368 - Corre��o na valida��o de NF de Servi�o - Complemento.
-- Alterar o valor do campo, nf_compl_serv.dm_nat_oper, caso o valor seja nulo. Ser� atribu�do 1-Tributa��o do Munic�pio.
-- Rotina: pkb_integr_nf_compl_serv.
--
-- Em 11/06/2018 - Marcelo Ono
-- Redmine #38773 - Corre��o no processo de valida��o das informa��es de detalhamento de servi�os prestados na constru��o civil.
-- 1- Retirado a valida��o de obrigatoriedade das colunas "NRO_ART e NRO_CNO" para a inclus�o do registro na tabela oficial "nfs_det_constr_civil", visto que, esta informa��o
-- n�o � obrigat�ria no leiaute de integra��o e na tabela oficial.
-- Rotina: pkb_integr_nfs_detconstrcivil.
--
-- Em 05/06/2018 - Angela In�s.
-- Redmine #43646 - Melhoria t�cnica no processo de Integra��o de Notas Fiscais de Servi�o.
-- Para melhoria do processo de Integra��o de Notas Fiscais de Servi�o, foi necess�rio eliminar o processo que verifica se existe mais de uma nota para:
-- empresa, modelo, s�rie, n�mero, opera��o, emitente e participante.
-- Esse processo � um comando "select" retornando um "count", executado para cada nota fiscal que envia o Identificador (ID <> 0), por�m esse retorno n�o est�
-- sendo utilizado em nenhum outro processo (vari�vel vn_qtde_nf). Portanto, select desnecess�rio. O mesmo procedimento � utilizado para Integra��o de Notas
-- Fiscais Mercantis, e nesse caso, uma mensagem/log de advert�ncia/aviso � emitida: "Nota Fiscal integrada, realizado a valida��o dos dados."
-- Rotina: pkb_integr_nota_fiscal_serv.
--
-- Em 02/06/2018 - Marcelo Ono
-- Redmine #43088 - Implementado a valida��o das informa��es de impostos adicionais de aposentadoria especial.
-- Rotina: pkb_int_imp_adic_apos_esp_serv.
--
-- Em 11/05/2018 - Angela In�s.
-- Redmine #42750 - N�o est� enviando a NF-e de Bauru.
-- Foi criada mensagem do tipo Informa��o Geral, indicando as condi��es para que o Lote seja gerado e a Nota Fiscal seja enviada.
-- Rotina: pkb_gera_lote_emissao_propria.
--
-- Em 24/05/2018 - Marcos Ferreira.
-- Redmine: #420770 - Corre��o nas valida��es dos dados de Constru��o Civil - Notas Fiscais de Servi�o.
-- Corre��o nas valida��es dos dados de Constru��o Civil - Notas Fiscais de Servi�o.
-- Processo: pkb_integr_nfs_detconstrcivil.
-- 1) N�o exigir valores nos campos cod_obra e nro_art.
-- 2) Exigir valor no campo nro_cno (dever� ser diferente de nulo), caso o campo dm_ind_obra seja 1 ou 2.
--
-- Em 28/03/2018 - Angela In�s.
-- Redmine #41080 - Alterar o processo de valida��o do CFOP: destinat�rio e emitente.
-- 1) Considerar como destinat�rio, a sigla do estado na tabela de destinat�rio: nota_fiscal_dest.
-- 2) Considerar como emitente, a sigla do estado na tabela de emitente: nota_fiscal_emit.
-- 3) Caso n�o seja encontrado o emitente, item 2, considerar a sigla do estado da empresa vinculada com a nota fiscal (nota_fiscal.empresa_id), se a nota fiscal
-- for de emiss�o pr�pria (nota_fiscal.dm_ind_emit=0).
-- 4) Caso n�o seja encontrado o emitente, item 2, considerar a sigla do estado da pessoa/participante vinculada com a nota fiscal (nota_fiscal.pessoa_id), se a
-- nota fiscal for de emiss�o de terceiro (nota_fiscal.dm_ind_emit=1).
-- Rotina: pkb_valida_cfop_por_dest.
--
-- Em 12/03/2018 - Angela In�s.
-- Redmine #40403 - Processo de gera��o de lote de nfs.
-- Alterar a gera��o dos Lotes de Notas Fiscais de Servi�o com rela��o a quantidade de NFS/RPS para cada lote gerado.
-- Rotinas: pkb_gera_lote_emissao_propria e pkb_gera_lote_emissao_terceiro.
--
-- Em 07/03/2018 - Angela In�s.
-- Redmine #40270 - Corre��o no processo de gera��o de Lote de Nota Fiscal de Servi�o.
-- Alterar a gera��o dos Lotes de Notas Fiscais de Servi�o com rela��o a quantidade de NFS/RPS para cada lote gerado.
-- Foi feita uma corre��o em 01/03, e a quantidade de NFS/RPS vinculado ao Lote ficou incoerente com o processo anterior, gerando diverg�ncia.
-- Rotinas: pkb_gera_lote_emissao_propria e pkb_gera_lote_emissao_terceiro.
--
-- Em 21/02/2018 - Marcelo Ono
-- Redmine #38773 - Corre��es e implementa��es nos processos do projeto REINF.
-- 1- Implementado processo para recuperar a informa��o de suspens�o de exibilidade de tributos do Processo Administrativo/Judici�rio da Empresa Matriz.
-- Rotina: pkb_integr_nf_proc_reinf.
--
-- Em 02/02/2018 - Karina de Paula
-- Redmine #39012 - Integra��o da nota fiscal de servi�o - valida��o do campo CNAE.
-- Incluida nova verifica��o para a valida��o do campo CNAE para a cidade de Campinas - Obj. alterado: (pkb_integr_itemnf_compl_serv)
--
-- Em 01/02/2018 - Angela In�s.
-- Redmine #39080 - Valida��o de Ambiente de Nota Fiscal Servi�o EFD por Job Scheduller.
-- Rotinas: pkb_gera_lote, pkb_gera_lote_emissao_terceiro, pkb_gera_lote_emissao_propria e pkb_excluir_lote_sem_nfs.
--
-- Em 16/01/2018 - Leandro Savenhago
-- Redmine #38534 - Carga de Dados de CEP Inicial e Final de Cidades
-- Rotina: pkb_integr_Nota_Fiscal_Dest
--
-- Em 16/01/2018 - Leandro Savenhago
-- Redmine #38511 - Represamento de NFSe
-- Represa a Emiss�o de NFse (N�o deixando gerar lote) se existir pendencia anterior de NFSe
--
-- Em 15/01/2018 - Karina de Paula
-- Redmine #38184 - Alterada a pkb_integr_nota_fiscal_serv_ff com a incluis�o do campo flex field nro_aut_nfs na rotina de valida��o
--
-- Em 08/01/2018 - Leandro Savenhago
-- Rotina: pkb_integr_Nota_Fiscal_Dest.
-- Verificado que o campo CIDADE_IBGE estava sendo informado como NULO, n�o validando os dados de CIDADE.
--
-- Em 05/01/2018 - Angela In�s.
-- Redmine #38202 - Gerar o registro de log para consistir o erro de valida��o da nota fiscal.
-- Rotina: pkb_valida_imposto_item.
--
-- Em 05/01/2018 - Angela In�s.
-- Redmine #38157 - Solicita��o referente a atividade #37893.
-- A primeira valida��o utilizando os par�metros como SIM, verifica se houveram registros de PIS e COFINS, nenhum ou mais de um. N�o existindo o registro
-- geramos as mensagens: "N�o informado o imposto de PIS para o item.", e, "N�o informado o imposto de COFINS para o item.". Neste caso, a mensagem fica como
-- informa��o geral, e n�o invalidamos a NFSE. Corre��o: Manter a mensagem e invalidar a NFSE, gerando erro de valida��o.
-- Rotina: pkb_valida_imposto_item.
--
-- Em 07/12/2017 - Angela In�s.
-- Redmine #34913 - Valida��o de NFSE, obriga existir os 2 impostos (PIS e COFINS).
-- 1) A primeira valida��o utilizando os par�metros como SIM, verifica se houveram registros de PIS e COFINS, nenhum ou mais de um. N�o existindo o registro
-- geramos as mensagens: "N�o informado o imposto de PIS para o item.", e, "N�o informado o imposto de COFINS para o item.". Neste caso, a mensagem fica como
-- erro de valida��o, e invalidamos a NFSE. Corre��o: Manter a mensagem, por�m n�o invalidar a NFSE.
-- 2) Na segunda valida��o relacionada ao imposto PIS, verificamos se tem o imposto da COFINS para comparar os valores de CST e Base de C�lculo, pois devem ser 
-- os mesmos. N�o existindo o imposto da COFINS, geramos a mensagem: "N�o informado o Imposto do COFINS.". Neste caso, a mensagem fica como erro de valida��o, e
-- invalidamos a NFSE. O mesmo tratamento � feito na valida��o do imposto da COFINS, com a mensagem: "N�o informado o Imposto do PIS.".
-- Corre��o: Alterar a mensagem para "N�o informado o Imposto da COFINS para comparar os valores de CST e Base de C�lculo.", e deixando como "Informa��o Geral",
-- n�o invalidando a NFSE. E alterar a mensagem da COFINS para "N�o informado o Imposto do PIS para comparar os valores de CST e Base de C�lculo.", e deixando
-- como "Informa��o Geral", n�o invalidando a NFSE.
-- Rotina: pkb_valida_imposto_item.
--
-- Em 30/11/2017 - Marcelo Ono
-- Redmine #36975 - Implementado processo na valida��o de CFOP por destinat�rio.
-- Se a UF do emitente for diferente da UF do destinat�rio e a UF do destinat�rio for "EX", dever� respeitar a seguinte regra:
-- Nota Fiscal com opera��o de Entrada: Primeiro d�gito do CFOP deve ser igual a 3.
-- Nota Fiscal com opera��o de Sa�da:   Primeiro d�gito do CFOP deve ser igual a 7.
-- Rotina: pkb_valida_cfop_por_dest.
--
-- Em 20/11/2017 - Angela In�s.
-- Redmine #36752 - Corre��o na valida��o do CFOP por Destinat�rio - Nota Fiscal de Servi�o.
-- Recuperar a sigla do estado do emitente da nota fiscal (nota_fiscal_emit), por�m se n�o houver emitente, recuperar a sigla do estado da empresa que emitiu a
-- nota fiscal (nota_fiscal.empresa_id/pessoa/cidade/estado.sigla_estado).
-- Rotina: pkb_valida_cfop_por_dest.
--
-- Em 20/11/2017 - Angela In�s.
-- Redmine #34618 - Utilizar o par�metro: "Valida Cfop por Destinat�rio" do cadastro para empresa para Validar NFSe.
-- Rotinas: pkb_param_nfs, pkb_consistem_nf e pkb_valida_cfop_por_dest.
--
-- Em 17/11/2017 - Marcos Garcia
-- Redmine 35993 - Implementa��o de Flex-Field VW_CSF_NF_CANC_SERV_FF.ID_ERP
-- Atividade para a leitura da view VW_CSF_NF_CANC_SERV_FF, mas atentando-se ao campo atributo com
-- o valor ID_ERP. Fazer valida��o conforme esse par�metro.
--
-- Em 08/11/2017 - F�bio Tavares
-- Redmine #36321 - Corre��o no processo de valida��o de notas fiscais de servi�o
-- Rotina: pkb_integr_nfs_detconstrcivil.
--
-- Em 07/11/2017 - Leandro Savenhago
-- Melhoria de desempenho de integra��o/valida��o de dados
-- Rotina: pkb_integr_Item_Nota_Fiscal.
--
-- Em 27/10/2017 - Marcelo Ono
-- Redmine #35937 - Inclus�o do par�metro de entrada empresa_id, para que seja filtrado a empresa do documento na execu��o das rotinas program�veis.
-- Rotina: pkb_consistem_nf.
--
-- Em 17/10/2017 - Angela In�s.
-- Redmine #35580 - Altera��o no processo de valida��o das Notas Fiscais de Servi�o.
-- 1) Identificar se a Empresa relacionada com a Nota Fiscal de Servi�o (nota_fiscal.empresa_id), est� indicando que existe agrupamento de Itens para o envio do
-- XML pelo RPS (empresa.dm_agrupa_item_xml_rps=1).
-- 2) N�o atendendo o item 2, o processo ser� finalizado sem valida��es.
-- 3) Atendendo ao item 2, fazer as seguinte valida��es:
-- 3.1) Os itens dever�o possuir o mesmo C�digo da Lista de Servi�o, mesmo c�digo de tributa��o do munic�pio (quando informado), mesmo IBGE de munic�pio e CNAE
-- (quando informado no complemento do servi�o) em todos os itens da NFSe. Caso contr�rio, gerar erro de valida��o para o usu�rio final informando que para
-- emiss�o de NFSe com mais de um item a regra acima deve ser atendida.
-- 3.2) Caso haja PIS Retido no RPS, em todos os itens a al�quota de PIS Retido dever� ser a mesma.
-- 3.3) Caso haja COFINS Retido no RPS, em todos os itens a al�quota de PIS Retido dever� ser a mesma.
-- 3.4) Caso haja INSS Retido no RPS, em todos os itens a al�quota de INSS Retido dever� ser a mesma.
-- 3.5) Caso haja IRRF Retido no RPS, em todos os itens a al�quota de IRRF Retido dever� ser a mesma.
-- 3.6) Caso haja CSLL Retido no RPS, em todos os itens a al�quota de CSLL Retido dever� ser a mesma.
-- 3.7) Caso haja ISS Retido no RPS, em todos os itens a al�quota de ISS Retido dever� ser a mesma.
-- 3.8) Caso haja ISS NORMAL no RPS, em todos os itens a al�quota de ISS NORMAL dever� ser a mesma.
-- 3.9) Caso haja outro imposto retido que n�o foi citado acima (outras reten��es), em todos os itens a al�quota desses impostos dever� ser a mesma conforme o
-- c�digo do imposto.
-- 3.10) Se o RPS possuir informa��es referente a constru��o civil (tabela - nfs_det_constr_civil) o valor dos campos cod_obra e nro_art dever� ser �nico, ou seja,
-- s� dever� haver um registro na tabela nfs_det_constr_civil para o RPS.
-- Rotina: pkb_consistem_nf/pkb_vld_xml_rps.
--
-- Em 10/10/2017 - Angela In�s.
-- Redmine #35374 - Inclus�o dos par�metros de valida��o dos Impostos PIS e COFINS para Notas Fiscais de Servi�o.
-- Rotina: pkb_valida_imposto_item.
--
-- Em 09/10/2017 - F�bio Tavares
-- Redmine #33828 - Integra��o Complementar de NFS para o Sped Reinf
-- Rotina: Adicionar as novas views do REINF
--
-- Em 25/08/2017 - Marcelo Ono.
-- Redmine #33869 - Valida se o participante est� cadastrado como empresa, se estiver cadastrado como empresa, n�o dever� atualizar os dados do participante
-- Rotina: pkb_reg_pessoa_dest_nf.
--
-- Em 17/08/2017 - Leandro Savenhago.
-- Gerar erro de valida��o se a empresa usu�ria estiver inativa
-- Rotina: pkb_integr_Nota_Fiscal_serv.
--
-- Em 08/08/2017 - Angela In�s.
-- Redmine #33149 - Defeito CSFTESTE 3 NFS-e.
-- 1) Atualizar/Gerar os impostos (imp_itemnf), somente se houver valores de servi�o maior ou igual a "valor m�nimo" parametrizado para a Natureza de Opera��o.
-- 2) Atualizar o C�digo de Tributa��o do Munic�pio (itemnf_compl_serv.codtribmunicipio_id), o Indicador de Origem de Cr�dito (itemnf_compl_serv.dm_ind_orig_cred),
-- e o CNAE (itemnf_compl_serv.cnae), no item da nota fiscal (itemnf_compl_serv), se atender ao item 1 (anterior).
-- 3) Atualizar, independente do item 1, nos itens da nota fiscal (item_nota_fiscal): Unidade de Medida de Tributa��o (unid_trib='UN'); Plano de Conta
-- (cod_cta=nat_oper_serv.planoconta_id); Identificador do CFOP (cfop_id=nat_oper_serv.cfop_id); e, c�digo do CFOP (cfop=cfop/nat_oper_serv.cfop_id).
-- 4) Atualizar, independente do item 1, nos itens da nota fiscal (itemnf_compl_serv): Base de C�lculo de Cr�dito de PIS/COFINS
-- (basecalccredpc_id=nat_oper_serv.basecalccredpc_id); Local de execu��o do servi�o (dm_loc_exe_serv=nat_oper_serv.dm_loc_exe_serv); e Centro de Custo
-- (centrocusto_id=nat_oper_serv.centrocusto_id).
-- 5) Atualizar, independente dos itens acima, na nota fiscal (nf_compl_serv): Natureza de Opera��o (dm_nat_oper=nat_oper_serv.dm_nat_oper, se for nulo considera
-- 1-Tributa��o no munic�pio).
-- 6) Atualizar, independente dos itens acima, na nota fiscal (nota_fiscal): Descri��o da Natureza de Opera��o, se estiver nula (nat_oper='NF Servico').
-- Rotina: pkb_gera_imposto_nfs.
--
-- Em 29/07/2017 - Leandro Savenhago.
-- Represar NFSe de Tabo�o da Serra com Pendencia
-- Rotina: pkb_gera_lote_emissao_propria.
--
-- Em 11/07/2017 - Angela In�s.
-- Redmine #32779 - Corre��o na valida��o de Totais de Notas Fiscais de Servi�o, e valores de Fatura e Duplicatas.
-- 1) Rotina pkb_atual_dados_cobr: atualizar as colunas: dm_ind_emit, dm_ind_tit e nro_fat; somente se estiverem nulos.
-- 2) Rotina pkb_vld_infor_dupl: incluir as valida��es de acordo com o processo de notas fiscais mercantis (pk_csf_api.pkb_valida_nf_cobr), adaptado para as notas
-- fiscais de servi�o (pk_csf_api_nfs). Valida��es a serem efetuadas:
-- 2.1) Verificar se o par�metro da natureza de opera��o/servi�o obriga que a nota possua duplicatas (nat_oper_serv.dm_obrig_vl_dup=1), neste caso, verificar se
-- foi informado fatura e duplicata, n�o sendo, gerar mensagem de log/inconsist�ncia informando que � necess�rio ter fatura e duplicata. A nota dever� ficar com
-- erro de valida��o.
-- 2.2) Verificar a quantidade de faturas relacionadas com a nota, e n�o permitir que possua mais que uma. Neste caso, gerar mensagem de log/inconsist�ncia
-- informando que n�o � poss�vel ter mais de uma fatura para a nota. A nota dever� ficar com erro de valida��o.
-- 2.3) Verificar se o Par�metro da empresa que indica se a fatura e as duplicatas devem ser validadas (empresa.dm_valid_cobr_nf=1). Neste caso:
-- 2.3.1) Recuperar o valor l�quido da fatura (nota_fiscal_cobr.vl_liq), recuperar o valor total da nota fiscal (nota_fiscal_total.vl_total_nf (menos)
-- nota_fiscal_total.vl_ret_prev). Se o valor l�quido da fatura for maior que zero e for diferente do valor total da nota fiscal, gerar mensagem de
-- log/inconsist�ncia informando que os valores est�o incorretos. A nota dever� ficar com erro de valida��o.
-- 2.3.2) Recuperar o valor l�quido da fatura (nota_fiscal_cobr.vl_liq), recuperar o valor total das duplicatas (nfcobr_dup.vl_dup). Se os valores estiverem
-- diferentes, gerar mensagem de log/inconsist�ncia informando que os valores est�o incorretos. A nota dever� ficar com erro de valida��o.
-- 2.4) Verificar se existe mais de uma duplicata com o mesmo n�mero de parcela, neste caso, gerar mensagem de log/inconsist�ncia informando que os valores est�o
-- incorretos. A nota dever� ficar com erro de valida��o.
-- 2.5) Verificar a quantidade de faturas/duplicatas relacionadas com a nota, e n�o permitir que possua mais que 120 duplicatas. Neste caso, gerar mensagem de 
-- log/inconsist�ncia informando que n�o � poss�vel ter mais que 120 duplicatas para a nota. A nota dever� ficar com erro de valida��o.
--
-- Em 26/01/2017 - Leandro Savenhago.
-- Redmine #23445 - Implementa��o da Package de Funcionalidade da Calculadora Fiscal
-- Alterar a integra��o de notas fiscais de servi�o, considerando o valor enviado no campo VW_CSF_NF_DEST_SERV.CIDADE_IBGE para o campo
-- NOTA_FISCAL_DEST.CIDADE_IBGE, quando a nota for de destinat�rio do Exterior.
-- Rotina: pkb_integr_nota_fiscal_dest.
--
-- Em 25/01/2017 - Angela In�s.
-- Redmine #27682 - Integra��o de NFServ - Campo CIDADE_IBGE - Destinat�rio.
-- Alterar a integra��o de notas fiscais de servi�o, considerando o valor enviado no campo VW_CSF_NF_DEST_SERV.CIDADE_IBGE para o campo
-- NOTA_FISCAL_DEST.CIDADE_IBGE, quando a nota for de destinat�rio do Exterior.
-- Rotina: pkb_integr_nota_fiscal_dest.
--
-- Em 25/10/2016 - Angela In�s.
-- Redmine #24701 - Corre��o na integra��o das Notas Fiscais de Servi�o - Descri��o de Tributos.
-- Incluir na descri��o dos tributos federais e municipais a informa��o referente a lei sobre esses assuntos.
-- Rotina: pkb_gerar_info_trib.
--
-- Em 16/09/2016 - Angela In�s.
-- Redmine #23467 - Alterar integra��o considerando dm_st_proc para preencher dm_legado.
-- Rotina: pkb_integr_nota_fiscal_serv.
--
-- Em 02/09/2016
-- Desenvolvedor: Marcos Garcia
-- Redmine #22304 - Alterar os processos de integra��o/valida��o.
-- Foi alterado a manipula��o dos campos Fone e Fax, por conta da altera��o dos mesmos em tabelas de integra��o.
--
-- Em 09/05/2016 - Rog�rio Silva.
-- Redmine #18352 - Integra��o de Informa��o Adicional com o Caractere PIPE e ENTER (\n)
--
-- Em 13/04/2016 - F�bio Tavares
-- Redmine #16793 - Melhoria nas mensagens dos processos flex-field.
--
-- Em 08/02/2016 - Rog�rio Silva
-- Redmine #13079 - Registro do N�mero do Lote de Integra��o Web-Service nos logs de valida��o
--
-- Em 14/12/2015 - Leandro Savenhago.
-- Redmine #13654 - REMOVER CARACTER ESPECIAL NOTA DE SERVI�O - CAMPO GRANDE
-- Rotina: pkb_integr_Nota_Fiscal_Dest
-- Retirada do caractere ":" dos dados do Tomador
--
-- Em 04/11/2015 - Leandro Savenhago.
-- Redmine #12648 - Lei de Transpar�ncia na NFS-e (UBM)
-- Implementada a rotina de gera��o da Informa��o de Lei da Transparencia de Impostos
--
-- Em 30/07/2015 - Rog�rio Silva.
-- Redmine #9832 - Altera��o do processo de Integra��o Open Interface Table/View
-- Redmine #8232 - Processo de Registro de Log em Packages - Notas Fiscais Mercantis
--
-- Em 28/07/2015 - Angela In�s.
-- Redmine #10117 - Escritura��o de documentos fiscais - Processos.
-- Inclus�o do novo conceito de recupera��o de data dos documentos fiscais para retorno dos registros.
--
-- Em 11/06/2015 - Rog�rio Silva.
--
-- Em 10/06/2015 - Leandro Savenhago.
-- Redmine #9117 - Registro de mensagem de cancelamento no log gen�rico
-- Rotina: pkb_integr_Nota_Fiscal_Canc
--
-- Em 02/06/2015 - Rog�rio Silva.
-- Redmine #8233 - Processo de Registro de Log em Packages - Notas Fiscais de Servi�os EFD
--
-- Em 14/04/2015 - Rog�rio Silva.
-- Redmine #7657 - ERRO VALIDA��O PATCH 2.6.5
-- Rotina: pkb_integr_Nota_Fiscal_serv
--
-- Em 18/03/2015 - Angela In�s.
-- Redmine #7122 - Avaliar Mult-Org: Inclus�o do identificador nas tabelas principais.
-- Rotina: pkb_reg_pessoa_dest_nf.
--
-- Em 04/03/2015 - Rog�rio Silva.
-- Redmine #6754 - Preparar o ambiente de testes da Cremer para emitir NFSe para Blumenau e acompanhar.
-- Rotina: pkb_gera_lote
--
-- Em 23/02/2015 - Rog�rio Silva.
-- Redmine #6510 - Criar valida��o CodTributCidade.
-- Rotina: pkb_integr_itemnf_compl_serv
--
-- Em 10/02/2015 - Angela In�s.
-- Redmine #6320 - Mensagem de aviso em empresa inativa na tela Convers�o de NFe Empresa/Terceiro.
-- Rotina: pkb_integr_Nota_Fiscal_serv.
--
-- Em 09/02/2015 - Rog�rio Silva.
-- Redmine #6260 - Informa��o adicional NFS - Integra��o de NF de Servi�o.
-- Rotina: pkb_valida_item_nota_fiscal
--
-- Em 05/02/2015 - Rog�rio Silva.
-- Redmine #6276 - Analisar os processos na qual a tabela CTRL_RESTR_PESSOA � utilizada.
-- Rotinas: pkb_integr_Nota_Fiscal_Dest.
--
-- Em 27/01/2015 - Rog�rio Silva.
-- Redmine #5896 - Valida��o de Inscri��o Municipal da empresa Emitente da NFSe
-- Rotina alterada: pkb_integr_nota_fiscal_serv
--
-- Em 23/01/2015 - Leandro Savenhago.
-- Redmine #6005 - Atribuido nulo aos valores de desconto da tabela ITEMNF_COMPL_SERV, caso o mesmo for menor ou igual a zero.
--
-- Em 08/01/2015 - Rog�rio Silva.
-- Redmine #5756 - Obrigatoriedade do Codigo de Tributacao do Municipio por cidade para NFSe
-- Rotina alterada: pkb_integr_itemnf_compl_serv
--
-- Em 06/01/2015 - Angela In�s.
-- Redmine #5616 - Adequa��o dos objetos que utilizam dos novos conceitos de Mult-Org.
--
-- Em 12/12/2014 - Leandro Savenhago
-- Redmine #5018 - Alterar os processos de integra��o NFe, CTe e NFSe (emiss�o pr�pria)
-- Rotina: pkb_gera_imposto_nfs
--
-- Em 18/11/2014 - Rog�rio Silva
-- Redmine #5018 - Alterar os processos de integra��o NFe, CTe e NFSe (emiss�o pr�pria)
-- Rotina: pkb_consistem_nf
--
-- Em 06/11/2014 - Rog�rio Silva
-- Redmine #5044 - Valida��o da obrigat�riedade do email para NFSe
--
-- Em 05/11/2014 - Rog�rio Silva
-- Redmine #5020 - Processo de contagem de registros integrados do ERP (Agendamento de integra��o)
--
-- Em 29/09/2014 - Angela In�s.
-- Redmine #4535 - Desconto IRRF em NFS-e. Altera��o na integra��o da Nota Fiscal de Servi�o.
-- 1) Alterar a integra��o de Nota Fiscal de Servi�o: nota_fiscal_total.vl_total_serv = soma(item_nota_fiscal.vl_item_bruto - item_nota_fiscal.vl_desc).
-- Rotina: pkb_gera_total_nfs.
--
-- Em 08/09/2014 - Angela In�s.
-- Redmine #4160 - Notas Fiscais de Servi�o sem Itens - Recuperar CFOP dos Par�metros de Natureza de Opera��o para Servi�os.
-- Corre��o: Ao integrar a nota fiscal de servi�o EFD, recuperar o c�digo de CFOP para o item da nota atrav�s dos par�metros de Natureza de Opera��o para
-- Servi�os (nat_oper_serv.cfop_id), caso esse par�metro n�o exista, manter o c�digo atual (cfop = 1000).
-- Rotina: pkb_integr_item_nota_fiscal.
--
-- Em 15/05/2014 - Angela In�s.
-- Redmine #2908 - Verificar relat�rios de impostos, de notas fiscais, de livros fiscais, sped fiscal e sped gia, que est�o com diferen�a nos valores.
-- Na integra��o da nota fiscal de servi�o ser� validado se o valor do item bruto � menor do que o valor do desconto, e a nota ficar� com erro de valida��o.
-- Rotina: pkb_integr_item_nota_fiscal.
--
-- Em 11/12/2013 - Angela In�s.
-- Corre��o das mensagens de erro.
--
-- Em 06/11/2013 - Angela In�s.
-- Redmine #1161 - Altera��o do processo de valida��o de valor dos documentos fiscais.
-- Inclus�o da recupera��o dos valores de toler�ncia atrav�s dos par�metros da empresa - utilizar a fun��o pk_csf.fkg_vlr_toler_empresa, e manter 0.03 como
-- valor de toler�ncia caso n�o exista o par�metro.
-- Rotinas: pkb_valida_imposto_item.
--
-- Em 17/09/2013 - Angela In�s.
-- Redmine #680 - Fun��o de valida��o dos documentos fiscais.
-- Invalidar a nota fiscal no processo de consist�ncia dos dados, se o objeto de refer�ncia for NOTA_FISCAL.
-- Rotina: pkb_consistem_nf.
--
-- Em 13/09/2013 - Angela In�s.
-- Comentar a chamada da rotina de valida��o de documentos fiscais.
--
-- Em 20/08/2013 - Angela In�s.
-- Redmine #451 - Valida��o de informa��es Fiscais - Ficha HD 66733.
-- Corre��o nas rotinas chamadas pela pkb_consistem_nf, eliminando as refer�ncias das vari�veis globais, pois essa rotina ser� chamada de outros processos.
-- Rotina: pkb_consistem_nf e todas as chamadas dentro dessa rotina.
-- Inclus�o da fun��o de valida��o dos conhecimentos de transporte, atrav�s dos processos de sped fiscal, contribui��es e gias.
-- Rotina: fkg_valida_nfs.
--
-- Em 15/08/2013 - Angela In�s.
-- Redmine #504 - Notas com diverg�ncia de sigla de estado da pessoa_id da nota com emitente ou destinat�rio.
-- Utiliza��o das rotinas: fkg_pessoa_id_cpf_cnpj, fkg_pessoa_id_cpf_cnpj_interno e fkg_pessoa_id_cpf_cnpj_uf
-- Rotinas: pkb_reg_pessoa_dest_nf.
--
-- Em 25/07/2013 - Angela In�s.
-- Redmine #404 - Leiautes: Nota Fiscal Mercantil, de Terceiros e Nota Fiscal de Servi�o.
-- Implementar no Imposto o flex-field para o "C�digo da Natureza de Receita".
--
-- Em 18/07/2013 - Angela In�s.
-- RedMine 58 - Ficha HD 66037 - Melhoria na valida��o de impostos de Nota Fiscal mercantil, separar a valida��o de "Emiss�o Pr�pria" e "Emiss�o de Terceiros".
-- Duplicar os par�metros para valida��o de impostos: icms, icms-60, ipi, pis, cofins.
-- Os que j� existem dever�o fazer parte da op��o Emiss�o Pr�pria, que s�o: DM_VALID_IMP, DM_VALID_ICMS60, DM_VALIDA_IPI, DM_VALIDA_PIS, DM_VALIDA_COFINS.
-- Os novos dever�o fazer parte da op��o Terceiros, ficando: DM_VALID_IMP_TERC, DM_VALID_ICMS60_TERC, DM_VALIDA_IPI_TERC, DM_VALIDA_PIS_TERC, DM_VALIDA_COFINS_TERC.
-- Rotina: pkb_valida_imposto_item.
--
-- Em 26/09/2012 - Angela In�s.
-- Alterar os nomes das FKB para FKG, nas rotinas de campos FF - Flex Field.
--
-- Em 17/09/2012 - Angela In�s - Ficha HD 63072.
-- 1) Inclus�o do processo de integra��o de Impostos Retidos - Processo Flex Field (FF).
--
-- Em 03/09/2012 - Angela In�s.
-- 1) Eliminar os espa�os a direita e a esquerda da coluna SERIE.
--
--------------------------------------------------------------------------------------------------------------------------------
--
   gt_row_nota_fiscal            nota_fiscal%rowtype;
   gt_row_nf_compl_serv          nf_compl_serv%rowtype;
   gt_row_nfs_det_constr_civil   nfs_det_constr_civil%rowtype;
   gt_row_nf_inter_serv          nf_inter_Serv%rowtype;
   gt_row_nota_fiscal_dest       nota_fiscal_dest%rowtype;
   gt_row_nfinfor_adic           nfinfor_adic%rowtype;
   gt_row_imp_Itemnf             imp_itemnf%rowtype;
   gt_row_imp_adic_apos_esp_serv imp_adic_aposent_esp%rowtype;
   gt_row_itemnf_compl_serv      itemnf_compl_serv%rowtype;
   gt_row_item_nota_fiscal       item_nota_fiscal%rowtype;
   gt_row_nota_fiscal_cobr       nota_fiscal_cobr%rowtype;
   gt_row_nfcobr_dup             nfcobr_dup%rowtype;
   gt_row_Nota_Fiscal_Canc       nota_fiscal_canc%rowtype;
   gt_row_nat_oper_serv          nat_oper_serv%rowtype;
   gt_row_nota_fiscal_compl      nota_fiscal_compl%rowtype;
   gt_row_nf_proc_reinf          nf_proc_reinf%rowtype;
--
-------------------------------------------------------------------------------------------------------
--
   gt_row_empresa             Empresa%rowtype;
   gt_row_unid_org            Unid_Org%rowtype;
   gt_row_usuempr_unidorg     usuempr_unidorg%rowtype;
--
-------------------------------------------------------------------------------------------------------

   gv_cabec_log               log_generico_nf.mensagem%TYPE;
   gv_mensagem_log            log_generico_nf.mensagem%TYPE;
   gv_cabec_log_item          log_generico_nf.mensagem%TYPE;
   gv_dominio                 Dominio.descr%TYPE;
   --
   gn_dm_tp_amb               Empresa.dm_tp_amb%TYPE := null;
   gn_empresa_id              Empresa.id%type := null;
   --
   gn_processo_id             log_generico_nf.processo_id%TYPE := null;
   gv_obj_referencia          log_generico_nf.obj_referencia%type default 'NOTA_FISCAL';
   gn_referencia_id           log_generico_nf.referencia_id%type := null;
   gn_tipo_integr             number;
   --
   gn_dm_st_proc              nota_fiscal.dm_st_proc%type;
   gn_pessoa_id               pessoa.id%type;
   gd_dt_emiss                nota_fiscal.dt_emiss%type;
   gn_cidade_id_prestador     cidade.id%type;
   gn_cidade_id_tomador       cidade.id%type;
   gv_simplesnacional         valor_tipo_param.cd%type := null;
   gv_cd_obj                  obj_integr.cd%type := '7';
   gn_dm_dt_escr_dfepoe       empresa.dm_dt_escr_dfepoe%type;
   gn_dm_valida_cfop_por_dest empresa.dm_valida_cfop_por_dest%type;
   gn_dm_ind_emit             nota_fiscal.dm_ind_emit%type;
   gn_dm_ind_oper             nota_fiscal.dm_ind_oper%type;
   gn_dm_agrupa_item_xml_rps  cidade_nfse.dm_agrupa_item_xml_rps%type;
   gn_modfiscal_id            nota_fiscal.modfiscal_id%type;
   --gv_ibge_cidade_empr        cidade.ibge_cidade%type;
   --gv_cod_mod                 mod_fiscal.cod_mod%type;
   --
   gv_objeto                  varchar2(300);
   gn_fase                    number;
   --
-------------------------------------------------------------------------------------------------------

-- Declara��o de constantes

   ERRO_DE_VALIDACAO              CONSTANT NUMBER := 1;
   ERRO_DE_SISTEMA                CONSTANT NUMBER := 2;
   NOTA_FISCAL_INTEGRADA          CONSTANT NUMBER := 16;
   INFO_CANC_NFE                  CONSTANT NUMBER := 31;
   INFORMACAO                     CONSTANT NUMBER := 35;
   INFO_CALC_FISCAL               constant number := 38;

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

--| Procedimento seta o "ID de Referencia" utilizado na Valida��o da Informa��o
procedure pkb_seta_referencia_id ( en_id in number );

-------------------------------------------------------------------------------------------------------

-- Procedimento armazena o valor do "loggenericonf_id" da nota fiscal de servico

procedure pkb_gt_log_generico_nf ( en_loggenericonf_id   in             log_generico_nf.id%TYPE
                                 , est_log_generico_nf   in out nocopy  dbms_sql.number_table );

-------------------------------------------------------------------------------------------------------

--| Procedimento finaliza o Log Gen�rico

procedure pkb_finaliza_log_generico_nf;

-------------------------------------------------------------------------------------------------------

--| Procedimento de registro de log de erros na valida��o da nota fiscal de servico

procedure pkb_log_generico_nf ( sn_loggenericonf_id   out nocopy log_generico_nf.id%TYPE
                              , ev_mensagem           in         log_generico_nf.mensagem%TYPE
                              , ev_resumo             in         log_generico_nf.resumo%TYPE
                              , en_tipo_log           in         csf_tipo_log.cd_compat%type      default 1
                              , en_referencia_id      in         log_generico_nf.referencia_id%TYPE  default null
                              , ev_obj_referencia     in         log_generico_nf.obj_referencia%TYPE default null
                              , en_empresa_id         in         Empresa.Id%type                  default null
                              , en_dm_impressa        in         log_generico_nf.dm_impressa%type    default 0 );

-----------------------------------------------------------------------------------------------------------------------------
-- Essa fun��o n�o deve estar dispon�vel para acesso externo, somente no contexto desse processo
--| Fun��o cria o Lote de Envio da Nota Fiscal Servico e retorna o ID
--
--function fkg_integr_lote ( est_log_generico_nf     in out nocopy  dbms_sql.number_table
--                         , en_lotenfs_id           in lote_nfs.id%type
--                         , en_qtde_nfs             in number
--                         , en_empresa_id           in             Empresa.id%TYPE
--                         , en_dm_ind_emit          in             lote_nfs.dm_ind_emit%type
--                         )
--         return lote_nfs.id%TYPE;
--
-------------------------------------------------------------------------------------------------------

-- Processo de cria��o do Lote de Notas Fiscais de Servico

procedure pkb_gera_lote ( en_multorg_id  in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

--| Procedimento de Integra��o de informa��es de Processos Administrativos/Judiciarios do REINF vinculado com notas fiscais de servi�o

procedure pkb_integr_nf_proc_reinf ( est_log_generico_nf          in out nocopy dbms_sql.number_table
                                   , est_row_nf_proc_reinf        in out nocopy nf_proc_reinf%rowtype
                                   , en_empresa_id                in            empresa.id%type
                                   , ed_dt_emiss                  in            date
                                   , en_dm_tp_proc                in            proc_adm_efd_reinf.dm_tp_proc%type
                                   , ev_nro_proc                  in            proc_adm_efd_reinf.nro_proc%type
                                   , en_cod_susp                  in            proc_adm_efd_reinf_inf_trib.cod_susp%type
                                   );

-------------------------------------------------------------------------------------------------------

--| Procedimento que faz a integra��o as Notas Fiscais Cancelas

procedure pkb_integr_Nota_Fiscal_Canc ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                      , est_row_Nota_Fiscal_Canc  in out nocopy  Nota_Fiscal_Canc%rowtype
                                      , en_multorg_id             in             mult_org.id%type
                                      , en_loteintws_id           in             lote_int_ws.id%type default 0
                                      );

-------------------------------------------------------------------------------------------------------

--| Procedimento de integra��o do complemento da nota fiscal de servi�o - CAMPO ID_ERP
procedure pkb_integr_nota_fiscal_compl ( est_log_generico_nf          in out nocopy dbms_sql.number_table
                                       , est_row_nota_fiscal_compl in out nocopy nota_fiscal_compl%rowtype
                                       );

-------------------------------------------------------------------------------------------------------

-- Integra informa��es da Duplicata de cobran�a
procedure pkb_integr_NFCobr_Dup ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                                , est_row_NFCobr_Dup        in out nocopy  NFCobr_Dup%rowtype
                                , en_notafiscal_id          in             Nota_Fiscal.id%TYPE 
                                );

-------------------------------------------------------------------------------------------------------

-- Integra informa��es da cobran�a da Nota Fiscal
procedure pkb_integr_Nota_Fiscal_Cobr ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                                      , est_row_Nota_Fiscal_Cobr  in out nocopy  Nota_Fiscal_Cobr%rowtype 
                                      );

-------------------------------------------------------------------------------------------------------

-- Integra as informa��es do Destinat�rio da Nota Fiscal

--| A API de integra��o do destinat�rio da NFe, ir� verificar se houve algum erro de integra��o com os dados informados
--| do destinat�rio, caso exista erro, verifica se a empresa "Utiliza o Endere�o de Faturamento do Destinat�rio para emiss�o de NFe",
--| se utiliza, o endere�o errado ser� substituido pelo registrado no Compliance NFe (Cadastro de Pessoas)

procedure pkb_integr_Nota_Fiscal_Dest ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                      , est_row_Nota_Fiscal_Dest  in out nocopy  Nota_Fiscal_Dest%rowtype
                                      , ev_cod_part               in             pessoa.cod_part%type
                                      , en_multorg_id             in             mult_org.id%type
                                      , en_cid                    in             number );


-------------------------------------------------------------------------------------------------------

-- Integra as informa��es adicionais da Nota Fiscal
procedure pkb_integr_NFInfor_Adic ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                                  , est_row_NFInfor_Adic      in out nocopy  NFInfor_Adic%rowtype
                                  , en_cd_orig_proc           in             Orig_Proc.cd%TYPE default null
                                  );

-------------------------------------------------------------------------------------------------------

-- Integra as informa��o de detalhamento de servi�os prestados na constru��o civil

procedure pkb_integr_nfs_detconstrcivil ( est_log_generico_nf                 in out nocopy  dbms_sql.number_table
                                        , est_row_nfs_det_constr_civil     in out nocopy  nfs_det_constr_civil%rowtype
                                        );

-------------------------------------------------------------------------------------------------------

-- Integra as informa��es do intermedi�rio do servi�o

procedure pkb_integr_nf_inter_serv ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                                   , est_row_nf_inter_serv     in out nocopy  nf_inter_serv%rowtype
                                   );

-------------------------------------------------------------------------------------------------------

-- Integra as informa��es de impostos do Item da Nota Fiscal
procedure pkb_integr_Imp_ItemNf ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                                , est_row_Imp_ItemNf        in out nocopy  Imp_ItemNf%rowtype
                                , en_cd_imp                 in             Tipo_Imposto.cd%TYPE
                                , ev_cod_st                 in             Cod_ST.cod_st%TYPE
                                , en_notafiscal_id          in             Nota_Fiscal.id%TYPE
                                );

-------------------------------------------------------------------------------------------------------

-- Integra as informa��es de impostos do Item da Nota Fiscal - processo FF - impostos retidos
procedure pkb_integr_imp_itemnf_ff ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                                   , en_impitemnf_id  in             imp_itemnf.id%type
                                   , en_tipoimp_id    in             tipo_imposto.id%type
                                   , en_cd_imp        in             tipo_imposto.cd%type
                                   , ev_atributo      in             varchar2
                                   , ev_valor         in             varchar2
                                   , en_multorg_id    in             mult_org.id%type
                                   );
                                   
-------------------------------------------------------------------------------------------------------

-- Integra as informa��es de impostos adicionais de aposentadoria especial
procedure pkb_int_imp_adic_apos_esp_serv ( est_log_generico_nf            in out nocopy  dbms_sql.number_table
                                         , est_row_imp_adic_apos_esp_serv in out nocopy  imp_adic_aposent_esp%rowtype
                                         , en_cd_imp                      in             tipo_imposto.cd%type
                                         );

-------------------------------------------------------------------------------------------------------

--| Procedimento de integra��o do complemento dos itens da nota fiscal de servi�o
procedure pkb_integr_itemnf_compl_serv ( est_log_generico_nf          in out nocopy dbms_sql.number_table
                                       , est_row_nfserv_item_compl in out nocopy itemnf_compl_serv%rowtype
                                       , en_notafiscal_id          in            nota_fiscal.id%type
                                       , ev_cod_bc_cred_pc         in            base_calc_cred_pc.cd%type
                                       , ev_cod_ccus               in            centro_custo.cod_ccus%type
                                       , ev_cod_trib_municipio     in            cod_trib_municipio.cod_trib_municipio%type default null
                                       );
                                       
-------------------------------------------------------------------------------------------------------

-- Integra as informa��es do complemento dos Itens da Nota Fiscal de servi�o - campos flex field
procedure pkb_int_itemnf_compl_serv_ff ( est_log_generico_nf   in out nocopy  dbms_sql.number_table
                                       , en_notafiscal_id      in             nota_fiscal.id%type
                                       , en_itemnf_id          in             item_nota_fiscal.id%type
                                       , ev_atributo           in             varchar2
                                       , ev_valor              in             varchar2 
                                       );

-------------------------------------------------------------------------------------------------------

-- Integra as informa��es dos itens da nota fiscal
procedure pkb_integr_Item_Nota_Fiscal ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                                      , est_row_Item_Nota_Fiscal  in out nocopy  Item_Nota_Fiscal%rowtype 
                                      );

-------------------------------------------------------------------------------------------------------

--| Procedimento de integra��o da nota fiscal de servi�o - complemento de servi�o
procedure pkb_integr_nf_compl_serv ( est_log_generico_nf     in out nocopy dbms_sql.number_table
                                   , est_row_nfserv_compl in out nocopy nf_compl_serv%rowtype
                                   );
                                   
-------------------------------------------------------------------------------------------------------

--| Procedimento que faz valida��es na Nota Fiscal de servi�o e grava na CSF - Campos Flex Field
procedure pkb_integr_nota_fiscal_serv_ff ( est_log_generico_nf     in out nocopy  dbms_sql.number_table
                                         , en_notafiscal_id        in             nota_fiscal.id%type
                                         , ev_atributo             in             varchar2
                                         , ev_valor                in             varchar2
                                         );

-------------------------------------------------------------------------------------------------------

--| Procedimento que faz valida��es na Nota Fiscal e grava na CSF
procedure pkb_integr_Nota_Fiscal_serv ( est_log_generico_nf        in out nocopy  dbms_sql.number_table
                                      , est_row_Nota_Fiscal        in out nocopy  Nota_Fiscal%rowtype
                                      , ev_cod_mod                 in             Mod_Fiscal.cod_mod%TYPE
                                      , ev_empresa_cpf_cnpj        in             varchar2                 default null -- CPF/CNPJ da empresa
                                      , ev_cod_part                in             Pessoa.cod_part%TYPE     default null
                                      , ev_cd_sitdocto             in             Sit_Docto.cd%TYPE        default null
                                      , ev_sist_orig               in             sist_orig.sigla%type     default null
                                      , ev_cod_unid_org            in             unid_org.cd%type         default null
                                      , en_multorg_id              in             mult_org.id%type
                                      , en_empresaintegrbanco_id   in             empresa_integr_banco.id%type default null
                                      , en_loteintws_id            in             lote_int_ws.id%type default 0
                                      );

-------------------------------------------------------------------------------------------------------

-- procedimento para criar o registro de total da Nota Fiscal de Servi�o
procedure pkb_gera_total_nfs ( en_notafiscal_id  in nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

--| Procedimento para desfazer a �ltima situa��o da NFS

procedure pkb_desfazer ( en_notafiscal_id  in nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------
-- Procedimento Solicita o Calculo dos Impostos
procedure pkb_solic_calc_imp ( est_log_generico_nf  in out nocopy dbms_sql.number_table
                             , en_notafiscal_id     in            nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------
--| Procedimento para processar uma Nota Fiscal de Servi�o
-- o processo dever� c�lcular os impostos e reten��es e validar a informa��o

procedure pkb_processar ( en_notafiscal_id  in nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedure que consiste os dados da Nota Fiscal

procedure pkb_consistem_nf ( est_log_generico_nf     in out nocopy  dbms_sql.number_table
                           , en_notafiscal_id     in             Nota_Fiscal.Id%TYPE 
                           );

-------------------------------------------------------------------------------------------------------
-- Fun��o para validar Notas fiscais de Servi�o - utilizada nas rotinas de valida��es da GIA, Sped Fiscal e Contribui��es
function fkg_valida_nfs ( en_empresa_id      in  empresa.id%type
                        , ed_dt_ini          in  date
                        , ed_dt_fin          in  date
                        , ev_obj_referencia  in  log_generico_nf.obj_referencia%type -- processo que acessa a fun��o: sped ou gia
                        , en_referencia_id   in  log_generico_nf.referencia_id%type ) -- identificador do processo que acessar: sped ou gia
         return boolean;

-------------------------------------------------------------------------------------------------------

--Procedimento que retorna os valores fiscais de um item de nota fiscal de servi�o

procedure pkb_vlr_fiscal_item_nfs ( en_itemnf_id           in   item_nota_fiscal.id%type
                                  , sn_cfop                out  cfop.cd%type
                                  , sn_vl_operacao         out  number
                                  );

-------------------------------------------------------------------------------------------------------

procedure pkb_ret_multorg_id( est_log_generico       in out nocopy  dbms_sql.number_table
                            , ev_cod_mult_org        in             mult_org.cd%type
                            , ev_hash_mult_org       in             mult_org.hash%type
                            , sn_multorg_id          in out nocopy  mult_org.id%type
                            , ev_obj_referencia      in             log_generico_nf.obj_referencia%type
                            , en_referencia_id       in             log_generico_nf.referencia_id%type
                            );

-------------------------------------------------------------------------------------------------------

-- Procedimento valida o mult org de acordo com o COD e o HASH das tabelas Flex-Field

procedure pkb_val_atrib_multorg ( est_log_generico   in out nocopy  dbms_sql.number_table
                                , ev_obj_name        in             VARCHAR2
                                , ev_atributo        in             VARCHAR2
                                , ev_valor           in             VARCHAR2
                                , sv_cod_mult_org    out            VARCHAR2
                                , sv_hash_mult_org   out            VARCHAR2
                                , ev_obj_referencia  in             log_generico_nf.obj_referencia%type
                                , en_referencia_id   in             log_generico_nf.referencia_id%type
                                );


-------------------------------------------------------------------------------------------------------

-- Processo que valida e integra nota fiscal de cancelamento, a partir do atributo ID_ERP
procedure pkb_val_integr_nf_canc_ff ( est_log_generico_nf  in out nocopy dbms_sql.number_table
                                    , en_notafiscalcanc_id in number
                                    , ev_atributo          in varchar2
                                    , ev_valor             in varchar2
                                    );
----------------------------------------------------------------------------
-- Fun��o para verificar se existe registro de erro grvados no Log Generico

function fkg_ver_erro_log_generico_nfs( en_nota_fiscal_id in nota_fiscal.id%type )
         return number;

-------------------------------------------------------------------------------------------------------

--Procedimento que retorna os valores fiscais de um item de nota fiscal de servi�o SOMENTE para o declan-rj

procedure pkb_vlr_fiscal_item_nfs_declan ( en_itemnf_id           in   item_nota_fiscal.id%type
                                         , sn_cfop                out  cfop.cd%type
                                         , sn_vl_operacao         out  number
                                          );
-------------------------------------------------------------------------------------------------------                                 
end pk_csf_api_nfs;
/
