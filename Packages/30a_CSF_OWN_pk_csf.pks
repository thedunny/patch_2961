create or replace package csf_own.pk_csf is
--
---------------------------------------------------------------------------------------------------------------------------------------------------------
-- Especifica��o do pacote de fun��es para o CSF
--
-- Em 30/12/2020 - Marcos Ferreira
-- Distribui��es: 2.9.7 / 2.9.6-1 / 2.9.5-4
-- Redmine #74754: Criar procedure para cria��o de dom�nio
-- Rotinas Alteradas: Cria��o da procedure pkb_cria_dominio e fkg_parametro_geral_sistema
--
-- Em 21/07/2020 - Luis Marques - 2.9.4-1 / 2.9.5
-- Redmine #68300 - Falha na integra��o & "E" comercial - WEBSERVICE NFE EMISSAO PROPRIA (OCQ)
-- Rotina Alterada - fkg_converte - Foi criado o valor 4 para o parametro "en_ret_carac_espec" que retira os caracteres
--                   especiais mas mantem o caracter & (E comercial).
--
-- Em 06/07/2020 - Allan Magrini
-- Redmine #65449 - Remo��o de caracteres especiais.
-- Foi alterada a regra dos caracteres que est�o entre parenteses (� > < " � � &) . Esse tratamento s� deve ser feito quando parametro ret_carac_espec = 3.  
-- Rotina Alterada: fkg_converte
--
-- Em 18/05/2020 - Allan Magrini
-- Redmine #65449 - Ajustes em integra��o e valida��o 
-- Foi permitido que sejam integrados os caracteres que est�o entre parenteses (� > < " � � &) . Esse tratamento s� deve ser feito quando parametro ret_carac_espec = 2 (Nfe).  
-- Rotina Alterada: fkg_converte
--
-- Em 13/03/2020 - Allan Magrini
-- Redmine #65711 - Informa��es Adicionais de NFSE n�o est� pulando linhas 
-- Adicionado en_ret_chr10 para valida��o de chr10 de notas de servi�o vindo da pk_csf_api_nfs, demais convers�es n�o ter�o altera��es
-- Rotina Alterada: fkg_converte
--
-- Em 12/02/20120 - Marcos Ferreira
-- Redmine #64831: Cria��o de procedure para cria��o de sequence e inclus�o na seq_tab
-- Rotina: pkb_cria_sequence
-- Altera��es: Cria��o de procedure para cria��o da sequence e inclus�o na seq_tab
--
-- Em 07/02/2020 - Allan Magrini
-- Redmine #60926 - Falha na chamada da pk_csf.fkg_empresa_id_cpf_cnpj (ACECO)
-- Altera��o: Incluido dm_situacao = 1 da tabela empresa para retornar somente empresa ativa
-- Rotina: fkg_empresa_id_cpf_cnpj
--
-- Em 24/01/2020 - Marcos Ferreira
-- Redmine #63891 - Customiza��o no processo de Gera��o de Danfe 01_CR060_ENGIE_DANFE_V3
-- Rotina: fkg_String_dupl
-- Altera��o: Inclus�o de checagem de parametro e exibi��o da descri��o do t�tulo no campo Fatura da Danfe
--
-- Em 23/01/2020 - Marcos Ferreira
-- Redmine #60926 - Verificar processo pk_csf.fkg_converte - NFINFOR_ADIC.CONTEUDO (USV)
-- Rotina: fkg_converte
-- Altera��o: Ajustado Caracteres especiais
--
-- Em 15/01/2020 - Eduardo Linden
-- Redmine #63141 - Ajuste para emiss�o Florianopolis
-- Cria��o da function que retorna o ID da Tabela COD_ST_CIDADE
-- Rotina Criada: fkg_codstcidade_Id
--
-- Em 07/01/2020 - Allan Magrini
-- Redmine #63050 - feed - n�o est� sendo exibido a mensagem de valida��o referente a data e o modelo
-- Adicionado o return vn_qtde_lac_aquav na fun��o
-- Rotina Alterada: fkg_valid_lacre_aquav
--
-- Em 07/01/2020 - Eduardo Linden
-- Redmine #63309 - Feed - gera��o do m400/M800
-- Cria��o de nova function retorna o primeiro ID do plano de conta do Tabela plano_conta_nat_rec_pc .
-- Rotina criada: fkg_plcnatpecpc_plc_id
--
-- Em 03/01/2020 - Eduardo Linden
-- Redmine #63246 - Altera��o da gera��o do M400/M800 a partir do F500/F550
-- Cria��o de nova function para obter o id da tabela NAT_PEC_PC
-- Rotina criada: fkg_natrecpc_id
--
-- Em 20/12/2019 - Luis Marques
-- Redmine #62274 - CNAE
-- Fun��o alterada: fkg_id_cnae_cd - retirado do campo "cd" na tabela cnae os caractesres ".-/" ponto, tra�o e barra para 
--                  pesquisa do id do cnae visto que na tela o campo � de 7 digitos e s� aceita numeros.
--
-- Em 18/12/2019 - Allan Magrini
-- Redmine #61174 - Inclus�o de modelo de documento 66
-- Adicionado '66' na valida��o do cod_mod, notas de sevi�os continuos, fase 6 e 11
-- Rotina: fkg_busca_notafiscal_id
--
-- Em 10/12/2019 - Eduardo Linden
-- Redmine #62393 - Problema no SPED PIS/COFINS
-- Tratamento para evitar erro ORA-01422: exact fecth returns more than requested number of rows.
-- Rotina Alterada: fkg_ncmnatrecpc_plc_id
--
-- Em 06/11/2019 - Eduardo Linden
-- Redmine #57982 - [PLSQL] Gera��o do M400/800 a partir do F500
-- Criadas novas functions para :
-- 1) retorno da planoconta_id das tabelas nat_rec_pc e ncm_nat_rec_pc.
-- 2) retorno ID do Tabela NAT_PEC_PC a partir da tabela NCM_NAT_REC_PC
-- Rotinas Criadas : fkg_natrecpc_plc_id , fkg_ncmnatrecpc_plc_id e fkg_ncmnatrecpc_npp_id.
--
-- Em 05/11/2019        - Karina de Paula
-- Redmine #60526	- Retorno de NFe - Open Interface
-- Rotinas Alteradas    - fkg_empresa_id_cpf_cnpj => Alterada a busca do id da empresa
-- N�O ALTERE A REGRA DESSAS ROTINAS SEM CONVERSAR COM EQUIPE
--
-- Em 09/10/2019        - Karina de Paula
-- Redmine #52654/59814 - Alterar todas as buscar na tabela PESSOA para retornar o MAX ID
-- Rotinas Alteradas    - fkg_Pessoa_id_cpf_cnpj / fkg_cnpj_empresa_id(EXCLU�DA) / fkg_Pessoa_id_cpf_cnpj_interno(EXCLU�DA)
-- Obs1.: As functions fkg_Pessoa_id_cpf_cnpj_interno e fkg_Pessoa_id_cpf_cnpj  eram iguais ent�o foi deixada somente a fkg_Pessoa_id_cpf_cnpj
-- Obs2.: As functions fkg_cnpj_empresa_id            e fkg_empresa_id_cpf_cnpj eram iguais ent�o foi deixada somente a fkg_empresa_id_cpf_cnpj
-- N�O ALTERE A REGRA DESSAS ROTINAS SEM CONVERSAR COM EQUIPE
--
-- Em 05/09/2019   - Karina de Paula
-- Redmine #58459  - N�o est� integrando mais de um item de servi�o
-- Rotina Alterada - fkg_existe_item_nota_fiscal => Exclu�da a verifica��o pk_csf.fkg_existe_item_nota_fiscal porque podemos ter mais
--                   de um item para a nota fiscal de servi�o. Criada a verifica��o de duplica��o da nota_fiscal_cobr (vn_nfcobr_id),
--                   para tratar a atividade 56740 que criou inicialmente a pk_csf.fkg_existe_item_nota_fiscal.
--
-- Em 02/09/2019 - Karina de Paula
-- Redmine 41413 - Lentid�o para execu��o da PK_INTEGR_VIEW_NFS e pk_valida_ambiente_nfs (UNIP)
-- Rotina Criada: pkb_ret_dados_empresa => Procedure retorna dados da empresa
--
-- Em 30/08/2019 - Luis Marques
-- Redmine #57715 - Alterar fun��o para integra��o de caracteres permitidos na NF-e
-- Function alterada: fkg_converte
-- Liberado todos caracteres para NF-e deixando bloqueado apenas os que d�o erro de parse conforme manual, parametro
-- 'en_ret_carac_espec' passar 2
--
-- Em 21/08/2019 - Eduardo Linden
-- Redmine #50987 - Exclus�o de Notas Fiscais e CTE vinculados ao REINF
-- Cria��o das fun��es para validar se Nota Fiscal est� submetida ou n�o aos eventos R-2010 e R-2020 do Reinf.
-- Rotina criada: fkg_existe_reinf_r2010_nf e fkg_existe_reinf_r2020_nf
--
-- Em 19/08/2019 - Luis Marques
-- Redmine #56740 - defeito - Nota est� ficando com erro de valida��o na duplicidade - Release 291
-- Nova Function: fkg_existe_item_nota_fiscal
--
-- Em 21/07/2019 - Luis Marques
-- Redmine # 56565
-- Nova Functions: fkg_empresa_dmvalpis_emis_nfs, fkg_empresa_dmvalpis_terc_nfs
--                 fkg_empr_dmvalcofins_emis_nfs, fkg_empr_dmvalcofins_terc_nfs
--
-- Em 26/06/2019 - Luiz Armando Azoni.
-- Redmine #52815
-- Adequa��o do processo para recuperar a quantidade a ser impressa.
-- procedure: pkb_impressora_id_serie.
--
-- Em 26/06/2019 - Luiz Armando Azoni.
-- Redmine #55659
-- Inclus�o da fun��o fkg_impressora_id_serie que recupera o valor da impressora_id para registra na nota fiscal.
--
-- Em 20/03/2012 - Angela In�s.
-- Inclus�o da fun��o para validar d�gito verificador da chave de acesso da nota fiscal eletr�nica ou conhecimento de transporte
--
-- Em 20/03/2012 - Angela In�s.
-- Exclus�o da fun��o para validar d�gito verificador da chave de acesso da nota fiscal eletr�nica ou conhecimento de transporte
-- Esse processo deve ser uma fun��o isolada dos procedimentos da Compliance.
--
-- Em 09/04/2012 - Angela In�s.
-- Altera��o na fun��o que recupera identificador do plano de contas - fkg_Plano_Conta_id.
-- Recuperar o identificador da conta pela empresa enviada no par�metro, e caso n�o exista, recuperar da empresa matriz.
--
-- Em 17/05/2012 - Angela In�s.
-- Inclus�o de fun��o para retornar par�metro da empresa de valida��o de CFOP por destinat�rio - fkg_dm_valcfoppordest_empresa.
--
-- Em 18/05/2012 - Angela In�s.
-- Inclus�o de fun��o para retornar indicador de opera��o da nota fiscal - nota_fiscal.dm_ind_oper -> 0-entrada, 1-sa�da - fkg_recup_dmindoper_nf_id.
--
-- Em 05/07/2012 - Angela In�s.
-- Inclus�o de fun��o para retornar o identificador do modelo fiscal da nota fiscal - nota_fiscal.modfiscal_id - atrav�s do identificador da nota fiscal.
-- Rotina fkg_recup_modfisc_id_nf.
--
-- Em 25/07/2012 - Angela In�s.
-- Inclus�o de fun��o para retornar se a empresa permite valida��o de cfop de cr�dito de pis/cofins para notas fiscais de pessoa f�sica.
-- Rotina: fkg_empr_val_cred_pf_pc.
--
-- Em 13/09/2012 - Angela In�s.
-- Corre��o na declara��o da vari�vel (utilizando 'in') - Fun��o retorna o ID da tabela Tipo_Servico - fkg_Tipo_Servico_id.
--
-- Em 19/09/2012 - Angela In�s.
-- Inclus�o da fun��o para verificar campos Flex Field - FF.
-- Rotina: fkg_ff_verif_campos.
-- Inclus�o da fun��o para retornar o dom�nio - tipo do campo Flex Field - FF, atrav�s do objeto e do atributo.
-- Rotina: fkg_ff_retorna_dmtipocampo
-- Inclus�o da fun��o para retornar o tamanho do campo Flex Field - FF, atrav�s do objeto e do atributo.
-- Rotina: fkg_ff_retorna_tamanho
-- Inclus�o da fun��o para retornar a quantidade em decimal do campo Flex Field - FF, atrav�s do objeto e do atributo.
-- Rotina: fkg_ff_retorna_decimal
-- Inclus�o da fun��o para retornar o valor dos campos Flex Field - FF - tipo DATA.
-- Rotina: fkg_ff_ret_vlr_data
-- Inclus�o da fun��o para retornar o valor dos campos Flex Field - FF - tipo NUM�RICO.
-- Rotina: fkg_ff_ret_vlr_number
-- Inclus�o da fun��o para retornar o valor dos campos Flex Field - FF - tipo CARACTERE.
-- Rotina: fkg_ff_ret_vlr_caracter
--
-- Em 26/09/2012 - Angela In�s.
-- Alterar os nomes das FKB para FKG, nas rotinas de campos FF - Flec Field.
--
-- Em 22/11/2012 - Angela In�s.
-- Ficha HD 64702 - Erro na gera��o do registro 0500.
-- 1) Implementar a fun��o que recupera o c�digo da conta do plano de contas atrav�s do identificador do plano.
-- 2) Implementar a fun��o que recupera o c�digo do centro de custo atrav�s do identificador do centro de custo.
-- Rotina: fkg_cd_plano_conta e fkg_cd_centro_custo.
--
-- Em 27/12/2012 - Angela In�s.
-- Ficha HD 65154 - Fechamento Fiscal por empresa. Fun��o que retorna a �ltima data de fechamento fiscal por empresa.
-- Rotina: fkg_recup_dtult_fecha_empresa.
--
-- Em 30/01/2013 - Vanessa Ribeiro
-- Inclusao da fkg_existe_item_compl
--
-- Em 20/02/2013 - Angela In�s.
-- Ficha HD 66153 - Inclus�o da fun��o que recupera os identificadores de pessoa atrav�s do cnpj ou cpf.
-- Rotina: fkg_ret_string_id_pessoa.
--
-- Em 25/02/2013 - Rog�rio Silva.
-- Exclus�o da fun��o fkg_busca_conhectransp_id (fun��o substituida pela mesma por�m da package PK_INTEGR_VIEW_CT).
-- Rotina: fkg_busca_conhectransp_id.
--
-- Em 09/04/2013 - Angela In�s.
-- Ficha HD 64892 - Gera��o do SEF-PE.
-- Corre��o na recupera��o do c�digo do tipo de item, pois a vari�vel de retorno � caracter e estava retornando num�rico.
-- Rotina: fkg_cd_tipo_item_id.
--
-- Em 26/04/2013 - Angela In�s.
-- Ficha HD 66641 - Bloco F100 - Se informar ITEM na tela, VALIDAR se tem NCM no cadastro de ITEM e se est� cadastrado com natureza de cr�dito NCM_NAT_REC_PC.
-- Criada fun��o para validar c�digo NCM relacionado co item, e fun��o para validar c�digo NCM e Natureza de receita para gera��o de Pis/Cofins.
-- Rotinas: fkg_item_ncm_valido e fkg_ncm_id_item.
--
-- Em 02/05/2013 - Angela In�s.
-- Sem ficha HD - Aline - Sermmatec - Integra��o de notas fiscais de servi�o modelo 99.
-- Na integra��o foi encontrada nota fiscal de servi�o sem pessoa_id com a mesma chave a ser integrada.
-- Corre��o para busca de nota fiscal de acordo com o dm_st_proc da mesma.
-- Rotina: fkg_busca_notafiscal_id.
--
-- Em 02/07/2013 - Angela In�s.
-- Redmine Atividade #303 - Valida��o de informa��es Fiscais - Ficha HD 66733.
-- Inclus�o de fun��o para recuperar o par�metro da empresa: dm_ajust_desc_zfm_item. Rotina: fkg_empr_ajust_desc_zfm_item.
-- Fun��o para retornar o tipo de emitente da nota fiscal - nota_fiscal.dm_ind_emit = 0-emiss�o pr�pria, 1-terceiros. Rotina: fkg_dmindemit_notafiscal.
-- Fun��o para retornar a finalidade da nota fiscal - nota_fiscal.dm_fin_nfe = 1-NF-e normal, 2-NF-e complementar, 3-NF-e de ajuste. Rotina: fkg_dmfinnfe_notafiscal.
-- Fun��o para retornar a sigla do estado do emitente da nota fiscal. Rotina: fkg_uf_notafiscalemit.
-- Fun��o para retornar a sigla do estado do destinat�rio da nota fiscal. Rotina : fkg_uf_notafiscaldest.
-- Fun��o para retornar o identificador de pessoa da nota fiscal. Rotina: fkg_pessoa_notafiscal_id.
--
-- Em 18/07/2013 - Angela In�s.
-- RedMine 58 - Ficha HD 66037
-- Melhoria na valida��o de impostos de Nota Fiscal mercantil, separar a valida��o de "Emiss�o Pr�pria" e "Emiss�o de Terceiros".
-- Duplicar os par�metros para valida��o de impostos: icms, icms-60, ipi, pis, cofins.
-- Os que j� existem dever�o fazer parte da op��o Emiss�o Pr�pria, que s�o: DM_VALID_IMP, DM_VALID_ICMS60, DM_VALIDA_IPI, DM_VALIDA_PIS, DM_VALIDA_COFINS.
-- Os novos dever�o fazer parte da op��o Terceiros, ficando: DM_VALID_IMP_TERC, DM_VALID_ICMS60_TERC, DM_VALIDA_IPI_TERC, DM_VALIDA_PIS_TERC, DM_VALIDA_COFINS_TERC.
-- Alterado os nomes das fun��es para: fkg_empresa_dmvalimp_emis, fkg_empresa_dmvalicms60_emis, fkg_empresa_dmvalipi_emis, fkg_empresa_dmvalpis_emis e fkg_empresa_dmvalcofins_emis.
-- Criadas as fun��es: fkg_empresa_dmvalimp_terc, fkg_empresa_dmvalicms60_terc, fkg_empresa_dmvalipi_terc, fkg_empresa_dmvalpis_terc e fkg_empresa_dmvalcofins_terc.
--
-- Em 22/07/2013 - Rog�rio Silva.
-- RedMine Atividade #399
-- Inclus�o das fun��es: fkg_grupopat_id e fkg_subgrupopat_id
--
-- Em 24/07/2013 - Rog�rio Silva.
-- RedMine Atividade #398
-- Inclus�o das fun��es: fkg_existe_grupo_pat, fkg_existe_subgrupo_pat, fkg_recimpsubgrupopat_id e fkg_existe_imp_subgrupo_pat.
--
-- Em 24/07/2013 - Angela In�s.
-- Eliminado a fun��o fkg_item_id por estar usando somente o c�digo do item e este pode estar cadastrado para outras empresas.
--
-- Em 25/07/2013 - Rog�rio Silva.
-- RedMine Atividade #401
-- Inclus�o das fun��es: fkg_nfbemativoimob_id, fkg_existe_nf_bem_ativo_imob e fkg_itnfbemativoimob_id.
--
-- Em 26/07/2013 - Rog�rio Silva.
-- RedMine Atividade #401 e #400
-- Inclus�o das fun��es: fkg_existe_itnf_bem_ativo_imob, fkg_recimpbemativoimob_id e fkg_existe_rec_imp_bem_ativo.
--
-- Em 12/08/2013 - Angela In�s.
-- Redmine #504 - Notas com diverg�ncia de sigla de estado da pessoa_id da nota com emitente ou destinat�rio.
-- Rotinas: fkg_pessoa_id_cpf_cnpj, fkg_pessoa_id_cpf_cnpj_interno e fkg_pessoa_id_cpf_cnpj_uf.
--
-- Em 09/09/2013 - Angela In�s.
-- Redmine #648 - Suporte - Tadeu/Verdemar - Gera��o do PIS/COFINS - Abertura do arquivo.
-- Recuperar o par�metro da empresa que indica se ir� utilizar recupera��o do tipo de cr�dito com o processo Embalagem ou n�o.
-- Rotina: fkg_dmutilprocemb_tpcred_empr.
--
-- Em 17/09/2013 - Rog�rio Silva
-- Inclus�o da fun��o fkg_cod_class
--
-- Em 17/09/2013 - Rog�rio Silva
-- Inclus�o da fun��o fkg_codconsitemcont_cod
--
-- Em 25/09/2013 - Rog�rio Silva
-- Inclus�o da fun��o fkg_nro_fci_valido
--
-- Em 08/10/2013 - Rog�rio Silva
-- Inclus�o da fun��o fkg_tipoeventosefaz_cd
--
-- Em 24/10/2013 - Rog�rio Silva
-- Inclus�o da fun��o fkg_tipoeventosefaz_id
--
-- Em 28/10/2013 - Angela In�s.
-- Redmine #1274 - Eliminar a fun��o pk_csf.fkg_nota_fiscal_id.
-- Rotina: fkg_nota_fiscal_id.
--
-- Em 31/10/2013 - Rog�rio Silva
-- Inclus�o da fun��o fkg_paiscnpj_cnpj
--
-- Em 04/11/2013 - Rog�rio Silva
-- Inclus�o da fun��o fkg_inscr_mun_empresa
--
-- Em 04/11/2013 - Rog�rio Silva
-- Inclus�o da fun��o fkg_ibge_cidade_empresa
--
-- Em 06/11/2013 - Angela In�s.
-- Redmine #1161 - Altera��o do processo de valida��o de valor dos documentos fiscais.
-- Inclus�o da fun��o para retornar o valor de toler�ncia para os valores de documentos fiscais (nf, cf, ct) e caso n�o exista manter 0.03.
-- Rotina: fkg_vlr_toler_empresa.
--
-- Em 20/02/2014 - Angela In�s.
-- Redmine #1979 - Alterar processo nota fiscal devido aos modelos fiscais de servi�o cont�nuo, incluir data de emiss�o.
-- Rotina: fkg_busca_notafiscal_id.
--
-- Em 03/03/2014 - Angela In�s.
-- Redmine #2043 - Alterar a API de integra��o de cadastros incluindo o cadastro de Item componente/insumo.
-- Incluir as fun��es: fkg_item_insumo_id e fkg_existe_iteminsumo.
--
-- Em 10/04/2014 - Angela In�s.
-- Redmine #2505 - Altera��o da Gera��o do arquivo do Sped ICMS/IPI.
-- Inclus�o da fun��o que retorna o c�digo de ajuste das obriga��es a recolher atrav�s do identificador.
-- Rotina: fkg_cd_ajobrigrec.
--
-- Em 09/09/2014 - Rog�rio Silva.
-- Redmine #4065
-- Altera��o para remover virgulas e pontos dos valores de campos flex-field
-- Rotinas: fkg_ff_ret_vlr_number e fkg_ff_verif_campos.
--
-- Em 15/10/2014 - Rog�rio Silva.
-- Sem atividade - Problema encontrado pelo Mateus durante testes de valida��o de nota.
-- Estava dando erro ao executar a fun��o fkg_busca_notafiscal_id.
-- Foi adicionado os valores da chave da nota na mensagem de erro
--
-- Em 30/10/2014 - Angela In�s.
-- Redmine #4961 - Incluir novos tipos de log para limpeza da log_generico.
-- Incluir os c�digos: INFO_NFE_INTEGRADA, INFO_ENV_EMAIL_DEST_NFE, INFO_IMPRESSAO_DANFE, CONS_SIT_NFE_SEFAZ, INFO_CANC_NFE, INFO_INTEGR,
-- CONHEC_TRANSP_INTEGRADO, INFORMACAO.
-- Rotina: pkb_limpa_log.
--
-- Em 18/11/2014 - Rog�rio Silva.
-- Redmine #5254 - Erro de valida��o em NFSe com dados corretos.
-- Rotina: fkg_Tipo_Servico_id
--
-- Em 21/11/2014 - Rog�rio Silva.
-- Redmine #5287 - Confirma��o Autom�tica do MDe para Barcelos
-- Rotina: fkg_empresa_reg_mde_aut
--
-- Em 21/11/2014 - Leandro Savenhago
-- Redmine #5287 - Altera��es na package PK_CSF para atender a melhoria de Mult-Organiza��o
-- Novas Rotinas: fkg_multorg_id, fkg_tipoobjintegr_id
-- Alteradas: fkg_Pessoa_id_cpf_cnpj, fkg_pessoa_id_cod_part, fkg_busca_notafiscal_id, fkg_contador_id, fkg_Pessoa_id_cpf_cnpj_interno,
--            fkg_ret_string_id_pessoa, fkg_pessoa_id_cpf_cnpj_uf, fkg_neo_usuario_id_conf_erp, pkb_insere_usuario, fkg_usuario_email_conf_erp,
--            fkg_Empresa_id, fkg_nome_empresa, fkg_empresa_id_pelo_cpf_cnpj, fkg_empresa_id_pelo_ie, fkg_empresa_id2, fkg_Unidade_id
--
-- Em 28/11/2014 - Rog�rio Silva.
-- Redmine #5364 - Altera��es na package PK_CSF
-- Rotina alteradas: fkg_grupopat_id
--
-- Em 01/12/2014 - Rog�rio Silva.
-- Redmine #5364 - Altera��es na package PK_CSF
-- Rotinas criadas: fkg_cod_ind_bem_id, fkg_subgrupopat_cd e fkg_grupopat_cd_subgrupo_id
--
-- Em 02/12/2014 - Rog�rio Silva.
-- Redmine #5364 - Altera��es na package PK_CSF
-- Rotinas alteradas: fkg_Nat_Oper_id, fkg_natoper_id_cod_nat, fkg_Infor_Comp_Dcto_Fiscal_id, fkg_id_obs_lancto_fiscal
--
-- Em 05/12/2014 - Rog�rio Silva.
-- Redmine #5364 - Altera��es na package PK_CSF
-- Rotinas criadas: fkg_existe_plano_conta, fkg_existe_pc_referen, fkg_existe_centro_custo
--
-- Em 06/12/2014 - Rog�rio Silva.
-- Redmine #5364 - Altera��es na package PK_CSF
-- Rotinas criadas: fkg_existe_hist_padrao
--
-- Em 26/12/2014 - Angela In�s.
-- Redmine #5616 - Adequa��o dos objetos que utilizam dos novos conceitos de Mult-Org.
-- Inverter os par�metros de entrada mantendo en_multorg_id como sendo o primeiro par�metro.
--
-- Em 22/01/2015 - Rog�rio Silva
-- Redmine #5889 - Alterar integra��es em bloco para usar o where e rownum
-- rotinas: fkg_quantidade e fkg_monta_obj
--
-- Em 23/02/2015 - Rog�rio Silva.
-- Redmine #6510 - Criar valida��o CodTributCidade.
-- Rotina: fkg_cidade_descr
--
-- Em 10/03/2015 - Rog�rio Silva.
-- Redmine #6881 - Integra��o de notas com CFOP 1152 (BARCELOS)
-- Rotina: fkg_monta_obj
--
-- Em 26/03/2015 - Rog�rio Silva.
-- Redmine #7195 - Realizar testes com base nas altera��es efetuadas nos processos que usam a tabela CTRL_RESTR_PESSOA
-- Rotina: fkg_multorg_id_usuario
--
-- Em 26/03/2015 - Rog�rio Silva.
-- Redmine #7276 - Falha na integra��o de notas - BASE HML (BREJEIRO)
-- Rotina: fkg_dm_tp_amb_nf
--
-- Em 13/04/2015 - Angela In�s.
-- Redmine #7500 - Valida��o dos dados Cadastrais de Participantes (SOUTHCO).
-- O processo de valida��o do cadastro de pessoa recuperava os valores de tipo e valor de par�metro pelos identificadores (ID), mas n�o recuperava o
-- c�digo dos mesmos (CD), por isso os valores n�o estavam sendo encontrados. Cria��o de nova fun��o.
-- Rotina: fkg_cd_tipoparam.
--
-- Em 22/04/2015 - Rog�rio Silva.
-- Redmine #6327 - Importar Arquivo ECD para Compliance - Processo Oficializar Arquivo.
-- Rotina: fkg_split
--
-- Em 23/04/2015 - Rog�rio Silva.
-- Redmine #7494 - Erro valida��o c�digo do servi�o no SPED Fiscal.
-- Rotina: fkg_Tipo_Servico_id
--
-- Em 27/04/2015 - Rog�rio Silva.
-- Redmine #7908 - Alterar fun��o de buscar o id a nota fiscal para considerar apenas a data sem a hora
-- Rotina: fkg_busca_notafiscal_id
--
-- Em 05/05/2015 - Rog�rio Silva.
-- Redmine #6327 - Importar Arquivo ECD para Compliance - Processo Oficializar Arquivo.
-- Rotina: pkb_dividir
--
-- Em 05/05/2015 - Rog�rio Silva.
-- Redmine #8071 - N�o est� gerando lote pra notas de servi�o.
-- Rotina: fkg_Tipo_Servico_id
--
-- Em 12/05/2015 - Rog�rio Silva.
-- Redmine #7226 - Criar package pk_vld_amb_usuario.
-- Rotinas: fkg_papel_nome_conf_id, fkg_empresa_id_cpf_cnpj
--
-- Em 18/05/2015 - Rog�rio Silva.
-- Redmine #8198 - Travar altera��o na Forma de Emiss�o de NFe, quando for EPEC
--
-- Em 22/05/2015 - Rog�rio Silva.
-- Redmine #7711 - Consistir na integra��o da emiss�o nfe dt_emiss superior a 30 dias
-- Rotina: fkg_estado_lim_emiss_nfe
--
-- Em 02/06/2015 - Rog�rio Silva.
-- Redmine #7754 - Registro duplicado NFe pr�pria/terceiro (SANTA F�)
--
-- Em 17/06/2015 - Angela In�s.
-- Redmine #9271 - Erro Registro C113 SISMETAL (ACECO).
-- Inclus�o da fun��o que recupera a situa��o do documento fiscal atrav�s do identificador da nota fiscal.
-- Rotina: fkg_sitdoc_id_nf.
--
-- Em 30/06/2015 - Rog�rio Silva.
-- Redmine #9335 -  Ao reenviar uma nota em EPEC, est� ficando com o nro de protocolo nulo
--
-- Em 17/07/2015 - Angela In�s.
-- Redmine #10117 - Escritura��o de documentos fiscais - Processos.
-- Criar a fun��o para recuperar o par�metro que indica qual data ser� escriturado o documento fiscal.
-- Rotina: fkg_dmdtescrdfepoe_empresa.
--
-- Em 30/07/2015 - Rog�rio Silva
-- Redmine #10208 - C�digos de Pa�s - IBGE e SISCOMEX. Processo de Valida��o.
-- Rotina: fkg_pais_id_tipo_cod_arq
--
-- Em 05/08/2015 - Rog�rio Silva
-- Redmine #9829 - Implementa��o do processo de exporta��o de Nota Fiscais de servi�os Tomados para a prefeitura do Rio de Janeiro/RJ
-- Rotina: fkg_inscr_mun_pessoa
--
-- Em 07/10/2015 - Angela In�s.
-- Redmine #11911 - Implementa��o do UF DEST nos processos de Integra��o e Valida��o.
-- Inclus�o de fun��o para identificar se j� existe grupo de tributa��o do imposto ICMS.
-- Rotina: fkg_existe_imp_itemnficmsdest.
--
-- Em 19/11/2015 - Leandro Savenhago
-- Implementado a limpeza de tabelas de log que n�o foram feitas
-- Rotina: pkb_limpa_log
--
-- Em 30/11/2015 - Angela In�s.
-- Redmine #13264 - N�o est� integrando as notas 1007 e 1008.
-- Corre��o no tamanho do campo VALOR para varchar2(600).
-- Rotina: fkg_ff_verif_campos e fkg_ff_ret_vlr_caracter.
--
-- Em 23/12/2015 - Rog�rio Silva.
-- Redmine #14035 - Rever procedimento pk_csf.pkb_acerta_sequence
--
-- Em 17/05/2016 - Marcos Garcia
-- Redmine #18958 - Implementar uma function que passa o id da nota por parametro e retorna as informa��es adicionais
-- mais detalhes na descri��o desta tarefa
-- Rotina: fkg_info_adicionais
--
-- Em 02/06/2016 - Angela In�s.
-- Redmine #19699 - Valida��o de Notas Fiscais de Emiss�o Pr�pria e Modelos '55' e '65'.
-- Fun��es criadas: fkg_empr_dt_venc_cert_ok e fkg_empr_dt_venc_cert.
--
-- Em 16/06/2016 - Angela In�s.
-- Redmine #20262 - Fun��o/Processo que recupera a nota fiscal - Utiliza��o Geral.
-- Alterar o processo que recupera as Notas Fiscais de emiss�o pr�pria (nota_fiscal.dm_ind_emit=0) e modelo fiscal diferente de ('06', '21', '22', '29', '28'),
-- passando a recuperar a nota mais antiga pelo identificador da nota (min(nota_fiscal.id)), quando for encontrado mais de um registro.
-- Rotina: fkg_busca_notafiscal_id.
--
-- Em 27/06/2016 - Angela In�s.
-- Redmine #20697 - Corre��o nos par�metros do Sped ICMS/IPI - DIFAL - Partilha de ICMS - Processos.
-- Incluir na fun��o pkb_param_difal_efd_icms_ipi, outro par�metro de sa�da CODAJSALDOAPURICMS_ID_DIFPART.
--
-- Em 23/01/2017 - Angela In�s.
-- Redmine #26824 - Corre��o no processo de acerto de sequence: Eliminar a tabela NOTA_FISCAL do processo.
-- A tabela nota_fiscal possui uma sequence diferenciada nos clientes que utilizam o ERP/SGI, temos que deixar um intervalo de valores espec�fico.
-- Se o processo de atualiza��o de sequence for executado, os valores das sequences ficaram incorretos.
-- Caso seja necess�rio atualizar a sequence da tabela nota_fiscal, o processo dever� ser espec�fico e com aten��o aos clientes de ERP/SGI.
-- Rotina: pkb_acerta_sequence.
--
-- Em 25/01/2017 - Leandro Savenhago
-- Redmine #27546 - Adequa��o dos impostos no DANFE/XML NFe modelo 55 - Lei da transpar�ncia
-- cria��o da fun��o fkg_empresa_inf_trib_op_venda
--
-- Em 16/02/2017 - Marcos Garcia
-- Cria��o da fun��o que retorna o id da tabela PARAM_ITEM_ENTR e PARAM_OPER_FISCAL_ENTR conforme a sua Unique.
-- Rotina: fkg_paramitementr_id, fkg_paramoperfiscalentr_id
--
-- Em 23/04/2017 - Leandro Savenhago
-- Redmine #28780 - Par�metro de Formato de Data Global para o Sistema
-- cria��o da fun��o fkg_param_global_csf_form_data
--
-- Em 09/03/2017 - F�bio Tavares
-- Redmine #28949 - Impress�o de Local de Retirada e Local de Entrega na Nota Fiscal Mercantil.
--
-- Em 09/03/2017 - Leandro Savenhago
-- Redmine #29225 - Adi��o de Tags no XML de NFe para Parker
-- cria��o da fun��o fkg_limpa_acento2, para n�o limpar caracteres como <>|! que seram utilizados em coment�rios de XML
--
-- Em 30/05/2017 - Angela In�s.
-- Redmine #31537 - Alterar a fun��o que converte caracteres especiais - comando ENTER/CHR(10).
-- Eliminar da fun��o que converte uma string limpando caracteres especiais, o comando que elimina o "ENTER"/"CHR".
-- Hoje no processo PK_CSF temos as fun��es FKG_CONVERTE, FKG_LIMPA_ACENTO e FKG_LIMPA_ACENTO2.
-- A fun��o que ser� alterada � FKG_LIMPA_ACENTO2. Essa fun��o � utilizada na valida��o da nota fiscal mercantil (pk_csf_api.pkb_integr_item_nota_fiscal e
-- pk_csf_api.pkb_integr_nfinfor_adic), com rela��o aos campos: Informa��es adicionais do produto (item_nota_fiscal.infadprod), e CONTEUDO de Informa��es
-- Adicionais (nfinfor_adic.conteudo).
-- Rotina: fkg_limpa_acento2.
--
-- Em 05/06/2017 - Angela In�s.
-- Redmine #31707 - Alterar fun��o que elimina caracteres especiais.
-- Alterar na fun��o que limpa os acento, para que a mesma limpe somente os caracteres especiais, deixando os espa�os entre as palavras devido a montagem do texto.
-- Eliminar da fun��o o caracter '%', pois esse caracter n�o deve ser eliminado.
-- Rotina: fkg_limpa_acento2.
--
-- Em 06/06/2017 - Angela In�s.
-- Redmine #31750 - Alterar a fun��o que elimina os caracteres especiais - pk_csf.fkg_limpa_acento2.
-- Alterar a fun��o que elimina somente os caracteres e o espa�o inicial e final, para eliminar tamb�m o comando ENTER do in�cio e do final do arquivo.
-- Rotina: fkg_limpa_acento2.
--
-- Em 25/08/2017 - Marcelo Ono
-- Redmine #33869 - Inclus�o da fun��o para verificar participante est� cadastro como empresa
-- Rotina: fkg_valida_part_empresa.
--
-- Em 28/09/2017 - Angela In�s.
-- Redmine #33434 - Alterar o processo de valida��o de cadastros gerais - atualiza��o de dependentes do ITEM.
-- 1) Na rotina que integra os Itens, executar o processo de atualiza��o de depend�ncia de item, se o par�metro da empresa indicar que devem ser atualizadas
-- as depend�ncias do Item (itens de notas fiscais sem o identificador do item - item_nota_fiscal.item_id).
-- Incluir fun��o que retorna o indicador de atualiza��o de depend�ncias do Item na Integra��o de Cadastros Gerais - Item
-- Rotina: fkg_empr_dm_atual_dep_item.
--
-- Em 10/10/2017 - Marcos Garcia
-- Redmine#35132 - Altera��es nos processos de Integra��o sobre Exporta��o.
-- Adicionado a fun�ao que recupera o identificador da informa��o sobre exporta��o
-- a nova coluna que faz parte da chave unica, NRO_RE. Rotina: fkg_busca_infoexp_id
--
-- Em 11/10/2017 - Marcelo Ono.
-- Redmine #35373 - Inclus�o de processo para converter o caractere especial \n "New line" por chr(10) "Enter".
-- Rotina: fkg_converte.
--
-- Em 23/10/2017 - Marcelo Ono.
-- Redmine #35619 - Corre��o no processo de convers�o do caractere especial \n "New line" por chr(10) "Enter".
-- 1- Implementado processo para verificar se a string original est� com o caractere \n "New line", e caso esteja,
-- n�o dever� retirar o caractere chr(10) "Enter" da string.
-- Obs: Este processo foi implementado especificamente para o cliente Ven�ncio, que est� enviando o caractere "\n" representando a quebra de linha.
-- Rotina: fkg_converte.
--
-- Em 23/01/2018 - Karina de Paula
-- Redmine #38656 - Processos de integra��o de Conhecimento de Transporte - Modelo D100.
-- Inclus�o do modelo fiscal 67 na function fkg_cte_nao_integrar
--
-- Em 09/02/2018 - Karina de Paula
-- Redmine #39221 - Altera��o nos processos de Informa��es sobre Exporta��o - Coluna CHC_EMB.
-- Rotina Alterada: fkg_busca_infoexp_id => Inclu�do o par�metro entrada ev_chc_emb. Inclu�da a coluna na condi��o where do select
--
-- Em 09/02/2018 - Marcelo Ono
-- Redmine #39282 - Implementado fun��o para recuperar o id e o c�digo da fonte pagadora REINF.
-- Rotina: fkg_recup_fonte_pagad_reinf_id, fkg_recup_fonte_pagad_reinf.
--
-- Em 08/03/2018 - Angela In�s.
-- Redmine #40180 - Altera��o na gera��o do arquivo Sped Fiscal - Registros C100 e 0450.
-- Criado par�metro em "Par�metros do Sped ICMS/IPI": param_efd_icms_ipi.dm_quebra_infadic_spedf - 0-N�o, 1-Sim.
-- Fun��o: fkg_parefdicmsipi_dmqueinfadi.
--
-- Em 26/07/2018 - Angela In�s.
-- Redmine #45214 - Gera��o da DANFE Adicionar as informa��es referente ao Nro_Fatura no quadro Fatura do pdf.
-- Foi criado um par�metro interno para ser utilizado na fun��o que recupera as faturas e suas parcelas. Essa fun��o � utilizada em dois processos: Gera��o da
-- DANFE e Gera��o de Arquivo de Emiss�o Pr�pria de Servi�o Prestado - NFSe.
-- Par�metro de entrada: en_monta_nro_fat, sendo: 0-N�o monta o Nro da Fatura, 1-Sim, monta o Nro da Fatura.
-- Fun��o: fkg_String_dupl.
--
-- Em 09/08/2018 - Eduardo Linden
-- Redmine #45728 - Campo nota_fiscal.vers_proc est� sendo preenchido com '2.8.4.5' na release 286
-- Alteracao do processo para obter a recuperar o c�digo da vers�o mais recente na tabela versao_sistema.
-- Fun��o: fkg_ultima_versao_sistema.
--
-- Em 15/10/2018 - Eduardo Linden
-- Redmine #47653 - Inclus�o das functions para os parametros de valida��o de base icms : empresa.dm_valid_base_icms e
-- empresa.dm_valid_base_icms_terc
-- Fun��o: fkg_empresa_dmvalbaseicms_emis e fkg_empresa_dmvalbaseicms_terc
--
-- Em 25/10/2018 - Karina de Paula
-- Redmine #39990 - Adpatar o processo de gera��o da DIRF para gerar os registros referente a pagamento de rendimentos a participantes localizados no exterior
-- Rotina Alterada: fkg_existe_item_compl => Alterada a msg de erro que estava como erro no objeto fkg_existe_inf_rend_dirf_msl
-- Rotina Criada: fkg_cod_nif_pessoa / fkg_sigla_pais / fkg_pais_obrig_nif
--
-- Em 30/10/2018 - Karina de Paula
-- Redmine #47549 - Adaptar packages de integra��o
-- Rotina Criada: fkg_tipo_ret_imp_rec
--
-- Em 31/10/2018 - Karina de Paula
-- Redmine 47558 - Altera��es na package pk_entr_cte_terceiro para atender INSS
-- Rotina Criada: fkg_tipo_ret_imp_rec_cd
--
-- Em 31/10/2018 - Angela In�s.
-- Redmine #48314 - Melhoria na fun��o global que recupera o Identificador do Plano de Contas.
-- Alterar a fun��o que recupera o Identificador do Plano de Contas, para considerar o c�digo da conta enviado pelo par�metro de entrada, no formato real, e caso
-- n�o seja encontrado, eliminar a m�scara do c�digo e fazer nova recupera��o. Ainda n�o encontrando, ser� verificado se a empresa enviada pelo par�metro de
-- entrada possui matriz, e neste caso, recuperar da mesma por�m com a empresa matriz, recuperando primeiro, no formato real e em seguida sem a m�scara.
-- Rotina: fkg_plano_conta_id.
--
-- Em 29/11/2018 - Eduardo Linden
-- Redmine #47653 - Inclus�o de function para o parametro de valida��o de base icms : empresa.dm_forma_dem_base_icms
-- Fun��o: fkg_empresa_dmformademb_icms 
--
-- Em 07/12/2018 - Karina de Paula
-- Redmine #48370 - Erro na integra��o do usuario.
-- Rotina Alterada: fkg_usuario_email_conf_erp e fkg_neo_usuario_id_conf_erp => Foi incluida essa nova verificacao em funcao do campo id_erp na integracao receber
-- o vlr do login. Nos casos de cadastro manual de usuario o campo id_erp pode ficar nulo, nao retornando o email ou o id do usuario
--
-- Em 09/01/2019 - Karina de Paula
-- Redmine #50344 - Processo para gerar os dados dos impostos originais
-- Rotina Criada: fkg_empresa_guarda_imporig e fkg_existe_nf_imp
--
-- Em 22/03/2019 - Angela In�s.
-- Redmine #52759 - Integra��o de Cadastro de Item - Empresa.
-- Considerar para Integra��o do ITEM, quando o ID do Item for NULO, a empresa enviada na View de Integra��o (vw_csf_item.cpf_cnpj), caso o ID do Item
-- for diferente de NULO, o processo ir� validar da mesma que era antes, ou seja, considerando a empresa em quest�o e sua matriz.
-- Rotina: fkg_item_id.
--
-- Em 02/04/2019 - Karina de Paula
-- Redmine #52997 - feed - erro na integra��o do imposto
-- Rotina Criada: fkg_existe_imp_itemnf
--
-- Em 03/06/2019 - Marcos Ferreira
-- Redmine #55245: Criar fun��o na pk_csf para retornar parametro geral
-- Altera��es: Cria��o de nova fun��o para buscar parametros gerais de sistema
-- Procedures Alteradas: fkg_ret_vl_param_geral_sistema, fkg_ret_idmodulo_sistema, fkg_ret_id_grupo_sistema
--
---------------------------------------------------------------------------------------------------------------------------------------------------------

--Fun��o que retrona o id da tabela PARAM_OPER_FISCAL_ENTR, conforme sua UK.

function fkg_paramoperfiscalentr_id ( en_empresa_id         in number
                                    , en_cfop_id_orig       in number
                                    , ev_cnpj_orig          in varchar2
                                    , en_ncm_id_orig        in number
                                    , en_item_id_orig       in number
                                    , en_codst_id_icms_orig in number
                                    , en_codst_id_ipi_orig  in number )
return param_oper_fiscal_entr.id%type;

-------------------------------------------------------------------------------------------------------
--Fun��o que retorna o id da tabela PARAM_ITEM_ENTR, conforme sua UK.

function fkg_paramitementr_id ( en_empresa_id     in number
                              , ev_cnpj_orig      in varchar2
                              , en_ncm_id_orig    in number
                              , ev_cod_item_orig  in varchar2
                              , en_item_id_dest   in number )
return param_item_entr.id%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o formata o valor na mascara deseja pelo usu�rio
function fkg_formata_num ( en_num in number
                         , ev_mascara in varchar2
                         )
         return varchar2;

----------------------------------------------------------------------------------------------------

--| Fun��o retorno o valor do Par�metro Global Formato Data do Sistema
function fkg_param_global_csf_form_data
         return param_global_csf.valor%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retor do ID da Mult-Organiza��o conforme c�digo

function fkg_multorg_id ( ev_multorg_cd in mult_org.cd%type )
         return mult_org.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o verifica se o ID da Mult-Organiza��o � valido

function fkg_valida_multorg_id ( en_multorg_id in mult_org.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna MULTORG_ID da Empresa

function fkg_multorg_id_empresa ( en_empresa_id in empresa.id%type )
         return mult_org.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da empresa Matriz
function fkg_empresa_id_matriz ( en_empresa_id  in empresa.id%type )
         return empresa.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela Msg_WebServ
function fkg_Msg_WebServ_id ( en_cd  in Msg_WebServ.cd%TYPE )
         return Msg_WebServ.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o tipo de efeito da mensagem do webserv
function fkg_Efeito_Msg_WebServ ( en_msgwebserv_id  in Msg_WebServ.id%TYPE
                                , en_cd             in Msg_WebServ.cd%TYPE )
         return Msg_WebServ.dm_efeito%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tebale Mod_Fiscal
function fkg_Mod_Fiscal_id ( ev_cod_mod  in Mod_Fiscal.cod_mod%TYPE )
         return Mod_Fiscal.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela Tipo_Servico
function fkg_Tipo_Servico_id ( ev_cod_lst  in Tipo_Servico.cod_lst%TYPE )
         return Tipo_Servico.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela Classe_Enq_IPI
function fkg_Classe_Enq_IPI_id ( ev_cl_enq  in Classe_Enq_IPI.cl_enq%TYPE )
         return Classe_Enq_IPI.id%TYPE;

-------------------------------------------------------------------------------------------------------

--| Fun��o retorna o CL_ENQ da tabela Classe_Enq_IPI conforme ID

function fkg_Classe_Enq_IPI_cd ( en_classeenqipi_id  in Classe_Enq_IPI.id%TYPE )
         return classe_enq_ipi.cl_enq%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela Selo_Contr_IPI
function fkg_Selo_Contr_IPI_id ( ev_cod_selo_ipi  in Selo_Contr_IPI.cod_selo_ipi%TYPE )
         return Selo_Contr_IPI.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o CD da tabela Selo_Contr_IPI conforme ID

function fkg_Selo_Contr_IPI_cd ( en_selocontripi_id  in Selo_Contr_IPI.id%TYPE )
         return selo_contr_ipi.cod_selo_ipi%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela Unidade
function fkg_Unidade_id ( en_multorg_id  in mult_org.id%type
                        , ev_sigla_unid  in Unidade.sigla_unid%TYPE
                        )
         return Unidade.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela Tipo_Item
function fkg_Tipo_Item_id ( ev_cd  in Tipo_Item.cd%TYPE )
         return Tipo_Item.id%TYPE;

-------------------------------------------------------------------------------------------------------

--| Fun��o retorna o ID da tabela Nat_Oper
function fkg_Nat_Oper_id ( en_multorg_id in mult_org.id%type
                         , ev_cod_nat    in Nat_Oper.cod_nat%TYPE )
         return Nat_Oper.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela Orig_Proc
function fkg_Orig_Proc_id ( en_cd  in Orig_Proc.cd%TYPE )
         return Orig_Proc.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o CD da tabela Orig_Proc conforme ID
function fkg_Orig_Proc_cd ( en_origproc_id  in Orig_Proc.id%TYPE )
         return Orig_Proc.cd%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela Sit_Docto
function fkg_Sit_Docto_id ( ev_cd  in Sit_Docto.cd%TYPE )
         return Sit_Docto.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o CD da tabela Sit_Docto
function fkg_Sit_Docto_cd ( en_sitdoc_id  in Sit_Docto.id%TYPE )
         return Sit_Docto.cd%TYPE;

-------------------------------------------------------------------------------------------------------

--| Fun��o retorna o ID da tabela Infor_Comp_Dcto_Fiscal
function fkg_Infor_Comp_Dcto_Fiscal_id ( en_multorg_id in mult_org.id%type
                                       , en_cod_infor  in Infor_Comp_Dcto_Fiscal.cod_infor%TYPE )
         return Infor_Comp_Dcto_Fiscal.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela Tipo_Imposto
function fkg_Tipo_Imposto_id ( en_cd  in Tipo_Imposto.cd%TYPE )
         return Tipo_Imposto.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela Cod_ST
function fkg_Cod_ST_id ( ev_cod_st      in Cod_ST.cod_st%TYPE
                       , en_tipoimp_id  in Cod_ST.id%TYPE )
         return Cod_ST.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela Aj_Obrig_Rec
function fkg_Aj_Obrig_Rec_id ( ev_cd          in Aj_Obrig_Rec.cd%TYPE
                             , en_tipoimp_id  in Aj_Obrig_Rec.id%TYPE )
         return Aj_Obrig_Rec.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela Genero
function fkg_Genero_id ( ev_cod_gen  in Genero.cod_gen%TYPE )
         return Genero.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela Ncm
function fkg_Ncm_id ( ev_cod_ncm  in Ncm.cod_ncm%TYPE )
         return Ncm.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela EX_TIPI
function fkg_ex_tipi_id ( ev_cod_ex_tipi  in EX_TIPI.cod_ex_tipi%TYPE
                        , en_ncm_id       in Ncm.id%TYPE )
         return EX_TIPI.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o C�digo da tabela EX_TIPI

function fkg_ex_tipi_cod ( en_extipi_id  in ex_tipi.id%type )
         return ex_tipi.cod_ex_tipi%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela Pais
function fkg_Pais_siscomex_id ( ev_cod_siscomex  in Pais.cod_siscomex%TYPE )
         return Pais.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela Pais conforme sigla do pais
function fkg_Pais_sigla_id ( ev_sigla_pais  in Pais.sigla_pais%TYPE )
         return Pais.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela Estado
function fkg_Estado_ibge_id ( ev_ibge_estado  in Estado.ibge_estado%TYPE )
         return Estado.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela Cidade
function fkg_Cidade_ibge_id ( ev_ibge_cidade  in Cidade.ibge_cidade%TYPE )
         return Cidade.id%TYPE;

-------------------------------------------------------------------------------------------------------

--| Fun��o retorna o ID da tabela Pessoa, conforme MultOrg_ID e CPF/CNPJ

function fkg_Pessoa_id_cpf_cnpj ( en_multorg_id  in mult_org.id%type
                                , en_cpf_cnpj    in varchar2 
                                )
         return Pessoa.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela Empresa
function fkg_Empresa_id ( en_multorg_id  in mult_org.id%type
                        , ev_cod_matriz  in Empresa.cod_matriz%TYPE
                        , ev_cod_filial  in Empresa.cod_filial%TYPE 
                        )
         return Empresa.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna "true" se a NF existe e "false" se n�o existe
function fkg_existe_nf ( en_nota_fiscal  in Nota_Fiscal.id%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna "true" se a UF for v�lida, e "false" se n�o for.
function fkg_uf_valida ( ev_sigla_estado  in Estado.Sigla_Estado%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna "true" se o IBGE do UF for v�lide e "false" se n�o for
function fkg_ibge_uf_valida ( ev_ibge_estado  in Estado.ibge_estado%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna "True" se o IBGE da cidade for v�lido e "false" se n�o for
function fkg_ibge_cidade ( ev_ibge_cidade  in Cidade.ibge_cidade%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna "true" se o c�digo do pais for v�lido e "false" se n�o for
function fkg_codpais_siscomex_valido ( en_cod_siscomex  in Pais.cod_siscomex%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna a descri��o do valor do domino
function fkg_dominio ( ev_dominio   in Dominio.dominio%TYPE
                     , ev_vl        in Dominio.vl%TYPE )
         return Dominio.descr%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna "true" se o ID da empresa for v�lido e "false" se n�o for
function fkg_empresa_id_valido ( en_empresa_id  in Empresa.id%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela Pessoa
function fkg_Pessoa_id_valido ( en_pessoa_id  in Pessoa.id%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna a pessoa pelo MultOrg_ID e cod_part
function fkg_pessoa_id_cod_part ( en_multorg_id  in mult_org.id%type
                                , ev_cod_part    in Pessoa.cod_part%TYPE
                                )
         return Pessoa.id%TYPE;

-------------------------------------------------------------------------------------------------------

--| Fun��o retorna o ID da NAT_OPER pelo cod_nat
function fkg_natoper_id_cod_nat ( en_multorg_id in mult_org.id%type
                                , ev_cod_nat    in Nat_Oper.cod_nat%TYPE )
         return Nat_Oper.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o nome da empresa
function fkg_nome_empresa ( en_empresa_id  in Empresa.id%TYPE
                          )
         return Pessoa.nome%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna a data de emiss�o da nota fiscal
function fkg_dt_emiss_nf ( en_notafiscal_id in Nota_Fiscal.id%TYPE )
         return Nota_Fiscal.dt_emiss%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna "true" se o item_id � v�lido e "false" se n�o �
function fkg_item_id_valido ( en_item_id  in Item.id%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o DM_ST_PROC (Situa��o do Processo) da Nota Fiscal
function fkg_st_proc_nf ( en_notafiscal_id  in Nota_Fiscal.id%TYPE )
         return Nota_Fiscal.dm_st_proc%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna a Chave da Nota Fiscal
function fkg_chave_nf ( en_notafiscal_id   in  Nota_Fiscal.id%TYPE )
         return Nota_Fiscal.nro_chave_nfe%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna um n�mero positivo aleat�rio na faixa de 1 a 999999999
function fkg_numero_aleatorio ( en_num in number
                              , en_ini in number
                              , en_fim in number )
         return number;

-------------------------------------------------------------------------------------------------------

-- C�lculo do d�gito verificador com modulo 11
function fkg_mod_11 ( ev_codigo in varchar2 )
         return number;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o tipo de ambiente (Produ��o/Homologa��o) parametrizado para a empresa
function fkg_tp_amb_empresa ( en_empresa_id  in Empresa.id%TYPE )
         return Empresa.dm_tp_amb%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o Tipo de impress�o (Retrato/Paisagem) parametrizado na empresa
function fkg_tp_impr_empresa ( en_empresa_id  in Empresa.id%TYPE )
         return Empresa.dm_tp_impr%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o Tipo de impress�o (Retrato/Paisagem) parametrizado na empresa
function fkg_forma_emiss_empresa ( en_empresa_id  in Empresa.id%TYPE )
         return Empresa.dm_forma_emiss%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da nota Fiscal a partir do n�mero da chave de acesso
function fkg_notafiscal_id_pela_chave ( en_nro_chave_nfe  in Nota_Fiscal.nro_chave_nfe%TYPE )
         return Nota_Fiscal.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID do Lote conforme o n�mero do recibo de envio fornecido pelo SEFAZ
function fkg_Lote_id_pelo_nro_recibo ( en_nro_recibo in Lote.nro_recibo%TYPE )
         return Lote.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID do Cfop
function fkg_cfop_id ( en_cd  in Cfop.cd%TYPE )
         return Cfop.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna a inscri��o estadual da empresa
function fkg_inscr_est_empresa ( en_empresa_id  in Empresa.id%TYPE )
         return Juridica.ie%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna "1" se a nota fiscal est� inutilizada e "0" se n�o est�
function fkg_nf_inutiliza ( en_empresa_id  in Empresa.id%TYPE
                          , ev_cod_mod     in Mod_Fiscal.cod_mod%TYPE
                          , en_serie       in Nota_Fiscal.serie%TYPE
                          , en_nro_nf      in Nota_Fiscal.nro_nf%TYPE
                          )
         return number;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna se 1 se o Estado Obrigado o CODIF e 0 se n�o Obriga
function fkg_Estado_Obrig_Codif ( ev_sigla_estado  in Estado.sigla_estado%TYPE )
         return Estado.dm_obrig_codif%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID do estado conforme a sigla de UF
function fkg_Estado_id ( ev_sigla_estado  in Estado.sigla_estado%TYPE )
         return Estado.id%TYPE;

-------------------------------------------------------------------------------------------------------

FUNCTION fkg_converte ( ev_string            IN varchar2
                      , en_espacamento       IN number DEFAULT 0
                      , en_remove_spc_extra  IN number DEFAULT 1
                      , en_ret_carac_espec   IN number DEFAULT 1
                      , en_ret_tecla         in number default 1 -- retira comandos CHR
                      , en_ret_underline     in number default 1 -- retira underline: 1 - sim, 0 - n�o
                      , en_ret_chr10         in number default 1 -- retira comandos CHR10 se a string original n�o vier com o caractere "\n"
                       )
         RETURN VARCHAR2;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna uma String com as informa��es de Duplicatas
function fkg_String_dupl ( en_notafiscal_id  in Nota_Fiscal.id%TYPE
                         , en_monta_nro_fat  in number default 0 )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da Nota Fiscal conforme Empresa, N�mero, modelo, serie e tipo (entrada/sa�da)
function fkg_busca_notafiscal_id ( en_multorg_id       in mult_org.id%type
                                 , en_empresa_id       in Empresa.id%TYPE
                                 , ev_cod_mod          in Mod_Fiscal.cod_mod%TYPE
                                 , ev_serie            in Nota_Fiscal.serie%TYPE
                                 , en_nro_nf           in Nota_Fiscal.nro_nf%TYPE
                                 , en_dm_ind_oper      in Nota_Fiscal.dm_ind_oper%TYPE
                                 , en_dm_ind_emit      in Nota_Fiscal.dm_ind_emit%TYPE
                                 , ev_cod_part         in Pessoa.cod_part%TYPE
                                 , en_dm_arm_nfe_terc  in nota_fiscal.dm_arm_nfe_terc%type default 0
                                 , ed_dt_emiss         in nota_fiscal.dt_emiss%type default null
                                 )
         return Nota_Fiscal.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o campo EMPRESA_ID conforme o CPF ou CNPJ
function fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id  in mult_org.id%type
                                      , ev_cpf_cnpj    in varchar2
                                      )
         return Empresa.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o campo EMPRESA_ID conforme a multorg_id e Incri��o Estadual
function fkg_empresa_id_pelo_ie ( en_multorg_id  in mult_org.id%type
                                , ev_ie          in juridica.ie%type
                                )
         return Empresa.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da empresa, pelo CNPJ ou pelo C�d. Matriz e Filial
function fkg_empresa_id2 ( en_multorg_id        in             mult_org.id%type
                         , ev_cod_matriz        in  Empresa.cod_matriz%TYPE  default null
                         , ev_cod_filial        in  Empresa.cod_filial%TYPE  default null
                         , ev_empresa_cpf_cnpj  in  varchar2                 default null -- CPF/CNPJ da empresa
                         )
         return empresa.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Procedimento respons�vel por retornar informa��es da Nota Fiscal
procedure pkb_inform_nf ( en_notafiscal_id       in  Nota_Fiscal.id%TYPE
                        , sn_lote_id             out Nota_Fiscal.lote_id%TYPE
                        , sv_cd_sitdocto         out Sit_Docto.cd%TYPE
                        , sn_nro_nf              out Nota_Fiscal.nro_nf%TYPE
                        , sv_serie               out Nota_Fiscal.serie%TYPE
                        , sn_dm_st_proc          out Nota_Fiscal.dm_st_proc%TYPE
                        , sd_dt_st_proc          out Nota_Fiscal.dt_st_proc%TYPE
                        , sn_dm_forma_emiss      out Nota_Fiscal.dm_forma_emiss%TYPE
                        , sn_dm_impressa         out Nota_Fiscal.dm_impressa%TYPE
                        , sn_dm_st_email         out Nota_Fiscal.dm_st_email%TYPE
                        , sn_dm_tp_amb           out Nota_Fiscal.dm_tp_amb%TYPE
                        , sd_dt_aut_sefaz        out Nota_Fiscal.dt_aut_sefaz%TYPE
                        , sn_dm_aut_sefaz        out Nota_Fiscal.dm_aut_sefaz%TYPE
                        , sv_nro_chave_nfe       out Nota_Fiscal.nro_chave_nfe%TYPE
                        , sn_cNF_nfe             out Nota_Fiscal.cNF_nfe%TYPE
                        , sn_dig_verif_chave     out Nota_Fiscal.dig_verif_chave%TYPE
                        , sn_nro_protocolo       out Nota_Fiscal.nro_protocolo%TYPE
                        , sn_nro_protocolo_canc  out Nota_Fiscal_Canc.nro_protocolo%TYPE
                        , sd_dt_canc             out Nota_Fiscal_Canc.dt_canc%TYPE
                        );

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna a Sigla do Tipo de Imposto
function fkg_Tipo_Imposto_Sigla ( en_cd  in Tipo_Imposto.cd%TYPE )
         return Tipo_Imposto.Sigla%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o COD_PART pelo ID da pessoa
function fkg_pessoa_cod_part ( en_pessoa_id in pessoa.id%type )
         return pessoa.cod_part%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela Contador conforme en_multorg_id e COD_PART
function fkg_contador_id ( en_multorg_id  in mult_org.id%type
                         , ev_cod_part    in pessoa.cod_part%type
                         )
         return contador.id%type;

-------------------------------------------------------------------------------------------------------

-- Retorna o ID do usu�rio do Sistema conforme multorg_id e ID_ERP
function fkg_neo_usuario_id_conf_erp ( en_multorg_id  in mult_org.id%type
                                     , ev_id_erp      in neo_usuario.id_erp%type
                                     )
         return neo_usuario.id%type;

-------------------------------------------------------------------------------------------------------

-- Retorna o ID da impressora vinculada a s�rie (EMPRESA_PARAM_SERIE)
procedure pkb_impressora_id_serie ( en_empresa_id    in  Empresa.id%TYPE
                                 , en_modfiscal_id  in  Mod_Fiscal.Id%TYPE
                                 , ev_serie         in  Nota_Fiscal.serie%TYPE
                                 , en_nfusuario_id  in  nota_fiscal.usuario_id%type
                                 , sn_impressora_id out nota_fiscal.impressora_id%type
                                 , sn_qtd_impr      out nota_fiscal.vias_danfe_custom%type);
-------------------------------------------------------------------------------------------------------

-- Retorna o ID da impressora vinculada ao usu�rio
function fkg_impressora_id_usuario ( en_usuario_id in neo_usuario.id%type )
         return impressora.id%type;

-------------------------------------------------------------------------------------------------------

-- Retorna o ID da impressora vincutada a empresa
function fkg_impressora_id_empresa ( en_empresa_id in empresa.id%type )
         return impressora.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna "true" se for uma NFe de emiss�o pr�pria j� autorizada, cancelada, denegada ou inutulizada, n�o pode ser re-integrada
function fkg_nfe_nao_integrar ( en_notafiscal_id  in nota_fiscal.id%Type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela CSF_TIPO_LOG conforme o identificador TIPO_LOG
function fkg_csf_tipo_log_id ( en_tipo_log in csf_tipo_log.cd_compat%type )
         return csf_tipo_log.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna um valor criptografado em MD5
function fkg_md5 ( ev_valor in varchar2 )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o CNPJ ou CPF conforme a empresa
function fkg_cnpj_ou_cpf_empresa ( en_empresa_id in Empresa.Id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o CNAE conforme a empresa
function fkb_retorna_cnae ( en_empresa_id in empresa.id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID do usu�rio
function fkg_usuario_id ( ev_login in neo_usuario.login%type)
         return neo_usuario.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna TRUE se a pessoa existe e FALSE se ela n�o existe, conforme o ID
function fkg_existe_pessoa ( en_pessoa_id in pessoa.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna "true" se o c�digo do pais for v�lido e "false" se n�o for, conforme ID
function fkg_pais_id_valido ( en_pais_id  in Pais.id%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da cidade conforme o c�digo do IBGE
function fkg_cidade_id_ibge ( ev_ibge_cidade in cidade.ibge_cidade%type )
         return cidade.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o IBGE da cidade conforme o ID
function fkg_ibge_cidade_id ( en_cidade_id  in Cidade.id%TYPE )
         return cidade.ibge_cidade%type;

-------------------------------------------------------------------------------------------------------

-- Retorna o c�dido do siscomex conforme o id do pa�s
function fkg_cod_siscomex_pais_id ( en_pais_id  in Pais.id%TYPE )
         return pais.cod_siscomex%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna TRUE se a unidade existe e FALSE se n�o existe, conforme o ID
function fkg_existe_unidade_id ( en_unidade_id in unidade.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorno o CD do tipo de item conforme o ID
function fkg_cd_tipo_item_id ( en_tipoitem_id in tipo_item.id%type )
         return tipo_item.cd%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o Retorna o C�digo da ANP do produto
function fkg_cod_anp_valido ( ev_cod_anp in cod_anp.cd%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da Covers�o de Unidade conforme Item e Unidade
function fkg_id_conv_unid ( en_item_id     in item.id%type
                          , ev_unidade_id  in unidade.id%type )
         return conversao_unidade.id%Type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID do bem do ativo imobilizado conforme empresa e c�digo do item
function fkg_id_bem_ativo_imob ( en_empresa_id   in empresa.id%type
                               , ev_cod_ind_bem  in bem_ativo_imob.cod_ind_bem%type )
         return bem_ativo_imob.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o returna TRUE se existe o bem ID ou FALSE se n�o existe, conforme o ID
function fkg_existe_bem_ativo_imob ( en_bemativoimob_id in bem_ativo_imob.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da Utiliza��o do Bem conforme Bem, Conta Cont�bil e Centro de Custo
function fkg_id_infor_util_bem ( en_bemativoimob_id in bem_ativo_imob.id%type
                               , ev_cod_ccus        in infor_util_bem.cod_ccus%type )
         return infor_util_bem.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o verifica se existe o ID da Informa��o Complementar do Documento Fiscal
function fkg_existe_Inf_Comp_Dcto_Fis ( en_infcompdctofis_id in infor_comp_dcto_fiscal.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o Retorna o ID da Observa��o do Lan�amento Fiscal
function fkg_id_obs_lancto_fiscal ( en_multorg_id in mult_org.id%type
                                  , ev_cod_obs in obs_lancto_fiscal.cod_obs%type )
         return obs_lancto_fiscal.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o verifica se existe da Observa��o do Lan�amento Fiscal
function fkg_existe_obs_lancto_fiscal ( en_obslanctofiscal_id in obs_lancto_fiscal.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID do invent�rio
function fkg_inventario_id ( en_empresa_id     in empresa.id%type
                           , en_item_id        in item.id%type
                           , en_unidade_id     in unidade.id%type
                           , ed_dt_inventario  in inventario.dt_inventario%type
                           , en_dm_ind_prop    in inventario.dm_ind_prop%type
                           , en_pessoa_id      in pessoa.id%type
                           )
         return inventario.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o verifica se existe o ID do invent�rio
function fkg_existe_inventario ( en_inventario_id in inventario.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID do invent�rio
function fkg_inventario_info_compl_id ( en_empresa_id     in empresa.id%type
                                      , en_item_id        in item.id%type
                                      , ed_dt_inventario  in inventario.dt_inventario%type
                                      )
         return inventario.id%type;
-------------------------------------------------------------------------------------------------------

-- Fun��o verifica se existe o ID do invent�rio
function fkg_existe_invent_cst ( en_invent_cst_id in invent_cst.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

function fkg_invent_cst_id ( en_inventario_id  in inventario.id%type
                           , en_codst_id       in cod_st.id%type
                           )
         return invent_cst.id%type;
-------------------------------------------------------------------------------------------------------

-- Conforme o ID da Pessoa Retorna o Nome
function fkg_nome_pessoa_id ( en_pessoa_id  in pessoa.id%type )
         return pessoa.nome%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da Unidade Organizacional conforme EMPRESA_ID e c�digo UO
function fkg_unig_org_id ( en_empresa_id    in  empresa.id%type
                         , ev_cod_unid_org  in  unid_org.cd%type )
         return unid_org.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID do Sistema de Origem conforme a Sigla
function fkg_unig_org_cd ( en_unidorg_id    in  unid_org.id%type )
         return unid_org.cd%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID do Sistema de Origem conforme a Sigla
function fkg_sist_orig_id ( en_multorg_id in  sist_orig.multorg_id%type
                          , ev_sigla      in  sist_orig.sigla%type )
         return sist_orig.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o Sigla do Sistema de Origem conforme o ID
function fkg_sist_orig_sigla ( en_sistorig_id  in  sist_orig.id%type )
         return sist_orig.sigla%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o par�metro de impressa autom�tica 0-N�o ou 1-Sim, conforme ID da empresa
function fkg_empresa_impr_aut ( en_empresa_id  in  empresa.id%type )
         return empresa.dm_impr_aut%type;

-------------------------------------------------------------------------------------------------------

-- Retorna true se a IBGE_UF for o mesmo da empresa, e false se n�o for
function fkg_uf_ibge_igual_empresa ( en_empresa_id   in  empresa.id%type
                                   , ev_ibge_estado  in  estado.ibge_estado%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Verifica se o c�digo do IBGE do estado corresponde a sigla do estado
function fkg_compara_ibge_com_sigla_uf ( ev_ibge_estado   in  estado.ibge_estado%type
                                       , ev_sigla_estado  in  estado.sigla_estado%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna a sigla do estado conforme o ID
function fkg_Estado_id_sigla ( en_estado_id in estado.id%type )
         return estado.sigla_estado%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna "true" se o valor � n�merico ou "false" se n�o �
function fkg_is_numerico ( ev_valor in varchar2 )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna "true" se for uma CTe de emiss�o pr�pria j� autorizada, cancelada, denegada ou inutulizada, n�o pode ser re-integrada
function fkg_cte_nao_integrar ( en_conhectransp_id in Conhec_Transp.id%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna a Sigla do Tipo de Imposto atrav�s do Id - cte
function fkg_Tipo_Imp_Sigla ( en_id  in Tipo_Imposto.id%TYPE )
         return Tipo_Imposto.Sigla%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o C�digo da tabela Cod_ST atrav�s do ID
function fkg_Cod_ST_cod ( en_id_st in Cod_ST.id%TYPE )
         return Cod_ST.cod_st%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o valida o formato da hora, passa o hora e o formato
function fkg_vld_formato_hora ( ev_hora     in varchar2
                              , ev_formato  in varchar2 )
                              return varchar2;

-------------------------------------------------------------------------------------------------------


-- Fun��o retorna o DM_ST_PROC (Situa��o do Processo) do Conhecimento de Transporte
function fkg_st_proc_ct ( en_conhectransp_id  in Conhec_Transp.id%TYPE )
         return Conhec_Transp.dm_st_proc%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna "1" se o conhecimento de transporte est� inutilizado e "0" se n�o est�
function fkg_ct_inutiliza ( en_empresa_id  in Empresa.id%TYPE
                          , ev_cod_mod     in Mod_Fiscal.cod_mod%TYPE
                          , en_serie       in Conhec_Transp.serie%TYPE
                          , en_nro_ct      in Conhec_Transp.nro_ct%TYPE
                          )
         return number;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna a Chave do Conhecimento de Transporte
function fkg_chave_ct ( en_conhectransp_id   in  Conhec_Transp.id%TYPE )
         return Conhec_Transp.nro_chave_cte%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna "true" se a CT-e existe e "false" se n�o existe
function fkg_existe_cte ( en_conhec_transp  in Conhec_Transp.id%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID do Conhec. de Transp. a partir do n�mero da chave de acesso
function fkg_conhectransp_id_pela_chave ( en_nro_chave_cte  in Conhec_Transp.nro_chave_cte%TYPE )
         return Conhec_Transp.id%TYPE;

-------------------------------------------------------------------------------------------------------

--| Fun��o retorna o ID da tabela Item, conforme ID Empresa, para Integra��o do Item por Open Interface
function fkg_item_id ( en_empresa_id in empresa.id%type
                     , ev_cod_item   in item.cod_item%type )
         return item.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela Item, conforme ID Empresa
function fkg_Item_id_conf_empr ( en_empresa_id  in  empresa.id%type
                               , ev_cod_item    in  Item.cod_item%TYPE )
         return Item.id%TYPE;

------------------------------------------------------------------------------------------------------

-- Fun��o retorna o Tipo do CT-e conforme o Id do CT-e.
-- Onde: 0 - CT-e Normal;
--       1 - CT-e de Complemento de Valores;
--       2 - CT-e de Anula��o de Valores;
--       3 - CT-e Substituto
function fkg_dm_tp_cte ( en_conhectransp_id  in  Conhec_Transp.Id%TYPE )
         return Conhec_Transp.dm_tp_cte%TYPE;

------------------------------------------------------------------------------------------------------

-- Fun��o retorna a data de emiss�o do conhecimento de transporte
function fkg_dt_emiss_ct ( en_conhectransp_id in Conhec_Transp.id%TYPE )
         return Conhec_Transp.dt_hr_emissao%TYPE;

------------------------------------------------------------------------------------------------------

-- Fun��o retorna o valor de presta��o do servi�o atrav�s do ID do conhecimento de transporte
function fkg_vl_valor_prest_ct ( en_conhectransp_id in Conhec_Transp.id%TYPE )
         return Conhec_Transp_Vlprest.vl_prest_serv%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o valor de ICMS atrav�s do ID do conhecimento de transporte
function fkg_vl_imp_trib_ct ( en_conhectransp_id in Conhec_Transp.id%TYPE )
         return Conhec_Transp_Imp.vl_imp_trib%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna true se o Ct-e a ser Anulado ou Substituido j� foi anulado ou substtuido anteriormente.
function fkg_val_ref_anul ( en_conhectransp_id    in Conhec_Transp.id%TYPE
                          , ev_nro_chave_cte_anul in conhec_transp_anul.nro_chave_cte_anul%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

function fkg_dmformaemiss_pelo_id ( en_conhectransp_id  in Conhec_Transp.id%TYPE )
         return Conhec_Transp.dm_forma_emiss%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna true se o Ct-e a ser Substituido j� foi substtuido anteriormente.
function fkg_val_ref_cte_sub ( en_conhectransp_id   in Conhec_Transp.id%TYPE
                             , ev_nro_chave_cte_sub in Conhec_Transp_Subst.nro_chave_cte_sub%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna CNPJ do Remente/Destinat�rio/Expedidor/recebedor/tomador atrav�s do Id do Conhecimento de Transporte
-- E parametro vv_pessoa onde assumir: R - Remetente, D- Destinarario, E - Expedidor, RC - Recebedor, T - Tomador, EM - Emitente
function fkg_cnpj_pelo_id ( en_conhectransp_id  in Conhec_Transp.id%TYPE
                          , vv_pessoa              varchar2 )
         return conhec_transp_rem.cnpj%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna IE do Remente/Destinat�rio/Expedidor/recebedor/tomador atrav�s do Id do Conhecimento de Transporte
-- E parametro vv_pessoa onde assumir: R - Remetente, D- Destinarario, E - Expedidor, RC - Recebedor, T - Tomador, EM - Emitente
function fkg_ie_pelo_id ( en_conhectransp_id  in Conhec_Transp.id%TYPE
                        , vv_pessoa varchar2 )
         return conhec_transp_rem.cnpj%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna UF de In�cio da Presta��o do Ct-e atrav�s do Id do Conhecimento de Transporte
function fkg_siglaufini_pelo_id ( en_conhectransp_id  in Conhec_Transp.id%TYPE )
         return conhec_transp.sigla_uf_ini%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna UF de Final da Presta��o do Ct-e atrav�s do Id do Conhecimento de Transporte
function fkg_siglauffim_pelo_id ( en_conhectransp_id  in Conhec_Transp.id%TYPE )
         return conhec_transp.sigla_uf_fim%TYPE;

-------------------------------------------------------------------------------------------------------

-- Se foi informado o Ct-e de Anula��o no grupo "Tomador n�o � contribuinte de do ICMS", o Ct-e de anula��o deve existir.
-- A fun��o retorna True se existir e False se n�o existir
function fkg_val_ref_cte_anul ( en_conhectransp_id    in Conhec_Transp.id%TYPE
                              , ev_nro_chave_cte_anul in Conhec_Transp_Anul.nro_chave_cte_anul%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o C�d. IBGE do Estado conformer a sigla do Estado.
function fkg_Estado_ibge_sigla ( ev_sigla_estado  in Estado.sigla_estado%TYPE )
         return Estado.ibge_estado%TYPE;

-------------------------------------------------------------------------------------------------------

-- Verifica se a empresa Utiliza Endere�o de Faturamento do destinat�rio na emiss�o da NFe
function fkg_empresa_util_end_fat_nfe ( en_empresa_id  in empresa.id%type )
         return empresa.dm_util_end_fat_nfe%type;

-------------------------------------------------------------------------------------------------------

-- Verifica se a empresa imprime o endere�o de entrega na DANFE
function fkg_empresa_impr_end_entr_nfe ( en_empresa_id  in empresa.id%type )
         return empresa.dm_impr_end_entr_nfe%type;
         
-------------------------------------------------------------------------------------------------------

--| Verifica se a empresa imprime o endere�o de Retirada na DANFE
function fkg_empresa_impr_end_retir_nfe ( en_empresa_id  in empresa.id%type )
         return empresa.dm_impr_end_entr_nfe%type;

-------------------------------------------------------------------------------------------------------

-- Verifica se a empresa valida a unidade de m�dida
function fkg_empresa_valid_unid_med ( en_empresa_id  in empresa.id%type )
         return empresa.dm_valid_unid_med%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento que acetar conforme o m�ximo ID de cada tabela

procedure pkb_acerta_sequence;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna 0 Se a empresa N�o valida totais da Nota Fiscal
-- ou 1 Se e empresa valida totais da Nota Fiscal
function fkg_valid_total_nfe_empresa ( en_empresa_id in empresa.id%type )
         return empresa.dm_valid_total_nfe%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna a sita��o da empresa: 0-Inativa ou 1-Ativa
function fkg_empresa_id_situacao ( en_empresa_id  in empresa.id%type )
         return empresa.dm_situacao%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna a sita��o da empresa: 0-Inativa ou 1-Ativa
function fkg_empresa_id_certificado_ok ( en_empresa_id  in empresa.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

--| Fun��o retorna o tipo de inclus�o da pessoa
function fkg_pessoa_id_dm_tipo_incl ( en_pessoa_id  in pessoa.id%type )
         return pessoa.dm_tipo_incl%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna "true" se o C�digo do IBGE da cidade pertente ao estado
-- e "false" se estiver incorreto
function fkg_ibge_cidade_por_sigla_uf ( en_ibge_cidade   in  cidade.ibge_cidade%type
                                      , ev_sigla_estado  in  estado.sigla_estado%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna a Vers�o v�lida do WSDL da NFE
function fkg_versaowsdl_nfe_estado ( en_estado_id in estado.id%type )
         return versao_wsdl.cd%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o Tipo Modal atrav�s do ID do Ct-e
-- Onde: 01-Rodovi�rio;
-- 02-A�reo;
-- 03-Aquavi�rio;
-- 04-Ferrovi�rio;
-- 05-Dutovi�rio
function fkg_dm_modal ( en_conhectransp_id   in   Conhec_Transp.Id%TYPE )
         return Conhec_Transp.dm_modal%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna True se existir informa��es referente a produtos perigosos.
function fkg_valid_prod_peri ( en_conhectransp_id   in   Conhec_Transp.Id%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna a quantidade de registros de lacres aquavi�rios por CT-e Aquavi�rio
function fkg_valid_lacre_aquav ( en_conhectranspaquav_id   in   conhec_transp_aquav.id%TYPE )
         return number;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna a quantidade de registros de Ordens de Coleta associados ao CT-e Rodovi�rio
function fkg_valid_ctrodo_occ ( en_conhectransprodo_id in ctrodo_occ.conhectransprodo_id%TYPE )
         return number;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna a quantidade de registros de Dados dos Ve�culos ao CT-e Rodovi�rio
function fkg_valid_ctrodo_veic ( en_conhectransprodo_id in ctrodo_occ.conhectransprodo_id%TYPE )
         return number;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna a quantidade de registros de vale ped�gio ao CT-e Rodovi�rio
function fkg_valid_ctrodo_valeped ( en_conhectransprodo_id in ctrodo_occ.conhectransprodo_id%TYPE )
         return number;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna True se existir informa��es sobre os ve�culos e False caso n�o houver.
function fkg_valid_ctrodo_veic_prop ( en_ctrodoveic_id in ctrodo_veic_prop.ctrodoveic_id%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna True se existir informa��es no Grupo Informa��es do(s) Motorista(s)
function fkg_valid_ctrodo_moto ( en_conhectransprodo_id in ctrodo_moto.conhectransprodo_id%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o tipo de servi�o do conhecimento de transporte
-- Onde: 0 - Normal; 1 - Subcontrata��o; 2 - Redespacho; 3 - Redespacho Intermediario
function fkg_dm_tp_serv ( en_conhectransp_id in Conhec_Transp.id%TYPE )
         return Conhec_Transp.dm_tp_serv%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela registro_in86
function fkg_registroin86_id ( en_cd  in Registro_In86.cod%TYPE )
         return Registro_In86.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna cod_mod_ref atrav�s do dm_tp_cte e ID do CTE
function fkg_ct_ref_moddoc ( en_conhectransp_id  in Conhec_Transp.id%TYPE
                           , en_dm_tp_cte        in Conhec_Transp.dm_tp_cte%TYPE)
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna serie_ref atrav�s do dm_tp_cte e ID do CTE
function fkg_ct_ref_serie ( en_conhectransp_id  in Conhec_Transp.id%TYPE
                          , en_dm_tp_cte        in Conhec_Transp.dm_tp_cte%TYPE)
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna num_doc_ref, atrav�s do dm_tp_cte e ID do CTE
function fkg_ct_ref_nro_nf ( en_conhectransp_id  in Conhec_Transp.id%TYPE
                           , en_dm_tp_cte        in Conhec_Transp.dm_tp_cte%TYPE)
         return number;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna dt_doc_ref atrav�s do dm_tp_cte e ID do CTE
function fkg_ct_ref_dtdoc ( en_conhectransp_id  in Conhec_Transp.id%TYPE
                          , en_dm_tp_cte        in Conhec_Transp.dm_tp_cte%TYPE)
         return date;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna cod_part_ref atrav�s do dm_tp_cte e ID do CTE
function fkg_ct_ref_codpart ( en_conhectransp_id  in Conhec_Transp.id%TYPE
                            , en_dm_tp_cte        in Conhec_Transp.dm_tp_cte%TYPE)
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Procedimento retornar dados do CTe referenciado, por meio de vari�veis "out"
procedure pkb_dados_ct_ref ( en_conhectransp_id  in   Conhec_Transp.id%TYPE
                           , en_dm_tp_cte        in   Conhec_Transp.dm_tp_cte%TYPE
                           , sv_cod_mod_ref      out  mod_fiscal.cod_mod%type
                           , sv_serie            out  conhec_transp.serie%type
                           , sn_nro_ct           out  conhec_transp.nro_ct%type
                           , sd_dt_hr_emissao    out  conhec_transp.dt_hr_emissao%type
                           , sv_cod_part         out  pessoa.cod_part%type
                           );

-------------------------------------------------------------------------------------------------------

-- Fun��o para formatar campos varchar2
-- Onde: ev_campo � o cont�udo que ser� formatado
--       en_qtdecasa � a quantidade de casas
--       ev_caracter o tipo de caracte
--       ev_lado � o lado utilizar 'D'para direita e 'E' para esquerda
function fkg_formatachar ( ev_campo    in varchar2
                         , ev_caracter in varchar2
                         , en_qtdecasa in number
                         , ev_lado     in varchar2 )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Procedimento para retornar valores de Impostos na tabela IMP_NOTA_FISCAL
procedure pkb_impostonf ( en_itemnf_id             in  item_nota_fiscal.id%type
                        , en_cod_tpimp             in  tipo_imposto.cd%type
                        , en_dm_tipo               in  imp_itemnf.dm_tipo%type
                        , sv_cod_st                out cod_st.cod_st%type
                        , sn_vl_base_calc          out imp_itemnf.vl_base_calc%type
                        , sn_aliq_apli             out imp_itemnf.aliq_apli%type
                        , sn_vl_imp_trib           out imp_itemnf.vl_imp_trib%type
                        , sn_perc_reduc            out imp_itemnf.perc_reduc%type
                        , sn_perc_adic             out imp_itemnf.perc_adic%type
                        , sn_qtde_base_calc_prod   out imp_itemnf.qtde_base_calc_prod%type
                        , sn_vl_aliq_prod          out imp_itemnf.vl_aliq_prod%type
                        , sn_vl_bc_st_ret          out imp_itemnf.vl_bc_st_ret%type
                        , sn_vl_icmsst_ret         out imp_itemnf.vl_icmsst_ret%type
                        , sn_perc_bc_oper_prop     out imp_itemnf.perc_bc_oper_prop%type
                        , sv_sigla_estado          out estado.sigla_estado%type
                        , sn_vl_bc_st_dest         out imp_itemnf.vl_bc_st_dest%type
                        , sn_vl_icmsst_dest        out imp_itemnf.vl_icmsst_dest%type
                        );

-------------------------------------------------------------------------------------------------------

-- Procedimento para retornar valores de Impostos na tabela CONHEC_TRANSP_IMP
procedure pkb_impostoct ( en_conhectransp_id  in  conhec_transp.id%TYPE
                        , en_cod_tpimp        in  tipo_imposto.cd%type
                        , sv_cod_st           out cod_st.cod_st%type
                        , sn_vl_base_calc     out conhec_transp_imp.vl_base_calc%type
                        , sn_aliq_apli        out conhec_transp_imp.aliq_apli%type
                        , sn_vl_imp_trib      out conhec_transp_imp.vl_imp_trib%type
                        , sn_perc_reduc       out conhec_transp_imp.perc_reduc%type
                        , sn_vl_cred          out conhec_transp_imp.vl_cred%type
                        , sn_dm_inf_imp       out conhec_transp_imp.dm_inf_imp%type
                        );

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna DM_TIPO_PESSOA da tabela pessoa atrav�s do ID pessoa
function fkg_pessoa_dmtipo_id ( en_pessoa_id  in Pessoa.id%TYPE )
         return Pessoa.dm_tipo_pessoa%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o IE Subst. conforme o ID da pessoa
function fkg_iest_pessoa_id ( en_pessoa_id in Pessoa.Id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o cod_participante pelo id_empresa
-- Fun��o retorna o c�digo da empresa atrav�s do id empresa em que est� relacionado.
function fkg_codpart_empresaid ( en_empresa_id in Empresa.Id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o Cod da tabale Mod_Fiscal
function fkg_cod_mod_id ( en_modfiscal_id  in Mod_Fiscal.id%TYPE )
         return Mod_Fiscal.cod_mod%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna cod_nat pelo ID da NAT_oper
function fkg_cod_nat_id ( en_natoper_id  in Nat_Oper.id%TYPE )
         return Nat_Oper.cod_nat%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o cod_ncm atrav�s do ID NCM
function fkg_cod_ncm_id ( en_ncm_id  in Ncm.id%TYPE )
         return Ncm.cod_ncm%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o Cod do Servi�o atrav�s do ID da tabela Tipo_Servico
function fkg_Tipo_Servico_cod ( en_tpservico_id  in Tipo_Servico.id%TYPE )
         return Tipo_Servico.cod_lst%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o tpservico_id atrav�s relacionado a tabela item atrav�s do c�digo do item
function fkg_Item_tpservico_conf_empr ( en_empresa_id  in  empresa.id%type
                                      , ev_cod_item    in  Item.cod_item%TYPE )
         return Item.tpservico_id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna a Desc do Servi�o atrav�s do ID da tabela Tipo_Servico
function fkg_Tipo_Servico_desc ( en_tpservico_id  in Tipo_Servico.id%TYPE )
         return Tipo_Servico.descr%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna a Data de Inclus�o da tabela alter_pessoa atrav�s do Pessoa_id
function fkg_dt_alt_pessoa_id ( en_pessoa_id  in Pessoa.id%TYPE
                              , ed_data       in date )
         return alter_pessoa.dt_alt%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna a Data de Inclus�o da tabela alter_item atrav�s do item_id
function fkg_dt_alt_item_id ( en_item_id  in Item.id%TYPE
                            , ed_data     in date )
         return alter_item.dt_ini%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o c�digo da vers�o da In que ser� exportada. Atrav�s do ID  disponibilizado na abertura_in86
function fkg_cod_in86_id ( en_versaoin86_id  in versao_in86.id%TYPE)
         return versao_in86.cd%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o CNPJ ou CPF conforme o ID da pessoa
function fkg_cnpjcpf_pessoa_id ( en_pessoa_id in Pessoa.Id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o sigla_estado que est� relacionado ao pessoa_id
function fkg_siglaestado_pessoaid ( en_pessoa_id in Pessoa.Id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o Inscri��o Estadual conforme o ID da pessoa
function fkg_ie_pessoa_id ( en_pessoa_id in Pessoa.Id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Fun��o retornar o valor do campo DM_PERM_EXP ID do Pa�s.
function fkg_perm_exp_pais_id  ( en_pais_id in pais.id%type )
         return pais.dm_perm_exp%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna se uma view est� configurada para ser utilizada em nosso sistema.
-- 0 - N�o e 1 - Sim
function fkg_existe_obj_util_integr ( ev_obj_name  in Obj_Util_Integr.obj_name%TYPE )
         return obj_util_integr.dm_ativo%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna 0 Se a empresa N�o valida totais entre as duplicatas, cobra��s e total da Nota Fiscal
-- ou 1 Se e empresa valida totais entre as duplicatas, cobra��s e total da Nota Fiscal
function fkg_valid_cobr_nf_empresa ( en_empresa_id in empresa.id%type )
         return empresa.dm_valid_cobr_nf%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o id da empresa atrav�s do ID da Nota Fiscal
function fkg_busca_empresa_nf ( en_notafiscal_id in Nota_Fiscal.id%type )
         return Empresa.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o id_erp do usu�rio atrav�s do ID do usu�rio
function fkg_id_erp_usuario_id ( en_usuario_id in neo_usuario.id%type )
         return neo_usuario.id_erp%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela Plano de Conta
function fkg_Plano_Conta_id ( ev_cod_cta    in Plano_Conta.cod_cta%TYPE
                            , en_empresa_id in Plano_Conta.empresa_id%TYPE)
         return Plano_Conta.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela Centro de Custo
function fkg_Centro_Custo_id ( ev_cod_ccus   in Centro_Custo.cod_ccus%TYPE
                             , en_empresa_id in Centro_Custo.empresa_id%TYPE)
         return Centro_Custo.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o Retorna o C�digo da Observa��o do Lan�amento Fiscal
function fkg_cd_obs_lancto_fiscal ( en_obslanctofiscal_id in obs_lancto_fiscal.id%type )
         return obs_lancto_fiscal.cod_obs%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o Sigla da tabela Unidade atrav�s do id.
function fkg_Unidade_sigla ( en_unidade_id  in Unidade.id%TYPE )
         return Unidade.sigla_unid%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o cd do Cfop
function fkg_cfop_cd ( en_cfop_id  in Cfop.id%TYPE )
         return Cfop.cd%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o C�digo da tabela Item
function fkg_Item_cod ( en_item_id  in Item.id%TYPE )
         return Item.cod_item%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela Infor_Comp_Dcto_Fiscal
function fkg_Infor_Comp_Dcto_Fiscal_cod( en_inforcompdctofiscal_id  in Infor_Comp_Dcto_Fiscal.id%TYPE )
         return Infor_Comp_Dcto_Fiscal.cod_infor%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o verifica se a data � valida
function fkg_data_valida ( ev_dt       in  varchar2
                         , ev_formato  in  varchar2 )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Procedimento cria usu�rio
procedure pkb_insere_usuario ( en_multorg_id  in  mult_org.id%type
                             , ev_login       in  neo_usuario.login%type
                             , ev_senha       in  neo_usuario.senha%type
                             , ev_nome        in  neo_usuario.nome%type
                             , ev_email       in  neo_usuario.email%type
                             );

-------------------------------------------------------------------------------------------------------

-- Procedimento bloqueia o usu�rio
procedure pkb_bloqueia_usuario ( ev_login    in  neo_usuario.login%type );

-------------------------------------------------------------------------------------------------------

-- Copia perfil de um usu�rio de origem para um usu�rio de destino
procedure pkb_copia_perfil_usuario ( ev_login_origem   in  neo_usuario.login%type
                                   , ev_login_destino  in  neo_usuario.login%type
                                   );

-------------------------------------------------------------------------------------------------------

-- Procedimento Copia Empresas de um usu�rio de origem para um usu�rio de destino
procedure pkb_copia_empresa_usuario ( ev_login_origem   in  neo_usuario.login%type
                                    , ev_login_destino  in  neo_usuario.login%type
                                    );

-------------------------------------------------------------------------------------------------------

--| Fun��o retornar se existe o CPF/CNPJ para integra��o EDI
function fkg_integr_edi ( en_multorg_id in param_integr_edi.multorg_id%type
                        , ev_cpf_cnpj   in param_integr_edi.cpf_cnpj%type
                        , en_dm_tipo    in param_integr_edi.dm_tipo%type
                        )
         return boolean;

-------------------------------------------------------------------------------------------------------

FUNCTION fkg_limpa_acento ( ev_string  in varchar2 )
         RETURN VARCHAR2;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna se o NCM obrigada a informa��o de medicamento para Nota Fiscal
function fkg_ncm_id_obrig_med_itemnf ( en_ncm_id  in ncm.id%type )
         return ncm.dm_obrig_med_itemnf%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o c�digo da vers�o do sistema conforme id
function fkg_versao_sistema_id ( en_versaosistema_id in versao_sistema.id%type )
         return versao_sistema.versao%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o c�digo da �ltima vers�o atual do sistema
function fkg_ultima_versao_sistema
         return versao_sistema.versao%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o par�metro de "Retorno da Informa��o de Hora de Autoriza��o/Cancelamento da empresa"
function fkg_ret_hr_aut_empresa_id ( en_empresa_id in empresa.id%type )
         return empresa.dm_ret_hr_aut%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o converte um BLOB em CLOB
FUNCTION fkg_blob_to_clob (blob_in IN BLOB)
RETURN CLOB;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o dm_mod_frete da tabela nota_fiscal_transp atrav�s do notafiscal_id
function fkg_modfrete_nftransp ( en_notafiscal_id  in nota_fiscal.id%type )
         return nota_fiscal_transp.dm_mod_frete%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o codigo do imposto atrav�s do id
function fkg_Tipo_Imposto_cd ( en_tipoimp_id  in Tipo_Imposto.id%TYPE )
         return Tipo_Imposto.cd%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID do conhecimento de transporte/frete atrav�s de empresa, indicadores de emiss�o e opera��o, pessoa, modelo fiscal, nro/s�rie/subs�rie do ct
function fkg_conhec_transp_id( en_empresa_id   in conhec_transp.empresa_id%type
                             , en_dm_ind_emit  in conhec_transp.dm_ind_emit%type
                             , en_dm_ind_oper  in conhec_transp.dm_ind_oper%type
                             , en_pessoa_id    in conhec_transp.pessoa_id%type
                             , en_modfiscal_id in conhec_transp.modfiscal_id%type
                             , en_nro_ct       in conhec_transp.nro_ct%type
                             , ev_serie        in conhec_transp.serie%type
                             , ev_subserie     in conhec_transp.subserie%type )
         return conhec_transp.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID do item da nota fiscal atrav�s do identificador da nota fiscal e do nro do item
function fkg_item_nota_fiscal_id( en_notafiscal_id in item_nota_fiscal.notafiscal_id%type
                                , en_nro_item      in item_nota_fiscal.nro_item%type )
         return item_nota_fiscal.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID do conhecimento de transporte/frete relacionado com o item da nota fiscal
function fkg_frete_itemnf_id( en_conhectransp_id   in conhec_transp.id%type
                            , en_notafiscal_id     in nota_fiscal.id%type
                            , en_itemnotafiscal_id in item_nota_fiscal.id%type )
         return frete_itemnf.id%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento de limpeza dos logs
procedure pkb_limpa_log;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorno o nome do usu�rio
function fkg_usuario_nome ( en_usuario_id in neo_usuario.id%type )
         return neo_usuario.nome%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da nota Fiscal de terceiro de armazenamento fiscal a partir do n�mero da chave de acesso
function fkg_nf_id_terceiro_pela_chave ( en_nro_chave_nfe in Nota_Fiscal.nro_chave_nfe%TYPE )
         return Nota_Fiscal.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorno o ID da tabela NEO_PAPEL conforme "sigla da descri��o"
function fkg_papel_id_conf_nome ( ev_nome in neo_papel.nome%type )
         return neo_papel.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o verifica se existe o papel informado para o usu�rio
function fkg_existe_usuario_papel ( en_usuario_id  in neo_usuario.id%type
                                  , en_papel_id    in neo_papel.id%type
                                  )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID do acesso de usu�rio/empresa
function fkg_usuario_empresa_id ( en_usuario_id  in neo_usuario.id%type
                                , en_empresa_id  in empresa.id%type
                                )
         return usuario_empresa.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorno o ID do acesso do usu�rio a Unidade Organizacional
function fkg_usuempr_unidorg_id ( en_usuempr_id  in usuario_empresa.id%type
                                , en_unidorg_id  in unid_org.id%type
                                )
         return usuempr_unidorg.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorno o c�digo de nome da empresa conforme seu ID
function fkg_cod_nome_empresa_id ( en_empresa_id in empresa.id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o C�digo de Consumo do Item de Servi�o Cont�nuo "COD_CONS_ITEM_CONT"
function fkg_codconsitemcont_id ( en_modfiscal_id  in  mod_fiscal.id%type
                                , ev_cod_cons      in  cod_cons_item_cont.cod_cons%type
								)
         return cod_cons_item_cont.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID do C�digo da Classe de Consumo do Item de Servi�o Cont�nuo
function fkg_class_cons_item_cont_id ( ev_cod_class in class_cons_item_cont.cod_class%type )
         return class_cons_item_cont.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retona o ID da empresa pelo ID da nota fiscal
function fkg_empresa_notafiscal ( en_notafiscal_id in nota_fiscal.id%type )
         return empresa.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o verifica se c�lcula ICMS-ST para a Nota Fiscal conforme Empresa
function fkg_dm_nf_calc_icmsst_empresa ( en_empresa_id in empresa.id%type )
         return empresa.dm_nf_calc_icmsst%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o verifica se a empresa ajusta o total da nota fiscal
function fkg_ajustatotalnf_empresa ( en_empresa_id in empresa.id%type )
         return empresa.dm_ajusta_total_nf%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o Retorna o Texto da Observa��o do Lan�amento Fiscal
function fkg_txt_obs_lancto_fiscal ( en_obslanctofiscal_id in obs_lancto_fiscal.id%type )
         return obs_lancto_fiscal.txt%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o Retorna a Inscri��o Estadual do Substituto conforme Empresa e Estado
function fkg_iest_empresa ( en_empresa_id  in empresa.id%type
                          , en_estado_id   in estado.id%type
                          )
         return ie_subst.iest%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna "true" se o id � v�lido e "false" se n�o �
function fkg_itemparamicmsst_id_valido ( en_id  in item_param_icmsst.id%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o que verifica a existencia de resgistro na Item_param_icmsst
function fkg_item_param_icmsst_id ( en_item_id	     in  item_param_icmsst.item_id%type
				  , en_empresa_id    in  item_param_icmsst.empresa_id%type
                                  , en_estado_id     in  item_param_icmsst.estado_id%type
              	                  , en_cfop_id_orig  in  item_param_icmsst.cfop_id%type
              	                  , ed_dt_ini	     in	 item_param_icmsst.dt_ini%type
              	                  , ed_dt_fin	     in	 item_param_icmsst.dt_fin%type
				  )
         return item_param_icmsst.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna CD atrav�s do tipo de par�metro
function fkg_cd_tipoparam ( en_tipoparam_id in tipo_param.id%type )
         return tipo_param.cd%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna ID do tipo de par�metro
function fkg_tipoparam_id ( ev_cd in tipo_param.cd%type )
         return tipo_param.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna a informa��o do "ID" do Valor do Tipo de Parametro salvo na pessoa
function fkg_pessoa_valortipoparam_id ( en_tipoparam_id in tipo_param.id%type
                                      , en_pessoa_id    in pessoa.id%type
									  )
         return valor_tipo_param.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o a informa��o do "CD" do Valor do Tipo de Parametro conforme o ID
function fkg_valortipoparam_id ( en_valortipoparam_id valor_tipo_param.id%type )
         return valor_tipo_param.cd%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna a informa��o do "c�digo" do Valor do Tipo de Parametro conforme pessoa
function fkg_pessoa_valortipoparam_cd ( ev_tipoparam_cd in tipo_param.cd%type
                                      , en_pessoa_id    in pessoa.id%type
									  )
         return valor_tipo_param.cd%type;

-------------------------------------------------------------------------------------------------------

-- Retorna o CD do c�digo de tributa��o do munic�pio, conforme o ID
function fkg_codtribmunicipio_cd ( en_codtribmunicipio_id in cod_trib_municipio.id%type )
         return cod_trib_municipio.cod_trib_municipio%type;

-------------------------------------------------------------------------------------------------------

-- Retorna o ID do c�digo de tributa��o do munic�pio, conforme o CD e Cidade
function fkg_codtribmunicipio_id ( ev_codtribmunicipio_cd  in cod_trib_municipio.cod_trib_municipio%type
                                 , en_cidade_id            in cod_trib_municipio.cidade_id%type
                                 )
         return cod_trib_municipio.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorma a descri��o da cidade conforme o IBGE dela
function fkg_descr_cidade_conf_ibge ( ev_ibge_cidade  in cidade.ibge_cidade%type )
         return cidade.descr%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID do Tipo de C�digo de arquivo
function fkg_tipocodarq_id ( ev_cd in tipo_cod_arq.cd%type )
         return tipo_cod_arq.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o c�digo do "Tipo de C�digo de arquivo" por pais

function fkg_cd_pais_tipo_cod_arq ( en_pais_id        in pais.id%type
                                  , en_tipocodarq_id  in tipo_cod_arq.id%type
                                  )
         return pais_tipo_cod_arq.cd%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o c�digo do "Tipo de C�digo de arquivo" por estado
function fkg_cd_estado_tipo_cod_arq ( en_estado_id in estado.id%type
                                    , en_tipocodarq_id in tipo_cod_arq.id%type
                                    )
         return estado_tipo_cod_arq.cd%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o c�digo do "Tipo de C�digo de arquivo" por cidade
function fkg_cd_cidade_tipo_cod_arq ( en_cidade_id in cidade.id%type
                                    , en_tipocodarq_id in tipo_cod_arq.id%type
                                    )
         return cidade_tipo_cod_arq.cd%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o sigla_estado que est� relacionado ao pessoa_id
function fkg_sigla_estado_empresa ( en_empresa_id in empresa.id%type )
         return estado.sigla_estado%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o verifica se c�lcula ICMS-Normal para a Nota Fiscal conforme Empresa
function fkg_dm_nf_calc_icms_empresa ( en_empresa_id in empresa.id%type )
         return empresa.dm_nf_calc_icms%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento Copia o perfil de acesso de um usu�rio (papeis e empresas)
procedure pkb_copia_perfil_acesso_usu ( ev_login_origem   in  neo_usuario.login%type
                                      , ev_login_destino  in  neo_usuario.login%type
                                      );

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o valor do par�metro "Ajusta valores dos itens da NF com o Total" conforme empresa
function fkg_ajustvlr_inf_conf_empresa ( en_empresa_id in empresa.id%type )
         return empresa.dm_ajust_vlr_itemnf%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o valor do par�metro "Integra o Item (produto/servi�o)" conforme empresa
function fkg_integritem_conf_empresa ( en_empresa_id in empresa.id%type )
         return empresa.dm_integr_item%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna par�metro de valida��o de CFOP por destinat�rio - conforme o identificador da empresa.
function fkg_dm_valcfoppordest_empresa ( en_empresa_id in empresa.id%type )
         return empresa.dm_valida_cfop_por_dest%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o para retornar indicador de opera��o da nota fiscal - nota_fiscal.dm_ind_oper -> 0-entrada, 1-sa�da.
function fkg_recup_dmindoper_nf_id ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal.dm_ind_oper%type;

-------------------------------------------------------------------------------------------------------

-- Retorna o E-mail do usu�rio do Sistema conforme multorg_id e ID_ERP
function fkg_usuario_email_conf_erp ( en_multorg_id in mult_org.id%type
                                    , ev_id_erp     in neo_usuario.id_erp%type
                                    )
         return neo_usuario.email%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o para retornar o identificador do modelo fiscal da nota fiscal - nota_fiscal.modfiscal_id - atrav�s do identificador da nota fiscal.
function fkg_recup_modfisc_id_nf ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal.modfiscal_id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o recupera a Ordem de impress�o dos itens na DANFE na empresa
function fkg_dm_ordimpritemdanfe_empr ( en_empresa_id empresa.id%type )
         return empresa.dm_ord_impr_item_danfe%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o para retornar se a empresa permite valida��o de cfop de cr�dito de pis/cofins para notas fiscais de pessoa f�sica.
function fkg_empr_val_cred_pf_pc ( en_empresa_id empresa.id%type )
         return empresa.dm_val_gera_cred_pf_pc%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o para retornar se a empresa permite Ajustar base de c�lculo de imposto
function fkg_empr_ajust_base_imp ( en_empresa_id in empresa.id%type )
         return empresa.dm_ajust_base_imp%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna ibge_estado conforme o empresa_id
function fkg_ibge_estado_empresa_id ( ev_empresa_id  in empresa.id%type )
         return estado.ibge_estado%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o para verificar campos Flex Field - FF.
function fkg_ff_verif_campos( ev_obj_name in obj_util_integr.obj_name%type
                            , ev_atributo in ff_obj_util_integr.atributo%type
                            , ev_valor    in varchar2 )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Fun��o para retornar o dom�nio - tipo do campo Flex Field - FF, atrav�s do objeto e do atributo.
function fkg_ff_retorna_dmtipocampo( ev_obj_name in obj_util_integr.obj_name%type
                                   , ev_atributo in ff_obj_util_integr.atributo%type )
         return ff_obj_util_integr.dm_tipo_campo%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o para retornar o tamanho do campo Flex Field - FF, atrav�s do objeto e do atributo.
function fkg_ff_retorna_tamanho( ev_obj_name in obj_util_integr.obj_name%type
                               , ev_atributo in ff_obj_util_integr.atributo%type )
         return ff_obj_util_integr.tamanho%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o para retornar a quantidade em decimal do campo Flex Field - FF, atrav�s do objeto e do atributo.
function fkg_ff_retorna_decimal( ev_obj_name in obj_util_integr.obj_name%type
                               , ev_atributo in ff_obj_util_integr.atributo%type )
         return ff_obj_util_integr.qtde_decimal%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o para retornar o valor dos campos Flex Field - FF - tipo DATA.
function fkg_ff_ret_vlr_data( ev_obj_name in obj_util_integr.obj_name%type
                            , ev_atributo in varchar2
                            , ev_valor    in varchar2 )
         return date;

-------------------------------------------------------------------------------------------------------

-- Fun��o para retornar o valor dos campos Flex Field - FF - tipo NUM�RICO.
function fkg_ff_ret_vlr_number( ev_obj_name in obj_util_integr.obj_name%type
                              , ev_atributo in varchar2
                              , ev_valor    in varchar2 )
         return number;

-------------------------------------------------------------------------------------------------------

-- Fun��o para retornar o valor dos campos Flex Field - FF - tipo CARACTERE.
function fkg_ff_ret_vlr_caracter( ev_obj_name in obj_util_integr.obj_name%type
                                , ev_atributo in varchar2
                                , ev_valor    in varchar2 )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorno o CPF ou CNPJ com mascara
function fkg_masc_cpf_cnpj ( ev_cpf_cnpj in varchar2 )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID do Tipo de Operacao do CFOP
function fkg_tipooperacao_id ( ev_id in tipo_operacao.id%type )
         return tipo_operacao.cd%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retornda o CD do Tipo de Opera��o conforme CD do CFOP
function fkg_cd_tipooper_conf_cfop ( ev_cfop_cd in cfop.cd%type )
         return tipo_operacao.cd%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o verifica o tipo de formato de data do retorno da informa��o para o ERP
function fkg_empresa_dm_form_dt_erp ( en_empresa_id in Empresa.id%type )
         return empresa.dm_form_dt_erp%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna c�digo da conta do plano de contas atrav�s do ID do Plano de Conta
function fkg_cd_plano_conta ( en_planoconta_id in plano_conta.id%type )
         return plano_conta.cod_cta%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna c�digo do centro de custo atrav�s do ID do Centro de Custo
function fkg_cd_centro_custo ( en_centrocusto_id in centro_custo.id%type )
         return centro_custo.cod_ccus%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o identificador do objeto de integra��o atrav�s do c�digo
function fkg_recup_objintegr_id( ev_cd in obj_integr.cd%type )
         return obj_integr.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID do tabela TIPO_OBJ_INTEGR, conforme OBJINTEGR_ID e C�digo

function fkg_tipoobjintegr_id ( en_objintegr_id      in tipo_obj_integr.objintegr_id%type
                              , ev_tipoobjintegr_cd  in tipo_obj_integr.cd%type
                              )
         return tipo_obj_integr.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o CD do tabela TIPO_OBJ_INTEGR, conforme ID

function fkg_tipoobjintegr_cd ( en_tipoobjintegr_id  in tipo_obj_integr.id%type
                              )
         return tipo_obj_integr.cd%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna a �ltima data de fechamento fiscal por empresa
function fkg_recup_dtult_fecha_empresa( en_empresa_id   in fecha_fiscal_empresa.empresa_id%type
                                      , en_objintegr_id in fecha_fiscal_empresa.objintegr_id%type )
         return fecha_fiscal_empresa.dt_ult_fecha%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna se o per�odo informado est� fechado - fechamento fiscal por empresa - 0-n�o ou 1-sim
function fkg_periodo_fechado_empresa( en_empresa_id   in fecha_fiscal_empresa.empresa_id%type
                                    , en_objintegr_id in fecha_fiscal_empresa.objintegr_id%type
                                    , ed_dt_ult_fecha in fecha_fiscal_empresa.dt_ult_fecha%type )
         return number;

-------------------------------------------------------------------------------------------------------

-- Fun��o verifica se existe o ID do Complemento do Item
function fkg_existe_item_compl ( en_inf_item_compl_id in item_compl.item_id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o para recuperar as pessoas de mesmo cpf ou cnpj
function fkg_ret_string_id_pessoa ( en_multorg_id  in mult_org.id%type
                                  , ev_cpf_cnpj    in varchar2
                                  )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID do Valor do Tipo de Par�metro
function fkg_valor_tipo_param_id ( en_tipoparam_id          in tipo_param.id%type
                                 , ev_valor_tipo_param_cd   in valor_tipo_param.cd%type
                                 )
         return valor_tipo_param.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID do par�metro de pessoa
function fkg_pessoa_tipo_param_id ( en_pessoa_id          in pessoa.id%type
                                  , en_tipoparam_id       in tipo_param.id%type
                                  , en_valortipoparam_id  in valor_tipo_param.id%type
                                  )
         return pessoa_tipo_param.id%Type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o valor do campo DM_TROCA_CFOP_NF por empresa
function fkg_empresa_troca_cfop_nf ( en_empresa_id in empresa.id%type )
         return empresa.dm_troca_cfop_nf%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna "true" se o item_id possui c�digo de NCM v�lido e "false" se n�o possui.
function fkg_item_ncm_valido ( en_item_id  in Item.id%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o identificador do NCM atrav�s do identificador do Item do produto
function fkg_ncm_id_item ( en_item_id  in item.id%type )
         return ncm.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela tipo_ret_imp conforme o codigo de reten��o e o id do tipo do imposto.
function fkg_tipo_ret_imp ( en_multorg_id  in tipo_ret_imp.multorg_id%TYPE
                          , en_cd_ret      in tipo_ret_imp.cd%TYPE
                          , en_tipoimp_id  in tipo_imposto.id%TYPE
                          )
         return tipo_ret_imp.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o c�digo do tipo de reten��o do imposto atrav�s do id
function fkg_tipo_ret_imp_cd ( en_tiporetimp_id  in tipo_ret_imp.id%TYPE )
         return tipo_ret_imp.cd%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna verifica se a empresa Gera tributa��es de impostos
function fkg_empresa_gera_tot_trib ( en_empresa_id in empresa.id%type )
         return empresa.dm_gera_tot_trib%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID do Controle de Vers�o Cont�bil conforme UK (unique key)
function fkg_ctrlversaocontabil_id ( en_empresa_id  in empresa.id%type
                                   , ev_cd          in ctrl_versao_contabil.cd%type
                                   , en_dm_tipo     in ctrl_versao_contabil.dm_tipo%type
                                   )
         return ctrl_versao_contabil.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o verifica se o valor do ID existe no Controle de Vers�o Cont�bil
function fkg_existe_ctrlversaocontabil ( en_ctrlversaocontabil_id in ctrl_versao_contabil.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o para retornar se a empresa permite Ajustar valores de impostos de importa��o com suframa
function fkg_empr_ajust_desc_zfm_item ( en_empresa_id in empresa.id%type )
         return empresa.dm_ajust_desc_zfm_item%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o para retornar o tipo de emitente da nota fiscal - nota_fiscal.dm_ind_emit = 0-emiss�o pr�pria, 1-terceiros
function fkg_dmindemit_notafiscal ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal.dm_ind_emit%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o para retornar a finalidade da nota fiscal - nota_fiscal.dm_fin_nfe = 1-NF-e normal, 2-NF-e complementar, 3-NF-e de ajuste
function fkg_dmfinnfe_notafiscal ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal.dm_fin_nfe%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o para retornar a sigla do estado do emitente da nota fiscal
function fkg_uf_notafiscalemit ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal_emit.uf%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o para retornar o CNPJ do emitente da nota fiscal
function fkg_cnpj_notafiscalemit ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal_emit.cnpj%type;
         
-------------------------------------------------------------------------------------------------------

-- Fun��o para retornar a sigla do estado do destinat�rio da nota fiscal
function fkg_uf_notafiscaldest ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal_dest.uf%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o para retornar o identificador de pessoa da nota fiscal
function fkg_pessoa_notafiscal_id ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal.pessoa_id%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto ICMS - Par�metro para Notas Fiscais com Emiss�o Pr�pria
function fkg_empresa_dmvalimp_emis ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valid_imp%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto ICMS60 - Par�metro para Notas Fiscais com Emiss�o Pr�pria
function fkg_empresa_dmvalicms60_emis ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valid_icms60%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida Bases de ICMS - Par�metro para Notas Fiscais com Emiss�o Pr�pria

function fkg_empresa_dmvalbaseicms_emis ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valid_base_icms%type;         

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto IPI - Par�metro para Notas Fiscais com Emiss�o Pr�pria
function fkg_empresa_dmvalipi_emis ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_ipi%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto PIS - Par�metro para Notas Fiscais com Emiss�o Pr�pria
function fkg_empresa_dmvalpis_emis ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_pis%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto Cofins - Par�metro para Notas Fiscais com Emiss�o Pr�pria
function fkg_empresa_dmvalcofins_emis ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_cofins%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto ICMS - Par�metro para Notas Fiscais com Emiss�o de Terceiros
function fkg_empresa_dmvalimp_terc ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valid_imp_terc%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto ICMS60 - Par�metro para Notas Fiscais com Emiss�o de Terceiros
function fkg_empresa_dmvalicms60_terc ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valid_icms60_terc%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida Bases de ICMS - Par�metro para Notas Fiscais com Emiss�o de Terceiros

function fkg_empresa_dmvalbaseicms_terc ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valid_base_icms_terc%type;         

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida Bases de ICMS - Par�metro para Forma de demonstra��o das bases de ICMS
function fkg_empresa_dmformademb_icms ( en_empresa_id in Empresa.id%type )
         return empresa.dm_forma_dem_base_icms%type ;

-------------------------------------------------------------------------------------------------------
-- Procedimento verifica se a empresa valida o imposto IPI - Par�metro para Notas Fiscais com Emiss�o de Terceiros
function fkg_empresa_dmvalipi_terc ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_ipi_terc%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto PIS - Par�metro para Notas Fiscais com Emiss�o de Terceiros
function fkg_empresa_dmvalpis_terc ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_pis_terc%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto Cofins - Par�metro para Notas Fiscais com Emiss�o de Terceiros
function fkg_empresa_dmvalcofins_terc ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_cofins_terc%type;

-------------------------------------------------------------------------------------------------------
--| Fun��o retorna o ID da tabela GRUPO_PAT

function fkg_grupopat_id ( en_multorg_id    in  mult_org.id%type
                         , ev_cod_grupopat  in  grupo_pat.cd%type )
         return grupo_pat.id%TYPE;
         
-------------------------------------------------------------------------------------------------------

--| Fun��o retorna o ID da tabela SUBGRUPO_PAT

function fkg_subgrupopat_id ( ev_cod_subgrupopat  in  subgrupo_pat.cd%type
                            , en_grupopat_id      in  grupo_pat.id%type )
         return subgrupo_pat.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o returna TRUE se existe o grupo ou FALSE caso contr�rio

function fkg_existe_grupo_pat ( en_grupopat_id in grupo_pat.id%type )
         return boolean;
         
-------------------------------------------------------------------------------------------------------

-- Fun��o returna TRUE se existe o subgrupo ou FALSE caso contr�rio

function fkg_existe_subgrupo_pat ( en_subgrupopat_id in subgrupo_pat.id%type )
         return boolean;         

-------------------------------------------------------------------------------------------------------

--| Fun��o retorna o ID da tabela REC_IMP_SUBGRUPO_PAT

function fkg_recimpsubgrupopat_id ( en_subgrupopat_id  in subgrupo_pat.id%type
                                  , en_tipoimp_id      in tipo_imposto.id%type )
         return rec_imp_subgrupo_pat.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o returna TRUE se existe o imposto do subgrupo ou FALSE caso contr�rio

function fkg_existe_imp_subgrupo_pat ( en_recimpsubgrupo_id in rec_imp_subgrupo_pat.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

--| Fun��o retorna o ID da tabela NF_BEM_ATIVO_IMOB

function fkg_nfbemativoimob_id ( en_bemativoimob_id  in   bem_ativo_imob.id%type
                               , en_dm_ind_emit      in   nf_bem_ativo_imob.dm_ind_emit%type
                               , en_pessoa_id        in   nf_bem_ativo_imob.pessoa_id%type
                               , en_modfiscal_id     in   nf_bem_ativo_imob.modfiscal_id%type
                               , ev_serie            in   nf_bem_ativo_imob.serie%type
                               , ev_num_doc          in   nf_bem_ativo_imob.num_doc%type )
         return nf_bem_ativo_imob.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna TRUE se existe o documento fiscal do bem ou FALSE caso contr�rio

function fkg_existe_nf_bem_ativo_imob ( en_nfbemativoimob_id in nf_bem_ativo_imob.id%type )
         return boolean;
         
-------------------------------------------------------------------------------------------------------

--| Fun��o retorna o ID da tabela ITNF_BEM_ATIVO_IMOB

function fkg_itnfbemativoimob_id ( en_nfbemativoimob_id in nf_bem_ativo_imob.id%type
                                 , en_num_item          in itnf_bem_ativo_imob.num_item%type )
         return itnf_bem_ativo_imob.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna TRUE se existe o item do documento fiscal do bem ou FALSE caso contr�rio

function fkg_existe_itnf_bem_ativo_imob ( en_itnfbemativoimob_id in itnf_bem_ativo_imob.id%type )
         return boolean;
         
-------------------------------------------------------------------------------------------------------

--| Fun��o retorna o ID da tabela REC_IMP_BEM_ATIVO_IMOB

function fkg_recimpbemativoimob_id ( en_bemativoimob_id in bem_ativo_imob.id%type
                                   , en_tipoimp_id      in tipo_imposto.id%type )
         return rec_imp_bem_ativo_imob.id%TYPE;
         
-------------------------------------------------------------------------------------------------------

-- Fun��o retorna TRUE se existe o imposto do bem ou FALSE caso contr�rio

function fkg_existe_rec_imp_bem_ativo ( en_recimpbemativoimob_id in rec_imp_bem_ativo_imob.id%type )
         return boolean;                  

-------------------------------------------------------------------------------------------------------

-- Fun��o para retorno o "C�lculo do Imposto do Patrim�nio" da Empresa

function fkg_empresa_calc_imp_patr ( en_empresa_id in empresa.id%type )
         return empresa.dm_calc_imp_patr%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela Pessoa atrav�s do CNPJ ou CPF e da Sigla do Estado - UF
function fkg_pessoa_id_cpf_cnpj_uf ( en_multorg_id  in mult_org.id%type
                                   , en_cpf_cnpj    in varchar2
                                   , ev_uf          in varchar2
                                   )
         return pessoa.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o para recuperar par�metro que indica se a empresa comp�e o tipo de c�digo de cr�dito atrav�s do tipo de embalagem.
function fkg_dmutilprocemb_tpcred_empr( en_empresa_id in empresa.id%type )
         return empresa.dm_util_proc_emb_tipocred%type;

-------------------------------------------------------------------------------------------------------

--| Fun��o retorna cod_class da tabela class_cons_item_cont conforme o id

function fkg_cod_class ( ev_classconsitemcont_id in class_cons_item_cont.id%type )
         return class_cons_item_cont.cod_class%type;

-------------------------------------------------------------------------------------------------------

--| Fun��o retorna o cod_cons da tabela cod_cons_item_cont

function fkg_codconsitemcont_cod( en_codconsitemcont_id  in cod_cons_item_cont.id%TYPE )
         return cod_cons_item_cont.cod_cons%type;
         
-------------------------------------------------------------------------------------------------------

--| Fun��o que verifica se o N�mero de controle da FCI do Item � v�lido.
-- � v�lido o n�mero da FCI que � de tamanho 36, cont�m apenas caracteres de "A" a "F", algarismos
-- e o caractere de h�fen "-" nas posi��es 9, 14, 19 e 24.

function fkg_nro_fci_valido ( ev_nro_fci in item_nota_fiscal.nro_fci%type )
         return boolean;
         
-------------------------------------------------------------------------------------------------------

--| Fun��o retorna o cd da tabela tipo_evento_sefaz conforme o ID

function fkg_tipoeventosefaz_cd( en_tipoeventosefaz_id  in tipo_evento_sefaz.id%TYPE )
         return tipo_evento_sefaz.cd%type;
         
-------------------------------------------------------------------------------------------------------

--| Fun��o retorna o ID da tabela tipo_evento_sefaz conforme o CD

function fkg_tipoeventosefaz_id( ev_cd  in tipo_evento_sefaz.cd%TYPE )
         return tipo_evento_sefaz.id%type;

-------------------------------------------------------------------------------------------------------

--| Fun��o retorna o par�matro da Empresa de "Retorna Consulta de CTe sem XML de Terceiro"

function fkg_ret_cons_cte_sem_xml ( en_empresa_id in Empresa.id%type )
         return empresa.dm_ret_cons_cte_sem_xml%type;
         
-------------------------------------------------------------------------------------------------------

--| Fun��o retorna o CNPJ da tabela pais_cnpj conforme o id do PAIS e da CIDADE

function fkg_paiscnpj_cnpj ( en_pais_id    in pais.id%TYPE
                           , en_cidade_id  in cidade.id%TYPE )
         return pais_cnpj.cnpj%type;
         
-------------------------------------------------------------------------------------------------------

-- Fun��o retorna a inscri��o municipal da empresa

function fkg_inscr_mun_empresa ( en_empresa_id  in Empresa.id%TYPE )
         return Juridica.im%TYPE;
         
-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o c�digo do IBGE da cidade da empresa conforme o ID da empresa

function fkg_ibge_cidade_empresa ( en_empresa_id  in Empresa.id%TYPE )
         return cidade.ibge_cidade%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o valor de toler�ncia para os valores de documentos fiscais (nf, cf, ct) e caso n�o exista manter 0.03

function fkg_vlr_toler_empresa ( en_empresa_id  in empresa.id%type
                               , ev_opcao       in varchar2 )
         return number;

-------------------------------------------------------------------------------------------------------

-- Procedimento retorna os par�metros de Difirencial de Al�quota para a EFD ICMS/IPI
procedure pkb_param_difal_efd_icms_ipi ( en_empresa_id                   in empresa.id%type
                                       , sn_dm_lcto_difal               out param_efd_icms_ipi.dm_lcto_difal%type
                                       , sn_codajsaldoapuricms_id_difal out param_efd_icms_ipi.codajsaldoapuricms_id_difal%type
                                       , sn_codocorajicms_id_difal      out param_efd_icms_ipi.codocorajicms_id_difal%type
                                       , sn_codajsaldoapuricms_id_difpa out param_efd_icms_ipi.codajsaldoapuricms_id_difpart%type
                                       );

-------------------------------------------------------------------------------------------------------

-- Procedimento retorna os par�metros de Difirencial de Al�quota para a EFD ICMS/IPI
function fkg_param_ciap_efd_icms_ipi ( en_empresa_id                   in empresa.id%type
                                     )
         return param_efd_icms_ipi.codajsaldoapuricms_id_ciap%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento retorna os par�metros C�digo de Ajuste de IPI N�o destacado para a EFD ICMS/IPI
function fkg_par_ipi_naodest_efdicmsipi ( en_empresa_id                   in empresa.id%type
                                        )
         return param_efd_icms_ipi.codajapuripi_id_ipi_nao_dest%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o Par�metro de Indicador de Tributa��o do Totalizador Parcial de ECF da empresa
function fkg_indtribtotparcredz_empresa ( en_empresa_id                   in empresa.id%type
                                        )
         return empresa.dm_ind_trib_tot_parc_redz%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o para retornar o identificador do relacionamento de item/componente e insumo
function fkg_item_insumo_id( en_item_id     in item.id%type
                           , en_item_id_ins in item.id%type
                           )
         return item_insumo.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o para retornar se o relacionamento de item/componente e insumo j� existe
function fkg_existe_iteminsumo( en_iteminsumo_id in item_insumo.id%type
                              )
         return boolean;
         
-------------------------------------------------------------------------------------------------------
-- Fun��o retorna o ID da tabela NFINFOR_FISCAL conforme o NOTAFISCAL_ID

function fkg_nfinfor_fiscal_id ( en_notafiscal_id      in nota_fiscal.id%type
                               , en_obslanctofiscal_id in obs_lancto_fiscal.id%type )
         return nfinfor_fiscal.id%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna o COD_OBS da tabela OBS_LANCTO_FISCAL conforme o NFINFORFISCAL_ID

function fkg_cod_obs_nfinfor_fiscal ( en_nfinforfiscal_id in nfinfor_fiscal.id%type )
         return obs_lancto_fiscal.cod_obs%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna o NRO_ITEM da tabela ITEM conforme o ITEMNOTAFISCAL_ID

function fkg_nro_item ( en_itemnotafiscal_id  in item_nota_fiscal.id%type )
         return item_nota_fiscal.nro_item%type;        

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna o c�digo de ajuste das obriga��es a recolher atrav�s do identificador
function fkg_cd_ajobrigrec ( en_ajobrigrec_id in aj_obrig_rec.id%type )
         return aj_obrig_rec.cd%type;

-------------------------------------------------------------------------------------------------------

--| Retorna o par�metro de empresa EMPR_PARAM_CONS_MDE.DM_REG_CO_MDE_AUT

function fkg_empresa_reg_co_mde_aut ( en_empresa_id                   in empresa.id%type
                                    )
         return empr_param_cons_mde.dm_reg_co_mde_aut%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o IBGE_CIDADE conforme Estado e Descri��o da Cidade

function fkg_ibge_cidade_dados ( ev_sigla_estado in estado.sigla_estado%type 
                               , ev_descr_cidade in cidade.descr%type
                               )
         return cidade.ibge_cidade%type;

-------------------------------------------------------------------------------------------------------

--| Retorna o par�metro de empresa EMPR_PARAM_CONS_MDE.DM_REG_MDE_AUT

function fkg_empresa_reg_mde_aut ( en_empresa_id in empresa.id%type )
         return empr_param_cons_mde.dm_reg_mde_aut%type;
         
-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o c�digo do bem do ativo imobilizado conforme o id

function fkg_cod_ind_bem_id ( en_bemativoimob_id in bem_ativo_imob.id%type )
         return bem_ativo_imob.cod_ind_bem%type;
         
-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o C�digo da tabela SUBGRUPO_PAT

function fkg_subgrupopat_cd ( en_subgrupopat_id  in subgrupo_pat.id%type )
         return subgrupo_pat.cd%type;
         
-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o CD da tabela GRUPO_PAT conforme o ID da tabela SUBGRUPO_PAT

function fkg_grupopat_cd_subgrupo_id ( en_subgrupopat_id  in subgrupo_pat.id%type )
         return grupo_pat.cd%type;
         
-------------------------------------------------------------------------------------------------------

-- Fun��o retorna TRUE se existe o Plano de Contas ou FALSE caso n�o exista

function fkg_existe_plano_conta ( en_planoconta_id in plano_conta.id%type )
         return boolean;
         
-------------------------------------------------------------------------------------------------------

-- Fun��o retorna TRUE se existe o Plano de Contas Referencial ou FALSE caso n�o exista

function fkg_existe_pc_referen ( en_pcreferen_id in pc_referen.id%type )
         return boolean;
         
-------------------------------------------------------------------------------------------------------

-- Fun��o retorna TRUE se existe o Centro de Custo ou FALSE caso n�o exista

function fkg_existe_centro_custo ( en_centrocusto_id in centro_custo.id%type )
         return boolean;
         
-------------------------------------------------------------------------------------------------------

-- Fun��o retorna TRUE se existe o Hist�rico Padr�o ou FALSE caso n�o exista

function fkg_existe_hist_padrao ( en_histpadrao_id in hist_padrao.id%type )
         return boolean;
         
-------------------------------------------------------------------------------------------------------

--| Retorna a quantidade de registros da tabela enviada no par�metro

function fkg_quantidade ( ev_obj    varchar2 )
         return number;
         
-------------------------------------------------------------------------------------------------------

--| Monta o objeto conforme aspas, owner e dblink

function fkg_monta_obj ( ev_obj         in varchar2
                       , ev_aspas       in varchar2
                       , ev_owner_obj   in varchar2
                       , ev_nome_dblink in varchar2
                       , en_dm_ind_emit in number default null
                       )
         return varchar2; 

-------------------------------------------------------------------------------------------------------

--| Retorna a descri��o (nome) da cidade conforme o ID

function fkg_cidade_descr ( en_cidade_id   in cidade.id%type )
         return cidade.descr%type;
         
-------------------------------------------------------------------------------------------------------

-- Retorna o ID do mult_org vinculado ao usu�rio

function fkg_multorg_id_usuario ( en_usuario_id in neo_usuario.id%type )
         return mult_org.id%type; 
         
-------------------------------------------------------------------------------------------------------

-- Retorna o tipo de ambiente da nota fiscal

function fkg_dm_tp_amb_nf ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal.dm_tp_amb%type;

-------------------------------------------------------------------------------------------------------

-- Retorna o valor do Par�metro Gerar XML WS Sinal Suframa

function fkg_cfop_gerar_sinal_suframa ( en_empresa_id in empresa.id%type
                                      , en_cfop_id    in cfop.id%type
                                      )
         return param_cfop_empresa.dm_gera_sinal_suframa%type;
         
-------------------------------------------------------------------------------------------------------

--
-- Recebe como entrada um texto(ev_texto) separado por algum simbolo(ev_separador)
-- e devolve um array onde cada posi��o do array � uma palavra que estava entre o separador.
--

procedure pkb_dividir ( ev_texto       in     varchar2
                      , ev_separador   in     varchar2
                      , estv_texto     in out dbms_sql.varchar2_table );       

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna c�digo da conta + descri��o do plano de contas atrav�s do ID do Plano de Conta

function fkg_texto_plano_conta_id ( en_planoconta_id in plano_conta.id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna c�digo do centro de custo + descri��o atrav�s do ID do Centro de Custo

function fkg_texto_centro_custo_id ( en_centrocusto_id in centro_custo.id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID "CNAE"conforme o C�digo

function fkg_id_cnae_cd ( en_cnae_cd in cnae.cd%TYPE )
         return cnae.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o C�digo do "CNAE" conforme ID

function fkg_cd_cnae_id ( en_cnae_id in cnae.id%TYPE )
         return cnae.cd%TYPE;
         
-------------------------------------------------------------------------------------------------------

--| Fun��o retorna o NOME da tabela NEO_PAPEL conforme ID

function fkg_papel_nome_conf_id ( en_papel_id in neo_papel.id%type )
         return neo_papel.nome%type;   
         
-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o campo EMPRESA_ID conforme o multorg_id e (CPF ou CNPJ)
-- Esta fun��o � uma c�pia da fkg_empresa_id_pelo_cpf_cnpj, por�m essa nova n�o considera
-- se a empresa est� ativa ou n�o.

function fkg_empresa_id_cpf_cnpj ( en_multorg_id  in mult_org.id%type
                                 , ev_cpf_cnpj    in varchar2
                                 ) return Empresa.id%TYPE;
         
-------------------------------------------------------------------------------------------------------

--| Fun��o retorna o NRO_PROC da tabela RET_EVENTO_EPEC conforme ID da nota

function fkg_ret_evento_epec_proc_id ( en_notafiscal_id in nota_fiscal.id%type )
         return ret_evento_epec.nro_proc%type;

-------------------------------------------------------------------------------------------------------

--| Fun��o retorna o COD_STAT da tabela RET_EVENTO_EPEC conforme ID da nota

function fkg_ret_evento_epec_stat_id ( en_notafiscal_id in nota_fiscal.id%type )
         return ret_evento_epec.cod_stat%type;
         
-------------------------------------------------------------------------------------------------------

--| Retorna o limite de quantade de dias para emiss�o da NFe conforme a empresa

function fkg_estado_lim_emiss_nfe ( en_empresa_id in empresa.id%type )
         return estado.lim_emiss_nfe%type;
         
-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da nota Fiscal a partir do n�mero da chave de acesso e empresa_id

function fkg_notafiscal_id_chave_empr ( en_nro_chave_nfe  in Nota_Fiscal.nro_chave_nfe%TYPE
                                      , en_empresa_id     in empresa.id%type )
         return nota_fiscal.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna situa��o do documento da Nota Fiscal atrav�s do identificador da nota fiscal
function fkg_sitdoc_id_nf ( en_notafiscal_id in nota_fiscal.id%type )
         return sit_docto.id%type;
         
-------------------------------------------------------------------------------------------------------

-- Fun��o retorna a data de conting�ncia da Nota Fiscal atrav�s do identificador
function fkg_dt_cont_nf ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal.dt_cont%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna DM_VAL_NCM_ITEM atrav�s do ID da empresa.
function fkg_dmvalncm_empid(en_empresa_id in empresa.id%type)
         return empresa.dm_val_ncm_item%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o que retorna DM_DT_ESCR_DFEPOE atrav�s do ID da empresa.
function fkg_dmdtescrdfepoe_empresa(en_empresa_id in empresa.id%type)
         return empresa.dm_dt_escr_dfepoe%type;
         
-------------------------------------------------------------------------------------------------------

-- Fun��o que retorna cidade_id da empresa da nota informada.

function fkg_cidade_id_nf_id ( en_notafiscal_id in nota_fiscal.id%type)
         return cidade.id%type; 
         
-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o id do pa�s conforme o "Pais do tipo do c�digo de arquivo" e "Tipo de C�digo de arquivo"

function fkg_pais_id_tipo_cod_arq ( ev_paistipocodarq_cd in pais_tipo_cod_arq.cd%type
                                  , ev_tipocodarq_cd     in tipo_cod_arq.cd%type
                                  , en_pais_id           in pais.id%type
                                  )
         return pais.id%type;
         
-------------------------------------------------------------------------------------------------------

-- Fun��o retorna a inscri��o municipal da pessoa

function fkg_inscr_mun_pessoa ( en_pessoa_id  in pessoa.id%TYPE )
         return juridica.im%type;         

-------------------------------------------------------------------------------------------------------

-- Fun��o para descrever valores por extenso

function fkg_descValor_extenso(valor number)
  return varchar2;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna TRUE se existe grupo de tributa��o do imposto ICMS ou FALSE caso n�o exista

function fkg_existe_imp_itemnficmsdest ( en_impitemnf_id in imp_itemnf_icms_dest.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o recupera o "C�digo" do Enquadramento Legal do IPI conforme ID
function fkg_cd_enq_legal_ipi ( en_enqlegalipi_id in enq_legal_ipi.id%type )
         return enq_legal_ipi.cd%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o recupera o "ID" do Enquadramento Legal do IPI conforme C�digo
function fkg_id_enq_legal_ipi ( ev_enqlegalipi_cd in enq_legal_ipi.cd%type )
         return enq_legal_ipi.id%type;

-------------------------------------------------------------------------------------------------------

procedure pkb_cria_nat_oper( ev_cod_nat         nat_oper.cod_nat%type
                           , ev_descr_nat       nat_oper.descr_nat%type default null
                           , en_multorg_id      mult_org.id%type);

-----------------------------------------------------------------------------------------------------
--Retorna o DM_OBRIG_INTEGR do mult org informado. 1 - obrigatorio, 0 - n�o obrigatorio;

function fkg_multorg_obrig_integr (en_multorg_id    mult_org.id%type)
         return mult_org.DM_OBRIG_INTEGR%type;
         
-------------------------------------------------------------------------------------------------------
--Retorna o conteudo adicional referente a nota fiscal, atraves do id da mesma.
function fkg_info_adicionais (en_notafiscal_id in nota_fiscal.id%type)
         return varchar2;

-------------------------------------------------------------------------------------------------------
-- Fun��o identifica se a data de vencimento do certificado est� OK
function fkg_empr_dt_venc_cert_ok ( en_empresa_id in empresa.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------
--| Fun��o retorna a data de vencimento do certificado
function fkg_empr_dt_venc_cert ( en_empresa_id in empresa.id%type )
         return date;

-------------------------------------------------------------------------------------------------------

--| Fun��o retorno do "c�digo do Cest" conforme ID
function fkg_cd_cest_id ( en_cest_id in cest.id%type )
         return cest.cd%type;

-------------------------------------------------------------------------------------------------------

--| Fun��o retorno do "ID do Cest" conforme CD
function fkg_id_cest_cd ( ev_cest_cd in cest.cd%type )
         return cest.id%type;

-------------------------------------------------------------------------------------------------------
--| Fun��o retorna do Valor do Par�metro de Aguardar Libera��o da NFe na Empresa

function fkg_empr_aguard_liber_nfe ( en_empresa_id in empresa.id%type )
         return empresa.dm_aguard_liber_nfe%type;

-------------------------------------------------------------------------------------------------------

--| Fun��o retorna a Descri��o do Pais conforme Siscomex

function fkg_Descr_Pais_siscomex ( ev_cod_siscomex  in Pais.cod_siscomex%TYPE )
         return Pais.descr%TYPE;

-------------------------------------------------------------------------------------------------------
--| Fun��o que pega o valor da sequence
function fkg_vlr_sequence ( ev_sequence_name in seq_tab.sequence_name%type )
         return number;

-------------------------------------------------------------------------------------------------------
--| Fun��o retorna o primeiro furo ID nos registros da tabela
function fkg_primeiro_furo_id ( ev_tabela    in varchar2
                              , ev_campo_id  in varchar2
                              )
         return number;

-------------------------------------------------------------------------------------------------------
--| Fun��o retorna o proximo valor livre (Furo do ID) ou o valor da sequence
function fkg_vlr_livre_sequence ( ev_tabela         in varchar2
                                , ev_campo_id       in varchar2
                                , ev_sequence_name  in seq_tab.sequence_name%type
                                )
         return number;

-------------------------------------------------------------------------------------------------------
--| Fun��o retorna o c�digo indentificador da tabela ABERTURA_FCI
function fkg_aberturafci_id ( en_empresa_id in empresa.id%type
                            , ed_dt_ini in abertura_fci.dt_ini%type
                            ) return number;

-------------------------------------------------------------------------------------------------------
--| Fun��o que retorna o c�digo identificador da tabela ABERTURA_FCI_ARQ
function pk_aberturafciarq_id ( en_aberturafci_id in abertura_fci_arq.aberturafci_id%type
                              , en_nro_sequencia  in abertura_fci_arq.nro_sequencia%type
                              ) return abertura_fci_arq.id%type;
                              
----------------------------------------------------------------------------------------------------
--| Fun��o que retorna o c�digo identificador da tabela de Retorno_Fci
function fkg_infitemfci_id ( en_aberturafciarq_id in abertura_fci_arq.id%type
                           , en_item_id           in item.id%type
                           ) return inf_item_fci.id%type;

----------------------------------------------------------------------------------------------------
--| Fun��o que retorna o c�digo identificador da tabela de Retorno_Fci
function fkg_retornofci_id ( en_item_id       in item.id%type
                           , en_infitemfci_id in inf_item_fci.id%type
                           ) return retorno_fci.id%type;

----------------------------------------------------------------------------------------------------

--| Fun��o de Retornar o ID do Regime Tribut�rio
function fkg_id_reg_trib_cd ( ev_regtrib_cd in reg_trib.cd%type )
         return reg_trib.id%type;

----------------------------------------------------------------------------------------------------

--| Fun��o de Retornar o CD do Regime Tribut�rio
function fkg_cd_reg_trib_id ( en_regtrib_id in reg_trib.id%type )
         return reg_trib.cd%type;

----------------------------------------------------------------------------------------------------

--| Fun��o retorna o CD da Forma de Tributa��o
function fkg_cd_forma_trib_id ( en_formatrib_id  in forma_trib.id%type )
         return forma_trib.cd%type;

----------------------------------------------------------------------------------------------------

--| Fun��o retorna o ID da Forma de Tributa��o
function fkg_forma_trib_cd ( en_regtrib_id    in reg_trib.id%type
                           , ev_formatrib_cd  in forma_trib.cd%type
                           )
         return forma_trib.id%type;

----------------------------------------------------------------------------------------------------

--| Fun��o retorna o ID da Incidencia Tributaria
function fkg_id_inc_trib_cd ( ev_inctrib_cd in inc_trib.cd%type )
         return inc_trib.id%type;

----------------------------------------------------------------------------------------------------

--| Fun��o retorna o CD da Incidencia Tributaria
function fkg_cd_inc_trib_id ( en_inctrib_id in inc_trib.id%type )
         return inc_trib.cd%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retor do ID da Mult-Organiza��o conforme c�digo e hash

function fkg_multorg_id ( ev_multorg_cd    in  mult_org.cd%type
                        , ev_multorg_hash  in  mult_org.hash%type
                        )
         return mult_org.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o CD da Mult-Organiza��o conforme ID

function fkg_multorg_cd ( en_multorg_id in mult_org.id%type
                        )
         return mult_org.cd%type;

----------------------------------------------------------------------------------------------------
--| Fun��o que retorna o c�digo identificador da tabela de Cod_Nat_Pc
function fkg_codnatpc_id ( ev_cod_nat in cod_nat_pc.cod_nat%type
                         ) return cod_nat_pc.id%type;

----------------------------------------------------------------------------------------------------
--| Fun��o que retorna o c�digo da tabela de Cod_Nat_Pc
function fkg_codnatpcid_cod_nat ( en_codnatpc_id in cod_nat_pc.id%type 
                                ) return cod_nat_pc.id%type;

----------------------------------------------------------------------------------------------------
--| Fun��o que retorna o c�digo identificador da tabela de AGLUT_CONTABIL
function fkg_aglutcontabil_id ( en_empresa_id  in empresa.id%type
                              , ev_cod_agl     in aglut_contabil.cod_agl%type
                              ) return aglut_contabil.id%type;

----------------------------------------------------------------------------------------------------
--| Fun��o que retorna o c�digo da tabela de AGLUT_CONTABIL
function fkg_cd_aglutcontabil ( en_aglutcontabil_id  in aglut_contabil.id%type
                              ) return aglut_contabil.cod_agl%type;
                              
----------------------------------------------------------------------------------------------------
--| Fun��o que retorna o c�digo identificador da tabela de PC_AGLUT_CONTABIL
function fkg_pcaglutcontabil_id ( en_planoconta_id    in plano_conta.id%type
                                , en_aglutcontabil_id in aglut_contabil.id%type
                                , en_centrocusto_id   in centro_custo.id%type
                                ) return pc_aglut_contabil.id%TYPE;

----------------------------------------------------------------------------------------------------

-- Procedimento para retornar o Regime Tribut�rio da Empresa e Forma de Tributa��o
procedure pkb_empresa_forma_trib ( en_empresa_id     in empresa.id%type
                                 , ed_dt_ref         in date
                                 , sn_regtrib_id     out reg_trib.id%type
                                 , sn_formatrib_id   out forma_trib.id%type
                                 );

----------------------------------------------------------------------------------------------------

-- Procedimento para retornar CNAE Primario da Empresa
function fkg_empresa_cnae_primario ( en_empresa_id     in empresa.id%type
                                   , ed_dt_ref         in date
                                   )
          return empresa_cnae.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o Id de Auto-Relacionamento do "CNAE" conforme ID

function fkg_ar_cnae_id ( en_cnae_id in cnae.id%TYPE )
         return cnae.ar_cnae_id%type;

----------------------------------------------------------------------------------------------------

-- Fun��o para retornar o Incidencia Tribut�ria da Empresa
function fkg_empresa_inc_trib ( en_empresa_id     in empresa.id%type
                              , ed_dt_ref         in date
                              )
         return inc_trib.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o id do pa�s conforme o codigo do "Pais do tipo do c�digo de arquivo" e do "Tipo de C�digo de arquivo"
function fkg_pais_id_tipo_arq_cd ( ev_paistipocodarq_cd in pais_tipo_cod_arq.cd%type
                                 , ev_tipocodarq_cd     in tipo_cod_arq.cd%type
                                 )
         return pais.id%type;

----------------------------------------------------------------------------------------------------

-- Fun��o para retornar o ID da informa��o sobre exporta��o com base na chave
function fkg_busca_infoexp_id ( ev_cpf_cnpj_emit   in   pessoa.cod_part%type
                              , en_dm_ind_doc      in   infor_exportacao.dm_ind_doc%type
                              , en_nro_de          in   infor_exportacao.nro_de%type
                              , ed_dt_de           in   infor_exportacao.dt_de%type
                              , en_nro_re          in   infor_exportacao.nro_re%type
                              , ev_chc_emb         in   infor_exportacao.chc_emb%type
                              , en_multorg_id      in   mult_org.id%type )
         return infor_exportacao.id%type;

----------------------------------------------------------------------------------------------------

-- Fun��o para retornar o ID do documento da informa��o sobre exporta��o com base no item e na nota do documento
function fkg_busca_docinfoexp_id ( en_item_id              in   item.id%type
                                 , en_notafiscal_id        in   nota_fiscal.id%type
                                 , en_inforexportacao_id   in   infor_exportacao.id%type )
         return infor_export_nota_fiscal.id%type;

----------------------------------------------------------------------------------------------------

--| Fun��o retorno o valor do Par�metro Global
function fkg_vlr_param_global_csf ( ev_paramglobalcsf_cd in param_global_csf.cd%type )
         return param_global_csf.valor%type;

----------------------------------------------------------------------------------------------------

-- Fun��o retorna se a Empresa Utiliza Unidade de Medida da Sefaz por NCM
function fkg_util_unidsefaz_conf_ncm ( en_empresa_id in empresa.id%type )
         return empresa.dm_util_unidsefaz_conf_ncm%type;

----------------------------------------------------------------------------------------------------

-- Fun��o para retornar a Sigla da Unidade de Medida do Sefaz Conforme NCM e Per�odo
function fkg_unidsefaz_conf_ncm ( en_ncm_id     in ncm.id%type
                                , ed_dt_ref     in date
                                )
         return unidade_sefaz.sigla_unid%type;

----------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID do NCM Supostamente Seperior

function fkg_ncm_id_superior ( ev_cod_ncm  in ncm.cod_ncm%type )
         return ncm.id%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto ISS - Par�metro para Notas Fiscais com Emiss�o Propria

function fkg_empresa_vld_iss_epropria ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_iss_epropria%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto ISS - Par�metro para Notas Fiscais com Emiss�o de Terceiros

function fkg_empresa_vld_iss_terc ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_iss_terc%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o para retornar o ibge da cidade do emitente da nota fiscal
function fkg_cidadeibge_notafiscalemit ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal_emit.cidade_ibge%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o para retornar o ibge da cidade do destinat�rio da nota fiscal
function fkg_cidadeibge_notafiscaldest ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal_dest.cidade_ibge%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o para retornar o ibge da cidade da pessoa do conhecimento de transporte
function fkg_cidadeibge_conhectransp ( en_conhectransp_id in conhec_transp.id%type )
         return cidade.ibge_cidade%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o para retornar o ibge da cidade do destinat�rio do conhecimento de transporte
function fkg_cidadeibge_ct_dest ( en_conhectransp_id in conhec_transp.id%type )
         return conhec_transp_dest.ibge_cidade%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o para retornar o ibge da cidade da pessoa da nota fiscal
function fkg_cidadeibge_notafiscalid ( en_notafiscal_id in nota_fiscal.id%type )
         return cidade.ibge_cidade%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o para retornar o ibge do estado da pessoa da nota fiscal
function fkg_estadoibge_notafiscalid ( en_notafiscal_id in nota_fiscal.id%type )
         return estado.ibge_estado%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o para retornar o ibge do estado do destinat�rio do conhecimento de transporte
function fkg_estadoibge_ct_dest ( en_conhectransp_id in conhec_transp.id%type )
         return estado.ibge_estado%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o para retornar o ibge do estado da pessoa do conhecimento de transporte
function fkg_estadoibge_conhectransp ( en_conhectransp_id in conhec_transp.id%type )
         return estado.ibge_estado%type;

-------------------------------------------------------------------------------------------------------

--| Fun��o retorna verifica se a empresa Gera Informa��es de Tributa��es apenas para Venda
function fkg_empresa_inf_trib_op_venda ( en_empresa_id in empresa.id%type )
         return empresa.dm_inf_trib_oper_venda%type;

-------------------------------------------------------------------------------------------------------

FUNCTION fkg_limpa_acento2 ( ev_string            IN varchar2 )
         RETURN VARCHAR2;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o valor do campo Tipo da impress�o dos Totais da Tributa��o

function fkg_tp_impr_tot_trib_empresa ( en_empresa_id in empresa.id%type )
         return empresa.dm_tp_impr_tot_trib%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o para Recuperar o C�digo do DIPAM-GIA

function fkg_dipamgia_id ( en_estado_id   in estado.id%type
                         , ev_cd_dipamgia in dipam_gia.cd%type
                         ) return dipam_gia.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o para Recuperar o C�digo da Tabela de Parametros do DIPAM-GIA

function fkg_paramdipamgia_id ( en_empresa_id  in empresa.id%type
                              , en_dipamgia_id in dipam_gia.id%type
                              , en_cfop_id     in cfop.id%type
                              , en_item_id     in item.id%type
                              , en_ncm_id      in ncm.id%type
                              ) return param_dipamgia.id%type;

-------------------------------------------------------------------------------------------------------

--| Processo que recupera o identificador do tipo do log pelo c�digo(id)
function fkg_retorna_csftipolog_id(ev_cd in varchar2)
return number;
--

--------------------------------------------------------------------------------------------------------
--| FUN��O QUE RECUPERA TODOS OS C�DIGOS CFOP DE ITEM, PERTENCENTES A UMA NOTA FISCAL
--------------------------------------------------------------------------------------------------------
function fkg_recupera_cfop (en_notafiscal_id in number)
return varchar2;
--

--------------------------------------------------------------------------------------------------------
--| FUN��O QUE RECUPERA C�DIGO IDENTIFICADOR DO PROCESSO ADMINISTRATIVO - REINF
--------------------------------------------------------------------------------------------------------
function fkg_procadmefdreinf_id ( en_empresa_id in empresa.id%type
                                , ed_dt_ini     in date
                                , ed_dt_fin     in date
                                , en_dm_tp_proc in number
                                , ev_nro_proc   in varchar2
                                ) return proc_adm_efd_reinf.id%type;

--------------------------------------------------------------------------------------------------------
--| Fun��o que verifica se o c�digo identificador ja existe na tabela
function fkg_verif_procadmefdreinf ( en_procadmefdreinf_id in proc_adm_efd_reinf.id%type 
                                   ) return boolean;

--------------------------------------------------------------------------------------------------------
--| Recupera c�digo identificador de Indicativo de Suspens�o da Exigibilidade
function fkg_indsuspexig_id ( ev_ind_susp_exig in ind_susp_exig.cd%type
                            ) return ind_susp_exig.id%type;

--------------------------------------------------------------------------------------------------------
--| Fun��o valida se o participante est� cadastrado como empresa
function fkg_valida_part_empresa ( en_multorg_id  in mult_org.id%type
                                 , ev_cod_part    in pessoa.cod_part%TYPE
                                 ) return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o indicador de atualiza��o de depend�ncias do Item na Integra��o de Cadastros Gerais - Item
function fkg_empr_dm_atual_dep_item ( en_empresa_id  in empresa.id%type )
         return empresa.dm_atual_dep_item%type;

-------------------------------------------------------------------------------------------------------
-- Recupera o id da fonte pagadora do REINF
function fkg_recup_fonte_pagad_reinf_id ( ev_cd_font_pag_reinf  in rel_fonte_pagad_reinf.cod%type )
         return rel_fonte_pagad_reinf.id%type;

-------------------------------------------------------------------------------------------------------
-- Recupera o c�digo da fonte pagadora do REINF
function fkg_recup_fonte_pagad_reinf ( en_relfontepagadreinf_id  in rel_fonte_pagad_reinf.id%type )
         return rel_fonte_pagad_reinf.cod%type;

-------------------------------------------------------------------------------------------------------
-- Procedimento retorna o par�metro que Permite a quebra da Informa��o Adicional no arquivo Sped Fiscal
function fkg_parefdicmsipi_dmqueinfadi ( en_empresa_id in empresa.id%type )
         return param_efd_icms_ipi.dm_quebra_infadic_spedf%type;

-------------------------------------------------------------------------------------------------------
-- Procedimento retorna o c�digo NIF da pessoa
function fkg_cod_nif_pessoa ( en_pessoa_id in pessoa.id%type ) return pessoa.cod_nif%type;

-------------------------------------------------------------------------------------------------------
-- Procedimento retorna o se o pa�s obriga o cod_nif p a pessoa_id
function fkg_pais_obrig_nif ( en_pais_id in pais.id%type ) return pais.dm_obrig_nif%type;

-------------------------------------------------------------------------------------------------------
-- Procedimento retorna a sigla do pais da pessoa_id
function fkg_sigla_pais ( en_pessoa_id in pessoa.id%type ) return pais.sigla_pais%type;

-------------------------------------------------------------------------------------------------------

--| Fun��o retorna o ID da tabela TIPO_RET_IMP_RECEITA
function fkg_tipo_ret_imp_rec ( en_cod_receita   in tipo_ret_imp_receita.cod_receita%TYPE
                              , en_tiporetimp_id in tipo_ret_imp_receita.tiporetimp_id%TYPE
                              ) return tipo_ret_imp_receita.id%TYPE;
--
-- ============================================================================================================= --
-- Fun��o retorna o COD_RECEITA da tabela TIPO_RET_IMP_RECEITA
function fkg_tipo_ret_imp_rec_cd ( en_tiporetimpreceita_id in tipo_ret_imp_receita.id%TYPE
                                 , en_tiporetimp_id        in tipo_ret_imp_receita.tiporetimp_id%TYPE
                                 ) return tipo_ret_imp_receita.cod_receita%TYPE;
--
-- ============================================================================================================= --
-- Fun��o retorna o valor do parametro dm_guarda_imp_orig
function fkg_empresa_guarda_imporig ( en_empresa_id in empresa.id%type ) return empresa.dm_guarda_imp_orig%type;
--
-- ============================================================================================================= --
-- Fun��o verifica se a nota fiscal j� possui os impostos originais salvos na tabela imp_itemnf_orig
function fkg_existe_nf_imp ( en_notafiscal_id in nota_fiscal.id%type ) return number;
--
-- ============================================================================================================= --
-- Fun��o verifica se o imposto j� foi inserido na tabela imp_itemnf
function fkg_existe_imp_itemnf ( en_itemnf_id  in imp_itemnf.itemnf_id%type
                               , en_tipoimp_id in imp_itemnf.tipoimp_id%type
                               , en_dm_tipo    in imp_itemnf.dm_tipo%type ) return number;
--
-- ============================================================================================================= --
-- Fun��o buscar par�metro do sistema (PARAM_GERAL_SISTEMA)
function fkg_ret_vl_param_geral_sistema ( en_multorg_id      in mult_org.id%type                        -- MultiOrganiza��o - Obrigat�rio
                                        , en_empresa_id      in empresa.id%type                         -- Empresa - Opcional
                                        , en_modulo_id       in modulo_sistema.id%type                  -- Modulos do Sistema - Obrigat�rio
                                        , en_grupo_id        in grupo_sistema.id%type                   -- Grupo de Par�metros por Modulo - Obrigat�rio
                                        , ev_param_name      in param_geral_sistema.param_name%type     -- Nome do Par�metro - Obrigat�rio
                                        , sv_vlr_param      out param_geral_sistema.vlr_param%type      -- Valor do Par�metro (sa�da)
                                        , sv_erro           out varchar2                                -- Mensagem de erro (return false)
                                        ) return boolean;
--
-- ============================================================================================================= --
-- Fun��o para retornar o id do modulo do sistema
function fkg_ret_id_modulo_sistema ( ev_cod_modulo  in modulo_sistema.cod_modulo%type
                                   ) return number;
--
-- ============================================================================================================= --
-- Fun��o para retornar o id do grupo do sistema
function fkg_ret_id_grupo_sistema ( en_modulo_id  in modulo_sistema.id%type
                                  , ev_cod_grupo  in grupo_sistema.cod_grupo%type
                                   ) return number;
--
-- ============================================================================================================= --
--
-- Fun��o para retornar o valor do par�metro do sistema, utilizando os par�metros nome do m�dulo, nome do grupo e nome do parametro
function fkg_parametro_geral_sistema ( en_multorg_id   mult_org.id%type,
                                       en_empresa_id   empresa.id%type,  
                                       ev_cod_modulo   modulo_sistema.cod_modulo%type,
                                       ev_cod_grupo    grupo_sistema.cod_grupo%type,
                                       ev_param_name   param_geral_sistema.param_name%type) return param_geral_sistema.vlr_param%type;
--
-- ============================================================================================================= --
-- Procedimento verifica se a empresa valida o imposto PIS - Par�metro para Notas Fiscais Servicos com Emiss�o Pr�pria
function fkg_empresa_dmvalpis_emis_nfs ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_pis_emiss_nfs%type;
-- 
-- ============================================================================================================= --
-- Procedimento verifica se a empresa valida o imposto PIS - Par�metro para Notas Fiscais Servi�os com Emiss�o de Terceiros
function fkg_empresa_dmvalpis_terc_nfs ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_pis_terc_nfs%type; 
--
-- ============================================================================================================= --
-- Procedimento verifica se a empresa valida o imposto Cofins - Par�metro para Notas Fiscais Servi�os com Emiss�o Pr�pria
function fkg_empr_dmvalcofins_emis_nfs ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_cofins_emiss_nfs%type;
--
-- ============================================================================================================= --
-- Procedimento verifica se a empresa valida o imposto Cofins - Par�metro para Notas Fiscais Servi�os com Emiss�o de Terceiros
function fkg_empr_dmvalcofins_terc_nfs ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_cofins_terc_nfs%type;
--
-- ============================================================================================================= --
--Fun��o retorna se Nota Fiscal foi submetido ao evento R-2010 do REINF ou n�o.
--E se o Conhecimento de tranporte est� no dm_st_proc igual � 7 (Exclus�o) do evento R-2010 do Reinf.
--
function fkg_existe_reinf_r2010_nf (en_notafiscal_id Nota_Fiscal.id%type) return boolean;
--
-- ============================================================================================================= --
--Fun��o retorna se Nota Fiscal foi submetido ao evento R-2020 do REINF ou n�o. 
--E se o Conhecimento de tranporte est� no dm_st_proc igual � 7 (Exclus�o) do evento R-2020 do Reinf.
--
function fkg_existe_reinf_r2020_nf (en_notafiscal_id Nota_Fiscal.id%type) return boolean;
--
-- ============================================================================================================================== --
--
-- Procedure retorna dados da empresa
procedure pkb_ret_dados_empresa ( en_empresa_id         in empresa.id%type
                                , sv_nome              out pessoa.nome%type
                                , sn_dm_situacao       out empresa.dm_situacao%type
                                , sv_dados             out varchar2
                                , sn_sit_empresa       out number
                                , sn_dm_habil          out cidade_nfse.dm_habil%type
                                , sn_existe_id         out empresa.id%type
                                , sn_dm_tp_impr        out empresa.dm_tp_impr%type
                                , sn_dm_tp_amb         out empresa.dm_tp_amb%type
                                , sv_cnpj_cpf          out varchar2
                                , sv_cod_part          out pessoa.cod_part%type
                                , sv_im                out juridica.im%type
                                , sn_pessoa_id         out pessoa.id%type
                                , sv_ibge_cidade       out cidade.ibge_cidade%type
                                , sv_ibge_estado       out estado.ibge_estado%type );
--
-- ============================================================================================================================== --
--
-------------------------------------------------------------------------------------------------------
--| Fun��o retorna o ID do Plano de Conta a partir da tab NAT_REC_PC
--
function fkg_natrecpc_plc_id ( en_natrecpc_id  in nat_rec_pc.id%TYPE )
         return nat_rec_pc.planoconta_id%TYPE;
--
-------------------------------------------------------------------------------------------------------
--| Fun��o retorna o ID do Plano de Conta a partir da tab NCM_NAT_REC_PC
--
function fkg_ncmnatrecpc_plc_id ( en_natrecpc_id  in nat_rec_pc.id%TYPE,
                                  en_ncm_id       in ncm.id%TYPE )
         return ncm_nat_rec_pc.planoconta_id%TYPE;
--
-------------------------------------------------------------------------------------------------------
--| Fun��o retorna o ID do Tabela NAT_PEC_PC a partir da tab NCM_NAT_REC_PC
--
function fkg_ncmnatrecpc_npp_id (en_planoconta_id in nat_rec_pc.planoconta_id%TYPE)
                 return PLANO_CONTA_NAT_REC_PC.NATRECPC_ID%type;
--
-------------------------------------------------------------------------------------------------------
--| Fun��o retorna o ID do Tabela NAT_PEC_PC a partir dos parametros planoconta_id e codst_id 
--
function fkg_natrecpc_id (en_planoconta_id in nat_rec_pc.planoconta_id%TYPE,
                          en_codst_id      in nat_rec_pc.codst_id%TYPE) 
                          return nat_rec_pc.id%type;
--
-------------------------------------------------------------------------------------------------------
--| Fun��o retorna o primeiro ID do plano de conta do Tabela NAT_PEC_PC
--
function fkg_plcnatpecpc_plc_id ( en_natrecpc_id  in nat_rec_pc.id%TYPE)
                             return plano_conta_nat_rec_pc.planoconta_id%type;
--
-------------------------------------------------------------------------------------------------------
--| Fun��o retorna o ID da Tabela COD_ST_CIDADE
--
function fkg_codstcidade_Id (ev_cod_st    in  cod_st_cidade.cod_st%TYPE,
                             en_cidade_id in  cod_st_cidade.cidade_id%TYPE)
                             return cod_st_cidade.id%type;
-------------------------------------------------------------------------------------------------------
--| Procedure para cria��o de sequence e inclus�o na seq_tab
--
procedure pkb_cria_sequence (ev_sequence_name varchar2,
                             ev_table_name    varchar2);

-------------------------------------------------------------------------------------------------------
--| Procedure para cria��o de dom�nio
--
procedure pkb_cria_dominio (ev_dominio    varchar2,
                            ev_valor      varchar2,
                            ev_descricao  varchar2);
--
end pk_csf;
/
