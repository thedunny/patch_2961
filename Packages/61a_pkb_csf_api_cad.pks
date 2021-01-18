create or replace package csf_own.pk_csf_api_cad is

-------------------------------------------------------------------------------------------------------
--
-- Especifica��o do pacote de procedimentos de integra��o e valida��o de Cadastros
--
-- Em 14/12/2020  - Eduardo Linden
-- Redmine #72406 - Cria��o de procedimento de replica��o
-- Cria��o de processo de replica��o de tabelas filhas da natureza de opera��o
-- Rotina criada -  pkb_replica_nat_oper
-- Patch_2.9.4.6 / Patch_2.9.5.3 / Release_2.9.6
--
-- Em 15/10/2020    - Wendel Albino
-- Redmine #70595   - Adicionar coluna DT_HR_ALTER em tabelas de cadastro ITEM,PESSOA E PLANO_CONTA
-- Rotinas Alterada - pkb_integr_item , pkb_integr_Plano_Conta,pkb_ins_atual_pessoa, criando validacao da coluna nova.
--
-- Em 02/07/2020 - Renan Alves
-- Redmine #68517 - Adicionar regra de valida��o de Bairro
-- Foi incluido uma valida��o para o bairro, quando a pessoa/participante for do Brasil 
-- Rotina: pkb_ins_atual_pessoa
-- Patch_2.9.4.1 / Patch_2.9.3.4 / Release_2.9.5
--
-- Em 22/01/2020   - Allan Magrini
-- Redmine #48957 - Inclus�o do campo de Valor do Diferencial de Al�quota em Informa��es dos Itens dos Documentos Fiscais do Bem.
-- Criada a rotina para valida��o pkb_val_atrib_bem_ativo e adicionando o campo VL_DIF_ALIQ no insert e update fase 18 e 18.1
-- Rotina Criada   - pkb_val_atrib_bem_ativo
-- Rotina Alterada - pkb_integr_itnf_bem_ativo_imob
--
-- Em 12/12/2019   - Karina de Paula
-- Redmine #62162  - Erro no calculo do FCI.
-- Rotina Alterada - pkb_integr_item_compl => Inclu�da a gera��o de log de informa��o quando o valor vl_est_venda for zerado
--
-- Em 03/05/2011 - Angela In�s.
-- Inclu�do processo de item de marca comercial.
--
-- Em 29/11/2012 - Angela In�s.
-- Ficha HD 64719 - Erro de integracao que impacta EFD Contribui��es Blocos M400 e M800.
-- Inclus�o do c�digo NCM na integra��o do Item/Produto independente do tipo de item.
-- Rotina: pkb_integr_item.
--
-- Em 11/01/2013 - Vanessa N F Ribeiro.
-- Ficha HD 65502 - Inclus�o da integra��o do complemento do item
-- Rotina: pkb_integr_item_compl.
--
-- Em 21/02/2013 - Rog�rio Silva
-- Ficha HD 66039 - Teste e valida��o Suframa
-- Rotina: pkb_ins_atual_juridica
--
-- Em 04/03/2013 - Angela In�s.
-- Ficha HD 66230 - Realizar o fechamento das rotinas program�veis.
-- Inclus�o das mensagens de log/avisos sobre as corre��es de UNIDADE, JURIDICA, ITEM, PESSOA e FISICA.
-- Rotina: pkb_inclui_log_unidade, pkb_inclui_log_juridica, pkb_inclui_log_item, pkb_inclui_log_pessoa e pkb_inclui_log_fisica.
--
-- Em 05/04/2013 - Angela In�s.
-- Ficha HD 66529 - Rotinas program�veis - Montagem do registro C190. Inclus�o do log de empresa.
-- Rotina: pkb_inclui_log_empresa.
--
-- Em 10/05/2013 - Marcelo Ono.
-- Ficha HD 66684 - Converter todas as procedures de acerto de dados que o Tadeu criou na Barcelos em Rotinas Program�veis. Inclus�o do log de ncm_nat_rec_pc.
-- Rotina: pkb_inclui_log_ncm_nat_rec_pc.
--
-- Em 15/07/2013 - Angela In�s.
-- Redmine #382 - Melhoria nas mensagens de inconsist�ncia na integra��o dos Bens do Ativo Imobilizado.
-- Rotina: pkb_integr_bem_ativo_imob.
--
-- Em 22/07/2013 - Rog�rio Silva.
-- RedMine #399
-- Rotinas: altera��es na pkb_integr_bem_ativo_imob e cria��o da pkb_integr_bem_ativo_imob_comp
--
-- Em 24/07/2013 - Rog�rio Silva.
-- RedMine #398
-- Cria��o dos procedimentos: pkb_integr_grupo_pat, pkb_integr_subgrupo_pat e pkb_integr_imp_subgrupo_pat
--
-- Em 25/07/2013 - Rog�rio Silva.
-- RedMine #401
-- Cria��o dos procedimentos: pkb_integr_nf_bem_ativo_imob e pkb_integr_itnf_bem_ativo_imob.
--
-- Em 26/07/2013 - Rog�rio Silva.
-- RedMine #400
-- Cria��o do procedimento: pkb_integr_rec_imp_bem_ativo.
--
-- Em 30/07/2013 - Rog�rio Silva.
-- RedMine #490
-- * Cria��o do procedimento que verifica se existe os dados de "Informa��es de Utiliza��o do Bem" e caso n�o exista,
-- recupera a partir do SUB-GRUPO: "pkb_rec_infor_util_bem"
-- * Adicionar campo COD_CCUS no procedimento pkb_integr_subgrupo_pat.
--
-- Em 31/07/2013 - Rog�rio Silva.
-- RedMine #490
-- * Cria��o do procedimento que verifica se existe os dados de "Impostos do Bem" e caso n�o exista,
-- recupera a partir do REC_IMP_SUBGRUPO_PAT: "pkb_rec_imp_bem_ativo"
--
-- Em 27/09/2013 - Rog�rio Silva.
-- Redmine #785
-- Altera��o origem de mercadoria, adicionado o valor 8.
--
-- Em 03/03/2014 - Angela In�s.
-- Redmine #2043 - Alterar a API de integra��o de cadastros incluindo o cadastro de Item componente/insumo.
--
-- Em 04/07/2014 - Angela In�s.
-- Redmine #3279 - Integra��o de Cadastros Gerais - Cadastro de Ativo Imobilizado.
-- Valor maior para o campo infor_util_bem.func.
-- Rotina: pkb_integr_infor_util_bem.
--
-- Em 26/09/2014 - Rog�rio Silva
-- Redmine #4067 - Processo de contagem de registros integrados do ERP (Agendamento de integra��o)
-- Rotinas: pkb_ins_atual_pessoa, pkb_integr_unid_med, pkb_integr_item
--
-- Em 16/10/2014 - Rog�rio Silva
-- Redmine #4067 - Processo de contagem de registros integrados do ERP (Agendamento de integra��o)
--
--
-- Em 05/11/2014 - Rog�rio Silva
-- Redmine #4067 - Processo de contagem de registros integrados do ERP (Agendamento de integra��o)
-- Redmine #5061 - Remover fun��o fkg_converte no campo e-mail e inserir fkg_limpa_acento
--
--
-- Em 21/11/2014 - Leandro Savenhago
-- Redmine #4067 - Altera��es na package PK_CSF_API_CAD para atender as mudan�as da Mult-Organiza��o
-- Alterados: pkb_atual_email_pessoa, pkb_atual_dep_item, pkb_atual_dep_pessoa
--
-- Em 28/11/2014 - Rog�rio Silva
-- Redmine #5365 - Altera��es na package PK_CSF_API_CAD
-- Adapta��o do processo de Grupo de Patrim�nios para multorg e web-service
--
-- Em 01/12/2014 - Rog�rio Silva
-- Redmine #5365 - Altera��es na package PK_CSF_API_CAD
-- Adapta��o do processo de Bens do Ativo Imobilizado para o multorg e web-service
--
-- Em 02/12/2014 - Rog�rio Silva
-- Redmine #5365 - Altera��es na package PK_CSF_API_CAD
-- Adapta��o dos processos de Natureza da Opera��o, Informa��es complementares do documento fiscal,
-- e Observa��o do lan�amento fiscal para o multorg e web-service
--
-- Em 03/12/2014 - Rog�rio Silva
-- Redmine #5365 - Altera��es na package PK_CSF_API_CAD
-- Adapta��o do processo de Par�metros de C�lculo de ICMS-ST para o multorg e web-service
--
-- Em 05/12/2014 - Rog�rio Silva
-- Redmine #5365 - Altera��es na package PK_CSF_API_CAD
-- Prcedimentos criados: pkb_integr_Plano_Conta, pkb_integr_pc_referen, pkb_integr_Centro_Custo
--
-- Em 06/12/2014 - Rog�rio Silva
-- Redmine #5365 - Altera��es na package PK_CSF_API_CAD
-- Prcedimentos criados: pkb_integr_Hist_Padrao
--
-- Em 06/01/2015 - Angela In�s.
-- Redmine #5616 - Adequa��o dos objetos que utilizam dos novos conceitos de Mult-Org.
--
-- Em 29/01/2015 - Rog�rio Silva.
-- Redmine #6136 - Integra��o Cadastro Ativo Imobilizado
--
-- Em 10/02/2015 - Angela In�s.
-- Redmine #6334 - Erro no agendamento de integra��o (ZANINI). Processo de Plano Referenciado.
-- Incluir o processo de verifica��o indicando se o plano referenciado est� incluso atrav�s da chave �nica (uk). Caso esteja, n�o executar a inclus�o.
-- Rotina: pkb_integr_pc_referen.
--
-- Em 25/02/2015 - Rog�rio Silva.
-- Redmine #6314 - Analisar os processos na qual a tabela UNIDADE � utilizada.
--
-- Em 20/03/2015 - Angela In�s.
-- Redmine #7122 - Avaliar/Acertar Mult-Org: Inclus�o do identificador nas tabelas principais.
-- Rotina: pkb_ins_atual_pessoa.
--
-- Em 23/04/2015 - Angela In�s.
-- Redmine #7784 - Erro Integra��o Cadastro (COOPERB).
-- Problema: Na view de integra��o o c�digo do Item est� vindo com caractere especial ficando: 'DEMONSTRAC?O'.
-- No Compliance esse item j� est� cadastrado como: 'DEMONSTRA\00C7\00C3O'.
-- Na leitura para identificar se o c�digo j� existe no Compliance os caracteres n�o s�o eliminados, e ao gravar sim, por isso o erro de UK.
-- 1) Eliminamos na api de integra��o (pkb_csf_api_cad.pkb_integr_item), os caracteres especiais do c�digo do item.
--
-- Em 08/05/2015 - Rog�rio Silva.
-- Redmine #8192 - Erro Integra��o Cadastro (ZANINI)
-- Rotina: pkb_integr_pc_referen
--
-- Em 21/05/2015 - Rog�rio Silva.
-- Redmine #8592 - Corrigir a fun��o pk_csf_ecd.fkg_planocontarefecd_id, est� sendo retornado mais de uma linha na consulta realizada.
--
-- Em 27/05/2015 - Rog�rio Silva.
-- Redmine #8227 - Processo de Registro de Log em Packages - Cadastros Gerais
--
-- Em 30/06/2015 - Rog�rio Silva.
-- Redmine #9294 - Cria��o de scripts de teste e apoio nos testes Karina
--
-- Em 16/07/2015 - Rog�rio Silva.
-- Redmine #9984 - Retorno da consulta de Unidade n�o retornou mensagem de valida��o
--
-- Em 04/12/2015 - Rog�rio Silva.
-- Redmine #13309 - Status de erro de valida��o sem mensagens do erro
--
-- Em 09/02/2016 - Rog�rio Silva
-- Redmine #13079 - Registro do N�mero do Lote de Integra��o Web-Service nos logs de valida��o
--
-- Em 06/04/2016 - Rog�rio Silva.
-- Redmine #17323 - Corre��o na rotina programavel de unidade de medida e melhoria no processo de cria��o de pessoa.
--
-- Em 06/04/2016 - F�bio Tavares.
-- Redmine #17036 - Cria��o da API de Integra��o de Subcontas Correlatas
--
-- Em 13/04/2016 - Angela In�s.
-- Redmine #17615 - Corre��o na integra��o de Pessoa - Pa�s.
-- Consistir o C�digo Siscomex para recuperar o identificador do Pa�s, na inclus�o de um novo cadastro de pessoa, somente se o par�metro de entrada relacionado
-- ao c�digo Siscomex for enviado com valor.
-- Hoje no processo de inclus�o, se o identificador do pa�s estiver nulo, utilizamos o c�digo Siscomex enviado no par�metro de entrada para recuper�-lo.
-- Rotina: pkb_ins_atual_pessoa, par�metro: en_cod_siscomex.
--
-- Em 14/04/2016 - F�bio Tavares
-- Redmine #16793 - Melhoria nas mensagens dos processos flex-field.
--
-- Em 26/04/2016 - F�bio Tavares
-- Redmine #18043 - Corre��o do processo de integra��o do PLANO_CONTA, caso tenha alguma inconsist�ncia
-- nos dados obrigat�rios n�o sera feito o update ou insert.
--
-- Em 04/08/2016 - Angela In�s.
-- Redmine #22067 - Corre��o na integra��o do Cadastro Gerais - Centro de Custo.
-- Na integra��o, ao incluir ou alterar o registro em quest�o, verificar se os valores dos campos que n�o podem ser NULOS, est�o corretos.
-- Rotina: pkb_integr_centro_custo.
--
-- Em 28/12/2016 - F�bio Tavares.
-- Redmine #26707 - Ajuste na Integra��o de ITEM de Insumo, que passou a ser filho do ITEM.
-- Rotina: pkb_ler_item, pkb_ler_item_insumo.
--
-- Em 06/01/2017 - Angela In�s.
-- Redmine #27030 - Na integra��o do item insumo est� exigindo o NCM.
-- Alterar a mensagem que indica o erro no c�digo NCM para: ""NCM" est� inv�lido (). Para os Itens vinculados ao tipo de item 00-Mercadoria para Revenda,
-- 01-Mat�ria-Prima, 02-Embalagem, 03-Produto em Processo, 04-Produto Acabado, 05-Subproduto e 06-Produto Intermedi�rio, o NCM deve ser informado."
-- Rotina: pkb_integr_item.
--
-- Em 14/02/2017 - F�bio Tavares.
-- Redmine #28306 - Log generico de Item de Insumo
-- Rotina: pkb_integr_item_insumo
--
-- Em 17/03/2017 - F�bio Tavares
-- Redmine #29500 - Ajuste na API de Cadastro relacionado ao Centro de Custo
-- Rotina: pkb_integr_Centro_Custo
--
-- Em 06/04/2017 - F�bio Tavares
-- Redmine #27483 - Melhorias referentes ao plano de contas referencial
-- Relacionado ao Periodo de Referencia de um plano de conta e centro de custo da empresa para o plano de conta do ECD.
--
-- Em 10/05/2017 - Leandro Savenhago
-- Redmine #30054 - Processo de Integra��o de Nota Fiscal de Servi�o versus atualiza depend�ncia de item_id
-- Atribuido a procedure pkb_atual_dep_item para integra��o de item
-- Rotina: pkb_integr_item
--
-- Em 16/05/2017 - F�bio Tavares
-- Redmine #31147 - Retirar a verifica��o de erros no plano de conta, anteriormente estava verificando se o plano pussuia erros
-- agora independente se houver ou nao erro ser� integrado.
--
-- Em 26/05/2017 - F�bio Tavares
-- Redmine #31472 - INTEGRA��O AGLUTINA��O CONT�BIL
--
-- Em 03/08/2017 - Angela In�s.
-- Redmine #33321 - Alterar a Rotina Program�vel que cria ITEM/Produto, e Integra��o de Cadastro de ITEM.
-- 1) Alterar a rotina considerando as notas fiscais das empresas filiais. Hoje no processo de integra��o de cadastro do ITEM, atualizamos nos itens de notas
-- fiscais o ITEM_ID que acabou de ser integrado e que estava com valor nulo, e ainda, que estejam relacionados com a Empresa vinculada com a integra��o.
-- Com isso, a integra��o de cadastro de ITEM, teoricamente, � considerada para a empresa Matriz. Atualizando nos itens das notas fiscais da empresa em quest�o,
-- os itens das notas fiscais das empresas filiais acabam n�o sendo alterados. Essa atualiza��o no processo, ir� considerar os itens das notas fiscais da empresa
-- em quest�o e suas filiais.
-- Rotina: pkb_atual_dep_item
--
-- Em 07/08/2017 - Angela In�s.
-- Redmine #33434 - Alterar o processo de valida��o de cadastros gerais - atualiza��o de dependentes do ITEM.
-- Alterar na rotina que atualiza ITEM_ID nos itens das notas fiscais atrav�s da integra��o do cadastro dos ITENS, a considera��o de recuperar somente as notas
-- que n�o armazenam XML (nota_fiscal.dm_arm_nfe_terc=0).
-- Rotina: pkb_atual_dep_item
--
-- Em 10/08/2017 - Marcelo Ono.
-- Redmine #33602 - Inclus�o da rotina de gera��o de log/altera��es nos processo de replica��o de plano de contas (tabela: plano_conta) - pkb_inclui_log_plano_conta.
--
-- Em 12/08/2017 - Marcelo Ono.
-- Redmine #33602 - Inclus�o da rotina de gera��o de log/altera��es nos processo de replica��o de plano referencial (tabela: pc_referen) - pkb_inclui_log_pc_referen.
--
-- Em 22/08/2017 - F�bio Tavares.
-- Redmine #33790 Integra��o de Cadastros para o Sped Reinf - API
-- Rotina: pkb_integr_procadmefdreinftrib e pkb_integr_proc_adm_efd_reinf.
--
-- Em 27/09/2017 - F�bio Tavares.
-- Redmine #34641 Ajustes sobre a vers�o 1.2 dos Leiautes e Esquemas XSD da EFD-Reinf
-- Rotina: pkb_integr_procadmefdreinftrib.
--
-- Em 28/09/2017 - Angela In�s.
-- Redmine #33434 - Alterar o processo de valida��o de cadastros gerais - atualiza��o de dependentes do ITEM.
-- 1) Alterar na rotina que atualiza ITEM_ID nos itens das notas fiscais atrav�s da integra��o do cadastro dos ITENS, a considera��o de recuperar somente as
-- notas que n�o armazenam XML (nota_fiscal.dm_arm_nfe_terc=0).
-- Rotina: pkb_atual_dep_item.
-- 2) Na rotina que integra os Itens, executar o processo de atualiza��o de depend�ncia de item, se o par�metro da empresa indicar que devem ser atualizadas
-- as depend�ncias do Item (itens de notas fiscais sem o identificador do item - item_nota_fiscal.item_id).
-- Rotina: pk_csf_api_cad.pkb_integr_item; Par�metro: empresa.dm_atual_dep_item=1.
--
-- Em 07/02/2018 - Marcelo Ono
-- Redmine 38773 - Corre��es e implementa��es nos processos do REINF.
-- 1- Corrigido as mensagens de logs nas valida��es do processo administrativo/judici�rio do EFD Reinf.
-- Rotina: pkb_integr_proc_adm_efd_reinf, pkb_integr_procadmefdreinftrib.
--
-- Em 08/02/2018 - Marcelo Ono
-- Redmine #39282 - Implementado o processo de valida��o das Informa��es de pagamentos de impostos retidos/SPED REINF.
-- Rotina: pkb_integr_pessoa_info_pir.
--
-- Em 14/02/2018 - Marcelo Ono
-- Redmine 38773 - Corre��es e implementa��es nos processos do REINF.
-- 1- Alterado o processo de valida��o do processo administrativo/judici�rio, para recuperar o id, apenas se for executado pelo processo de integra��o.
-- Rotina: pkb_integr_proc_adm_efd_reinf.
--
-- Em 30/04/2018 - Marcelo Ono
-- Redmine 40845 - Implementado regra de valida��o para a informa��o do c�digo do indicativo de suspens�o do cadastro de processos administrativos/judici�rios.
-- 1- O preenchimento da informa��o do c�digo do indicativo de suspens�o ser� obrigat�rio se houver mais de uma informa��o de indicativo de suspens�o para um 
-- mesmo processo.
-- 2- Se o tipo de processo for "1-Administrativo", s� poder� ser informado o indicativo de suspens�o de exigibilidade "03,90,92";
-- 3- Se o tipo de processo for "2-Judicial", s� poder� ser informado o indicativo de suspens�o de exigibilidade "01,02,04,05,08,09,10,11,12,13,90,92";
-- Rotina: pkb_integr_procadmefdreinftrib.
--
-- Em 03/05/2018 - Marcelo Ono
-- Redmine 40845 - Alterado a regra de valida��o para a informa��o do c�digo do indicador de auditoria do cadastro de processos administrativos/judici�rios.
-- 1- O preenchimento da informa��o do c�digo do indicador de auditoria ser� obrigat�rio.
-- Rotina: pkb_integr_proc_adm_efd_reinf.
--
-- Em 08/05/2018 - Marcelo Ono
-- Redmine 42597 - Alterado a regra de valida��o para as informa��es "C�d. IBGE cidade e C�d. ident. vara" do cadastro de processos administrativos/judici�rios.
-- 1- O preenchimento das informa��es "C�d. IBGE cidade e C�d. ident. vara" s� dever� ser informado se o tipo de processo for "2-Judicial".
-- Rotina: pkb_integr_proc_adm_efd_reinf.
--
-- Em 23/05/2018 - Marcelo Ono
-- Redmine 43064 - Implementado processo para cria��o do log de inclus�o na tabela "log_proc_adm_efd_reinf", quando n�o existir nenhum log na tabela, ou seja,
-- quando o processo for inclu�do via integra��o.
-- Rotina: pkb_integr_proc_adm_efd_reinf.
--
-- Em 28/06/2018 - Angela In�s.
-- Redmine #44509 - Incluir a coluna de percentual de rateio de item nos par�metros da DIPAM-GIA.
-- 1) Incluir no documento de leiaute de Integra��o de Cadastro a coluna de percentual de rateio de item, PERC_RATEIO_ITEM, nos par�metros da DIPAM-GIA.
-- 2) Alterar o processo de Integra��o e Valida��o dos Cadastros Gerais, incluindo a coluna de percentual de rateio de item, PERC_RATEIO_ITEM, nos par�metros da DIPAM-GIA.
-- Rotina: pkb_integr_param_dipamgia.
--
-- Em 23/08/2018 - Angela In�s.
-- Redmine #46310 - Valida��o do Plano de Contas - Cadastros Gerais.
-- De acordo com a solicita��o, o erro reportado indica que ter�amos na base do cliente, um plano de conta cadastrado com o NIVEL 99, e no processo temos que
-- somar mais 1 na informa��o para que ficasse com o valor de 100, e o tamanho do campo NIVEL comporta apenas 2 d�gitos (number(2)). Dessa forma o erro ocorreria.
-- Consultando a base, n�o foram encontrados planos de contas com NIVEL 99, portanto, inclu�mos uma valida��o no processo, fazendo com que seja gerado um log de
-- inconsist�ncia, caso o erro ocorra novamente.
-- Rotina: pkb_integr_plano_conta.
--
-- Em 18/10/2018 - Karina de Paula
-- Redmine #39990 - Adpatar o processo de gera��o da DIRF para gerar os registros referente a pagamento de rendimentos a participantes localizados no exterior
-- Rotina Criada: pk_csf_api_cad.pkb_val_atrib_nif    => Criada essa pb para validar o COD_NIF, por�m, n�o gera erro de valida��o conforme solicita��o
-- da consultoria, o erro gerado � somente de INFORMACAO. Verifica se o pa�s exige COD_NIF para gerar erro de INFORMACAO;
-- Rotina Alterada: pk_csf_api_cad.pkb_ins_atual_pessoa => O COD_NIF n�o ser� validado aqui pq j� foi validado na pk_csf_api_cad.pkb_val_atrib_nif que � chamado pela integra��o
-- pk_int_view_cad.pkb_pessoa_ff(Flex Field). Como o campo pode ser nulo essa informa��o ser� validada somente na gera��o da
-- DIRF no momento de gerar os arquivos?(RPDE/BRPDE/VRPDE). Inclu�do no update e insert na tabela pessoa o cod_nif
--
-- Em 11/03/2019 - Angela In�s.
-- Redmine #47605 - Performance - Integra��o de Cadastro.
-- Utilizar o par�metro de entrada EN_EMPRESA_ID para recuperar as Notas Fiscais e os Conhecimentos de Transporte. O processo estava utilizando o par�metro
-- EN_MULTORG_ID para cada EN_EMPRESA_ID, com isso todas as Nota Fiscais e Conhecimentos de Transporte estavam sendo recuperados mais de uma vez.
-- Foi trocado o nome da rotina pkb_atual_dep_pessoa para pkb_atual_dep_pessoa_old e criada uma nova rotina com o nome pkb_atual_dep_pessoa.
-- Rotina: pkb_atual_dep_pessoa.
--
-- Em 22/03/2019 - Angela In�s.
-- Redmine #52759 - Integra��o de Cadastro de Item - Empresa.
-- Considerar para Integra��o do ITEM, quando o ID do Item for NULO, a empresa enviada na View de Integra��o (vw_csf_item.cpf_cnpj), caso o ID do Item
-- for diferente de NULO, o processo ir� validar da mesma que era antes, ou seja, considerando a empresa em quest�o e sua matriz.
-- Rotina: pkb_integr_item.
--
-- Em 10/09/2019 - Luis Marques
-- Redmine #58698 - Inser��o de novo campo no modBCST (Calculadora Fiscal)
-- Rotina Alterada: pkb_integr_item_param_icmsst - Ajustado para aceitar 6 no campo 'dm_mod_base_calc_st'
--
-- Em 12/09/2019 - Luis Marques
-- Redmine 58615 - Erros no SPED DF
-- Nova procedure - pkb_integr_nat_set_pessoa - Para incluir a Natureza/Setor da pessoa
--                  (0 - Pessoa Setor Privado / 1 - Pessoa Setor Publico)
--
-- Em 25/10/2019 - Marcos Ferreira
-- Redmine #59975: Erro de valida��o - R-1070
-- Altera��es: Remo��o da obrigatoriedade do campo COMER_PROD_INF_PROC_ADM.procadmefdreinfinftrib_id
-- Procedures Alteradas: pkb_integr_procadmefdreinftrib
--

-------------------------------------------------------------------------------------------------------
--
   gt_row_plano_conta             plano_conta%rowtype;
--
   gt_row_pc_referen              pc_referen%rowtype;
--
   gt_row_hist_padrao             hist_padrao%rowtype;
--
   gt_row_centro_custo            centro_custo%rowtype;
--
   gt_subconta_correlata          subconta_correlata%rowtype;
--
   gt_row_pessoa                  Pessoa%rowtype;
--
   gt_row_pessoa_tipo_param       pessoa_tipo_param%rowtype;
--
   gt_row_pessoa_info_pir         pessoa_info_pir%rowtype;
--
   gt_row_fisica                  Fisica%rowtype;
--
   gt_row_juridica                Juridica%rowtype;
--
   gt_row_unidade                 unidade%rowtype;
--
   gt_row_item                    item%rowtype;
--
   gt_row_item_anp                item_anp%rowtype; 
--
   gt_row_conversao_unidade       conversao_unidade%rowtype;
--
   gt_row_item_marca_comerc       item_marca_comerc%rowtype;
--
   gt_row_grupo_pat               grupo_pat%rowtype;
--
   gt_row_subgrupo_pat            subgrupo_pat%rowtype;
--
   gt_row_rec_imp_subgrupo_pat    rec_imp_subgrupo_pat%rowtype;
--
   gt_row_bem_ativo_imob          bem_ativo_imob%rowtype;
--
   gt_row_infor_util_bem          infor_util_bem%rowtype;
--
   gt_row_bem_ativo_imob_compl    bem_ativo_imob%rowtype;
--
   gt_row_nf_bem_ativo_imob       nf_bem_ativo_imob%rowtype;
--
   gt_row_itnf_bem_ativo_imob     itnf_bem_ativo_imob%rowtype;
--
   gt_row_rec_imp_bem_ativo_imob  rec_imp_bem_ativo_imob%rowtype;
--
   gt_row_infor_comp_dcto_fiscal  infor_comp_dcto_fiscal%rowtype;
--
   gt_row_obs_lancto_fiscal       obs_lancto_fiscal%rowtype;
--
   gt_row_item_param_icmsst	  item_param_icmsst%rowtype;
--
   gt_row_item_compl              item_compl%rowtype;
--
   gt_row_ctrl_ver_contab         ctrl_versao_contabil%rowtype;
--
   gt_row_item_insumo             item_insumo%rowtype;
--
   gt_row_abertura_fci            abertura_fci%rowtype;
--
   gt_row_abertura_fci_arq        abertura_fci_arq%rowtype;
--
   gt_row_inf_item_fci            inf_item_fci%rowtype;
--
   gt_row_retorno_fci             retorno_fci%rowtype;
--
   gt_row_mem_calc_fci            mem_calc_fci%rowtype;
--
   gt_row_aglut_contabil          aglut_contabil%rowtype;
--
   gt_row_pc_aglut_contabil       pc_aglut_contabil%rowtype;
--
   gt_row_param_item_entr         param_item_entr%rowtype;
--
   gt_row_param_oper_fiscal_entr  param_oper_fiscal_entr%rowtype;
--
   gt_row_param_dipamgia          param_dipamgia%rowtype;
--
   gt_row_proc_adm_efd_reinf      proc_adm_efd_reinf%rowtype;
--
   gt_row_procadmefdreinfinftrib  proc_adm_efd_reinf_inf_trib%rowtype;
--
-------------------------------------------------------------------------------------------------------

-- Declara��o de constantes

   ERRO_DE_VALIDACAO       CONSTANT NUMBER := 1;
   ERRO_DE_SISTEMA         CONSTANT NUMBER := 2;
   INFORMACAO              CONSTANT NUMBER := 35;

-------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------------
   --
   gn_processo_id        log_generico_cad.processo_id%type := null;
   gn_empresa_id         empresa.id%type := null;
   gn_tipo_integr        number := null;
   --

   gv_cabec_log          log_generico_cad.mensagem%TYPE;
   --
   gv_cabec_log_item     log_generico_cad.mensagem%TYPE;
   --
   gv_mensagem_log       log_generico_cad.mensagem%TYPE;
   --
   gv_obj_referencia     log_generico_cad.obj_referencia%type;
   --
   gn_referencia_id      log_generico_cad.referencia_id%type := null;
   --
   gv_cd_obj             obj_integr.cd%type := '1';

-------------------------------------------------------------------------------------------------------

-- Procedimento seta o tipo de integra��o que ser� feito
   -- 0 - Somente v�lida os dados e registra o Log de ocorr�ncia
   -- 1 - V�lida os dados e registra o Log de ocorr�ncia e insere a informa��o
   -- Todos os procedimentos de integra��o fazem refer�ncia a ele
procedure pkb_seta_tipo_integr ( en_tipo_integr in number );

-------------------------------------------------------------------------------------------------------

-- Procedimento seta o objeto de referencia utilizado na Valida��o da Informa��o
procedure pkb_seta_obj_ref ( ev_objeto in varchar2 );

-------------------------------------------------------------------------------------------------------

-- Procedimento seta o "ID de Referencia" utilizado na Valida��o da Informa��o
procedure pkb_seta_referencia_id ( en_id in number );

-------------------------------------------------------------------------------------------------------

-- Procedimento armazena o valor do "loggenerico_id" do cadastro
procedure pkb_gt_log_generico_cad ( en_loggenerico    in             log_generico_cad.id%type
                                  , est_log_generico  in out nocopy  dbms_sql.number_table 
                                  );

-------------------------------------------------------------------------------------------------------

-- Procedimento finaliza o Log Gen�rico
procedure pkb_finaliza_log_generico_cad;

-------------------------------------------------------------------------------------------------------

-- Procedimento de registro de log de erros na valida��o da nota fiscal
procedure pkb_log_generico_cad ( sn_loggenericocad_id  out nocopy    log_generico_cad.id%type
                               , ev_mensagem           in            log_generico_cad.mensagem%type
                               , ev_resumo             in            log_generico_cad.resumo%type
                               , en_tipo_log           in            csf_tipo_log.cd_compat%type      default 1
                               , en_referencia_id      in            log_generico_cad.referencia_id%type  default null
                               , ev_obj_referencia     in            log_generico_cad.obj_referencia%type default null
                               , en_empresa_id         in            empresa.id%type                  default null
                               , en_dm_impressa        in            log_generico_cad.dm_impressa%type    default 0
                               );

-------------------------------------------------------------------------------------------------------

--| Atualiza cadastro de e-mails conforme multorg_id e CPF/CNPJ
procedure pkb_atual_email_pessoa ( en_multorg_id  in mult_org.id%type
                                 , ev_cpf_cnpj    in varchar2
                                 , ev_email       in pessoa.email%type
                                 );

-------------------------------------------------------------------------------------------------------

--| Atualiza os dados de tabelas dependentes de ITEM
procedure pkb_atual_dep_item ( en_multorg_id  in mult_org.id%type
                             , ev_cpf_cnpj    in varchar2
                             , ev_cod_item    in item.cod_item%type 
                             );

-------------------------------------------------------------------------------------------------------

--| Atualiza os dados de tabelas dependentes de Pessoa
procedure pkb_atual_dep_pessoa ( en_multorg_id  in  mult_org.id%type
                               , ev_cpf_cnpj    in  varchar2
                               , en_empresa_id  in  empresa.id%type
                               );

-------------------------------------------------------------------------------------------------------

-- Procedimento de integra��o de par�metros fiscais de pessoa

procedure pkb_integr_pessoa_tipo_param ( est_log_generico       in out nocopy  dbms_sql.number_table
                                       , est_pessoa_tipo_param  in out nocopy  pessoa_tipo_param%rowtype
                                       , ev_cd_tipo_param       in     varchar2
                                       , ev_valor_tipo_param    in     varchar2
                                       , en_empresa_id          in             empresa.id%type
                                       );

-------------------------------------------------------------------------------------------------------

-- Procedimento de integra��o de informa��es de pagamentos de impostos retidos/SPED REINF

procedure pkb_integr_pessoa_info_pir ( est_log_generico      in out nocopy  dbms_sql.number_table
                                     , est_pessoa_info_pir   in out nocopy  pessoa_info_pir%rowtype
                                     , ev_cd_font_pag_reinf  in             rel_fonte_pagad_reinf.cod%type
                                     , en_empresa_id         in             empresa.id%type
                                     );

-------------------------------------------------------------------------------------------------------

-- Procedimento insere ou atualiza o registro de uma pessoa

procedure pkb_ins_atual_pessoa ( est_log_generico    in out nocopy  dbms_sql.number_table
                               , est_pessoa          in out nocopy  Pessoa%rowtype
                               , ev_ibge_cidade      in             Cidade.ibge_cidade%type  default null
                               , en_cod_siscomex     in             Pais.cod_siscomex%type   default null 
                               , en_loteintws_id     in             lote_int_ws.id%type default 0
                               , en_empresa_id       in             empresa.id%type
                               );

-------------------------------------------------------------------------------------------------------

-- Procedimento insere ou atualiza os dados de pessoa f�sica

procedure pkb_ins_atual_fisica ( est_log_generico    in out nocopy  dbms_sql.number_table
                               , est_fisica          in out nocopy  fisica%rowtype
                               , en_empresa_id       in             empresa.id%type
                               );

-------------------------------------------------------------------------------------------------------

-- Procedimento insere e atualiza o registro de pessoa juridica

procedure pkb_ins_atual_juridica ( est_log_generico    in out nocopy  dbms_sql.number_table
                                 , est_juridica        in out nocopy  juridica%rowtype
                                 , en_empresa_id       in             empresa.id%type
                                 );

-------------------------------------------------------------------------------------------------------

-- Procedimento insere o registro de altera��o da Tabela do Cadastro do Participante

procedure pkb_ins_alter_pessoa ( en_pessoa_id  in alter_pessoa.pessoa_id%type
                               , ev_cont_ant   in alter_pessoa.cont_ant%type
                               , ev_nr_campo   in alter_pessoa.nr_campo%type
                               , ed_dt_alt     in alter_pessoa.dt_alt%type default null );

-------------------------------------------------------------------------------------------------------

--| Procedimento para integra��o dos dados de Unidade de Medida
procedure pkb_integr_unid_med ( est_log_generico    in out nocopy  dbms_sql.number_table
                              , est_unidade         in out nocopy  unidade%rowtype 
                              , en_loteintws_id     in             lote_int_ws.id%type default 0
                              , en_empresa_id       in             empresa.id%type
                              );

-------------------------------------------------------------------------------------------------------

--| Procedimento integra as informa��es do Item

procedure pkb_integr_item ( est_log_generico    in out nocopy  dbms_sql.number_table
                          , est_item            in out nocopy  item%rowtype
                          , en_multorg_id       in             mult_org.id%type
                          , ev_cpf_cnpj         in             varchar2
                          , ev_sigla_unid       in             unidade.sigla_unid%type
                          , ev_tipo_item        in             tipo_item.cd%type
                          , ev_cod_ncm          in             ncm.cod_ncm%type
                          , ev_cod_ex_tipi      in             ex_tipi.cod_ex_tipi%type
                          , ev_tipo_servico     in             tipo_servico.cod_lst%type
                          , ev_cest_cd          in             cest.cd%type
                          , en_loteintws_id     in             lote_int_ws.id%type default 0
                          );
-------------------------------------------------------------------------------------------------------

-- Procedimento integra as informa��es do Item
procedure pkb_integr_item_ff ( est_log_generico    in out nocopy  dbms_sql.number_table
                             , en_item_id          in             item.id%type
                             , ev_atributo         in             varchar2
                             , ev_valor            in             varchar2
                             );

-------------------------------------------------------------------------------------------------------

-- Procedimento integra os item de combustiveis existentes na tabela da ANP

procedure pkb_integr_item_anp ( est_log_generico    in out nocopy  dbms_sql.number_table
                              , est_item_anp        in out nocopy  item_anp%rowtype
                              , en_empresa_id       in             empresa.id%type
                              );

-------------------------------------------------------------------------------------------------------

--| procedimento integra as informa��es de C�digos de Grupos por Marca Comercial/Refrigerantes

procedure pkb_integr_item_marca_comerc ( est_log_generico      in out nocopy  dbms_sql.number_table
                                       , est_item_marca_comerc in out nocopy  item_marca_comerc%rowtype
                                       , en_empresa_id         in             empresa.id%type 
                                       );
                                       
-------------------------------------------------------------------------------------------------------

-- Procedimento de integra��o da tabela de Lan�amento de Valores das Tabelas Din�micas do ECF
procedure pkb_integr_param_dipamgia ( est_log_generico         in out nocopy dbms_sql.number_table
                                    , est_row_param_dipamgia   in out nocopy param_dipamgia%rowtype
                                    , en_multorg_id            in            mult_org.id%type
                                    , ev_cpf_cnpj              in            varchar2
                                    , ev_ibge_estado           in            estado.ibge_estado%type
                                    , ev_cd_dipamgia           in            dipam_gia.cd%type
                                    , en_cd_cfop               in            cfop.cd%type
                                    , ev_cod_item              in            item.cod_item%type
                                    , ev_cod_ncm               in            ncm.cod_ncm%type
                                    , en_loteintws_id          in            lote_int_ws.id%type default 0
                                    );

-------------------------------------------------------------------------------------------------------

--| Procedimento integra os complementos do Item

procedure pkb_integr_item_compl ( est_log_generico          in out nocopy  dbms_sql.number_table
                                , est_item_compl            in out nocopy  item_compl%rowtype
                                , en_item_id                in             number
                                , ev_codst_csosn            in             varchar2
                                , ev_codst_icms             in             varchar2
                                , ev_codst_ipi_entrada      in             varchar2
                                , ev_codst_ipi_saida        in             varchar2
                                , ev_codst_pis_entrada      in             varchar2
                                , ev_codst_pis_saida        in             varchar2
                                , ev_codst_cofins_entrada   in             varchar2
                                , ev_codst_cofins_saida     in             varchar2
                                , ev_natrecpc_pis           in             varchar2
                                , ev_natrecpc_cofins        in             varchar2
                                , en_multorg_id             in             mult_org.id%type
 );


-------------------------------------------------------------------------------------------------------

--| procedimento integra as informa��es de convers�o de unidade

procedure pkb_integr_conv_unid ( est_log_generico             in out nocopy  dbms_sql.number_table
                               , est_conversao_unidade        in out nocopy  conversao_unidade%rowtype
                               , ev_sigla_unid                in             unidade.sigla_unid%type
                               , en_multorg_id                in             mult_org.id%type
                               , en_empresa_id                in             empresa.id%type
                               );

-------------------------------------------------------------------------------------------------------

--| Procedimento integra as informa��es dos Grupos de Patrimonio

procedure pkb_integr_grupo_pat ( est_log_generico   in out nocopy  dbms_sql.number_table
                               , est_grupo_pat      in out nocopy  grupo_pat%rowtype 
                               , en_loteintws_id    in             lote_int_ws.id%type default 0
                               , en_empresa_id      in             empresa.id%type
                               );

-------------------------------------------------------------------------------------------------------

--| Procedimento integra as informa��es dos Subgrupos do Patrimonio

procedure pkb_integr_subgrupo_pat ( est_log_generico   in out nocopy  dbms_sql.number_table
                                  , est_subgrupo_pat   in out nocopy  subgrupo_pat%rowtype
                                  , ev_cd_grupopat     in             grupo_pat.cd%type
                                  , en_multorg_id      in             mult_org.id%type
                                  , en_loteintws_id    in             lote_int_ws.id%type default 0
                                  , en_empresa_id      in             empresa.id%type
                                  );
                                  


-------------------------------------------------------------------------------------------------------

--| Procedimento integra as informa��es dos Impostos dos Subgrupos do Patrimonio

procedure pkb_integr_imp_subgrupo_pat ( est_log_generico          in out nocopy  dbms_sql.number_table
                                      , est_rec_imp_subgrupo_pat  in out nocopy  rec_imp_subgrupo_pat%rowtype
                                      , ev_cd_grupopat            in             grupo_pat.cd%type
                                      , ev_cd_subgrupopat         in             subgrupo_pat.cd%type
                                      , ev_cd_tipo_imp            in             tipo_imposto.cd%type 
                                      , en_multorg_id             in             mult_org.id%type 
                                      , en_loteintws_id           in             lote_int_ws.id%type default 0
                                      , en_empresa_id             in             empresa.id%type
                                      );

-------------------------------------------------------------------------------------------------------

--| Procedimento integra as informa��es do Bem do Ativo Imobilizado

procedure pkb_integr_bem_ativo_imob ( est_log_generico    in out nocopy  dbms_sql.number_table
                                    , est_bem_ativo_imob  in out nocopy  bem_ativo_imob%rowtype
                                    , en_multorg_id       in             mult_org.id%type
                                    , ev_cpf_cnpj         in             varchar2
                                    , ev_cod_prnc         in             bem_ativo_imob.cod_ind_bem%type
                                    , en_loteintws_id     in             lote_int_ws.id%type default 0
                                    );

-------------------------------------------------------------------------------------------------------

--| Procedimento integra os dados de Informa��es de Utiliza��o do Bem

procedure pkb_integr_infor_util_bem ( est_log_generico    in out nocopy  dbms_sql.number_table
                                    , est_infor_util_bem  in out nocopy  infor_util_bem%rowtype
                                    , en_multorg_id       in             mult_org.id%type
                                    , ev_cpf_cnpj         in             varchar2
                                    , ev_cod_ind_bem      in             bem_ativo_imob.cod_ind_bem%type 
                                    );
                                    
-------------------------------------------------------------------------------------------------------

-- Procedimento que verifica se existe os dados de "Informa��es de Utiliza��o do Bem" e caso n�o exista,
-- recupera a partir do SUB-GRUPO.

procedure pkb_rec_infor_util_bem ( en_bemativoimob_id in bem_ativo_imob.id%type
                                 , en_multorg_id      in mult_org.id%type
                                 , ev_cpf_cnpj        in varchar2
                                 , ev_cod_ind_bem     in bem_ativo_imob.cod_ind_bem%type
                                 );
                                    
-------------------------------------------------------------------------------------------------------

--| Procedimento integra as informa��es complementares do Bem do Ativo Imobilizado

procedure pkb_integr_bem_ativo_imob_comp ( est_log_generico         in out nocopy  dbms_sql.number_table
                                         , est_bem_ativo_imob_comp  in out nocopy  bem_ativo_imob%rowtype
                                         , en_bemativoimob_id       in             bem_ativo_imob.id%type
                                         , en_multorg_id            in             mult_org.id%type
                                         , ev_cpf_cnpj              in             varchar2
                                         , ev_cod_item              in             item.cod_item%type
                                         , ev_cod_subgrupopat       in             subgrupo_pat.cd%type
                                         , ev_cod_grupopat          in             grupo_pat.cd%type
                                         , en_loteintws_id          in             lote_int_ws.id%type default 0
                                         );


-------------------------------------------------------------------------------------------------------

--| Procedimento integra as informa��es dos Documentos Fiscais do Bem do Ativo Imobilizado

procedure pkb_integr_nf_bem_ativo_imob ( est_log_generico        in out nocopy  dbms_sql.number_table
                                       , est_nf_bem_ativo_imob   in out nocopy  nf_bem_ativo_imob%rowtype
                                       , en_multorg_id           in             mult_org.id%type
                                       , ev_cpf_cnpj             in             varchar2
                                       , ev_cod_ind_bem          in             bem_ativo_imob.cod_ind_bem%type
                                       , ev_cod_part             in             pessoa.cod_part%type
                                       , ev_cod_mod              in             mod_fiscal.cod_mod%type 
                                       , en_loteintws_id         in             lote_int_ws.id%type default 0
                                       );
                                       
-------------------------------------------------------------------------------------------------------

--| Procedimento integra as informa��es dos Itens dos Documentos Fiscais do Bem do Ativo Imobilizado

procedure pkb_integr_itnf_bem_ativo_imob ( est_log_generico        in out nocopy  dbms_sql.number_table
                                         , est_itnf_bem_ativo_imob in out nocopy  itnf_bem_ativo_imob%rowtype
                                         , en_multorg_id           in             mult_org.id%type
                                         , ev_cpf_cnpj             in             varchar2
                                         , ev_cod_ind_bem          in             bem_ativo_imob.cod_ind_bem%type
                                         , en_dm_ind_emit          in             nf_bem_ativo_imob.dm_ind_emit%type
                                         , ev_cod_part             in             pessoa.cod_part%type
                                         , ev_cod_mod              in             mod_fiscal.cod_mod%type 
                                         , ev_serie                in             nf_bem_ativo_imob.serie%type
                                         , en_num_doc              in             nf_bem_ativo_imob.num_doc%type
                                         , ev_cod_item             in             item.cod_item%type
                                         , en_loteintws_id         in             lote_int_ws.id%type default 0
                                         , ev_valor                in             number
                                         );
                                         
-------------------------------------------------------------------------------------------------------

--| Procedimento integra as informa��es dos Impostos do Bem

procedure pkb_integr_rec_imp_bem_ativo ( est_log_generico           in out nocopy  dbms_sql.number_table
                                       , est_rec_imp_bem_ativo_imob in out nocopy  rec_imp_bem_ativo_imob%rowtype
                                       , en_multorg_id              in             mult_org.id%type
                                       , ev_cpf_cnpj                in             varchar2
                                       , ev_cod_ind_bem             in             bem_ativo_imob.cod_ind_bem%type
                                       , ev_cd_tipo_imp             in             tipo_imposto.cd%type 
                                       , en_loteintws_id            in             lote_int_ws.id%type default 0
                                       );

-------------------------------------------------------------------------------------------------------

-- Procedimento que verifica se existe os dados do "Impostos do bem ativo" e caso n�o exista,
-- recupera a partir do REC_IMP_SUBGRUPO_PAT.

procedure pkb_rec_imp_bem_ativo ( en_bemativoimob_id in bem_ativo_imob.id%type
                                , en_multorg_id      in mult_org.id%type
                                , ev_cpf_cnpj        in varchar2
                                , ev_cod_ind_bem     in bem_ativo_imob.cod_ind_bem%type
                                );

-------------------------------------------------------------------------------------------------------

-- Procedure Insere ou atualiza registro nat_oper

procedure pkb_cria_nat_oper ( ev_cod_nat    in Nat_Oper.cod_nat%TYPE

                           , ev_descr_nat  in Nat_Oper.descr_nat%TYPE

                           , en_multorg_id in Nat_Oper.multorg_id%TYPE

                           , en_dm_st_proc in Nat_Oper.dm_st_proc%type
                           );


-------------------------------------------------------------------------------------------------------

--| Fun��o retorna o ID da NAT_OPER pelo cod_nat

function fkg_natoper_id_cod_nat ( en_multorg_id in mult_org.id%type
                                , ev_cod_nat    in Nat_Oper.cod_nat%TYPE )
         return Nat_Oper.id%TYPE;

-------------------------------------------------------------------------------------------------------

--| Procedimento integra os dados de Informa��o Complementar do Documento Fiscal

procedure pkb_integr_inf_comp_dcto_fis ( est_log_generico            in out nocopy  dbms_sql.number_table
                                       , est_infor_comp_dcto_fiscal  in out nocopy  infor_comp_dcto_fiscal%rowtype 
                                       , en_loteintws_id             in             lote_int_ws.id%type default 0
                                       , en_empresa_id               in             empresa.id%type
                                       );

-------------------------------------------------------------------------------------------------------

--| Procedimento integra os dados de Observa��o do Lan�amento Fiscal

procedure pkb_integr_obs_lancto_fiscal ( est_log_generico            in out nocopy  dbms_sql.number_table
                                       , est_obs_lancto_fiscal       in out nocopy  obs_lancto_fiscal%rowtype 
                                       , en_loteintws_id             in             lote_int_ws.id%type default 0
                                       , en_empresa_id               in             empresa.id%type
                                       );

-------------------------------------------------------------------------------------------------------

--| Procedimento integra os dados de Par�metros de C�lculo de ICMS-ST

procedure pkb_integr_item_param_icmsst ( est_log_generico       in out nocopy  dbms_sql.number_table
                                       , est_item_param_icmsst  in out nocopy  item_param_icmsst%rowtype
                                       , en_multorg_id          in             mult_org.id%type
                                       , ev_cpf_cnpj            in             varchar2
                                       , ev_cod_item 	        in 	       item.cod_item%type
                                       , ev_sigla_uf_dest       in             estado.sigla_estado%type
                                       , en_cfop_orig	        in 	       cfop.cd%type
                                       , ev_cod_obs	        in  	       obs_lancto_fiscal.cod_obs%type
                                       , en_cfop_dest	        in	       cfop.cd%type
                                       , ev_cod_st	        in 	       cod_st.cod_st%type 
                                       , en_loteintws_id        in             lote_int_ws.id%type default 0
                                       );
                                       
-------------------------------------------------------------------------------------------------------

-- Procedimento integra as informa��es do Hist�rico Padr�o

procedure pkb_integr_Hist_Padrao ( est_log_generico     in out nocopy  dbms_sql.number_table
                                 , est_row_Hist_Padrao  in out nocopy  hist_padrao%rowtype 
                                 , en_loteintws_id      in             lote_int_ws.id%type default 0
                                 );
                                       
-------------------------------------------------------------------------------------------------------

-- Procedimento integra as informa��es do centro de custo

procedure pkb_integr_Centro_Custo ( est_log_generico      in out nocopy  dbms_sql.number_table
                                  , est_row_Centro_Custo  in out nocopy  Centro_Custo%rowtype
                                  , ed_dt_fim_reg_0000    in             Abertura_ECD.dt_fim%TYPE 
                                  , en_loteintws_id       in             lote_int_ws.id%type default 0
                                  );

-------------------------------------------------------------------------------------------------------

-- Procedimento integra as informa��es da SubConta Correlata

procedure pkb_integr_subconta_correlata ( est_log_generico           in out nocopy dbms_sql.number_table
                                        , est_row_subconta_correlata in out nocopy subconta_correlata%rowtype
                                        , en_empresa_id              in            empresa.id%type
                                        , ev_cod_cta_corr            in            plano_conta.cod_cta%type
                                        , ev_cd_natsubcnt            in            nat_sub_cnt.cd%type
                                        , en_loteintws_id            in            lote_int_ws.id%type default 0
                                        );
/*
-------------------------------------------------------------------------------------------------------
-- Procedimento consiste as informa��es do PC_REFEREN
procedure pkb_consiste_pc_referen ( est_log_generico  in out nocopy dbms_sql.number_table
                                  , en_pcreferen_id   in            pc_referen.id%type
                                  );
*/
                                  
-------------------------------------------------------------------------------------------------------
/*-- Procedimento integra as informa��es do Plano de Contas Referencial Flex Field
procedure pkb_integr_pc_referen_ff ( EST_LOG_GENERICO        IN OUT NOCOPY  DBMS_SQL.NUMBER_TABLE
                                   , EN_PCREFEREN_ID         IN             PC_REFEREN.ID%TYPE
                                   , EV_ATRIBUTO             IN             VARCHAR2
                                   , EV_VALOR                IN             VARCHAR2
                                   );
*/
-------------------------------------------------------------------------------------------------------

-- Procedimento integra as informa��es do Plano de Contas Referencial

procedure pkb_integr_pc_referen ( est_log_generico    in out nocopy  dbms_sql.number_table
                                , est_row_pc_referen  in out nocopy  PC_Referen%rowtype
                                , en_empresa_id       in             Empresa.id%TYPE
                                , ev_cod_ent_ref      in             Cod_Ent_Ref.Cod_Ent_Ref%TYPE
                                , ev_cod_cta_ref      in             Plano_Conta_Ref_Ecd.cod_cta_ref%TYPE
                                , ev_cod_ccus         in             Centro_Custo.cod_ccus%TYPE
                                , en_loteintws_id     in             lote_int_ws.id%type default 0
                                ); 

-------------------------------------------------------------------------------------------------------
-- Procedimento integra as informa��es do Plano de Contas Referencial por Periodo
procedure pkb_integr_pc_referen_period ( est_log_generico    in out nocopy  dbms_sql.number_table
                                       , est_row_pc_referen  in out nocopy  PC_Referen%rowtype
                                       , en_empresa_id       in             Empresa.id%TYPE
                                       , ev_cod_ent_ref      in             Cod_Ent_Ref.Cod_Ent_Ref%TYPE
                                       , ev_cod_cta_ref      in             Plano_Conta_Ref_Ecd.cod_cta_ref%TYPE
                                       , ev_cod_ccus         in             Centro_Custo.cod_ccus%TYPE
                                       , en_loteintws_id     in             lote_int_ws.id%type default 0
                                       );

-------------------------------------------------------------------------------------------------------

--| Procedimento integra as informa��es do Plano de Contas

procedure pkb_integr_Plano_Conta ( est_log_generico     in out nocopy  dbms_sql.number_table
                                 , est_row_Plano_Conta  in out nocopy  Plano_Conta%rowtype
                                 , ev_cod_nat           in             Cod_Nat_PC.cod_nat%TYPE
                                 , ev_cod_cta_sup       in             Plano_Conta.Cod_Cta%TYPE
                                 , ed_dt_fim_reg_0000   in             Abertura_ECD.dt_fim%TYPE 
                                 , en_loteintws_id      in             lote_int_ws.id%type default 0
                                 );

-------------------------------------------------------------------------------------------------------

--| Procedimento para gravar o log referente as inclus�es/altera��es das unidades
procedure pkb_inclui_log_unidade( en_unidade_id  in log_unidade.unidade_id%type
                                , ev_resumo      in log_unidade.resumo%type
                                , ev_mensagem    in log_unidade.mensagem%type
                                , en_usuario_id  in log_unidade.usuario_id%type
                                , ev_maquina     in log_unidade.maquina%type );

-------------------------------------------------------------------------------------------------------

--| Procedimento para gravar o log referente as inclus�es/altera��es dos dados de pessoas jur�dicas
procedure pkb_inclui_log_juridica( en_juridica_id in log_juridica.juridica_id%type
                                 , ev_resumo      in log_juridica.resumo%type
                                 , ev_mensagem    in log_juridica.mensagem%type
                                 , en_usuario_id  in log_juridica.usuario_id%type
                                 , ev_maquina     in log_juridica.maquina%type );

-------------------------------------------------------------------------------------------------------

--| Procedimento para gravar o log referente as inclus�es/altera��es dos itens/produtos
procedure pkb_inclui_log_item( en_item_id     in log_item.item_id%type
                             , ev_resumo      in log_item.resumo%type
                             , ev_mensagem    in log_item.mensagem%type
                             , en_usuario_id  in log_item.usuario_id%type
                             , ev_maquina     in log_item.maquina%type );

-------------------------------------------------------------------------------------------------------

--| Procedimento para gravar o log referente as inclus�es/altera��es de pessoas
procedure pkb_inclui_log_pessoa( en_pessoa_id   in log_pessoa.pessoa_id%type
                               , ev_resumo      in log_pessoa.resumo%type
                               , ev_mensagem    in log_pessoa.mensagem%type
                               , en_usuario_id  in log_pessoa.usuario_id%type
                               , ev_maquina     in log_pessoa.maquina%type );

-------------------------------------------------------------------------------------------------------

--| Procedimento para gravar o log referente as inclus�es/altera��es dos dados de pessoas f�sicas
procedure pkb_inclui_log_fisica( en_fisica_id   in log_fisica.fisica_id%type
                               , ev_resumo      in log_fisica.resumo%type
                               , ev_mensagem    in log_fisica.mensagem%type
                               , en_usuario_id  in log_fisica.usuario_id%type
                               , ev_maquina     in log_fisica.maquina%type );

-------------------------------------------------------------------------------------------------------

--| Procedimento para gravar o log referente as inclus�es/altera��es dos dados da empresa
procedure pkb_inclui_log_empresa( en_empresa_id  in log_empresa.empresa_id%type
                                , ev_resumo      in log_empresa.resumo%type
                                , ev_mensagem    in log_empresa.mensagem%type
                                , en_usuario_id  in log_empresa.usuario_id%type
                                , ev_maquina     in log_empresa.maquina%type );
                                
-------------------------------------------------------------------------------------------------------

--| Procedimento para gravar o log referente as inclus�es/altera��es dos dados do c�digo NCM relacionado com a natureza de receita para pis e cofins
procedure pkb_inclui_log_ncm_nat_rec_pc( en_ncmnatrecpc_id  in log_ncm_nat_rec_pc.ncmnatrecpc_id%type
                                       , ev_resumo          in log_ncm_nat_rec_pc.resumo%type
                                       , ev_mensagem        in log_ncm_nat_rec_pc.mensagem%type
                                       , en_usuario_id      in log_ncm_nat_rec_pc.usuario_id%type
                                       , ev_maquina         in log_ncm_nat_rec_pc.maquina%type );

-------------------------------------------------------------------------------------------------------

--| Procedimento para gravar o log/altera��o do plano de conta
procedure pkb_inclui_log_plano_conta( en_planoconta_id  in log_plano_conta.planoconta_id%type
                                    , ev_resumo         in log_plano_conta.resumo%type
                                    , ev_mensagem       in log_plano_conta.mensagem%type
                                    , en_usuario_id     in log_plano_conta.usuario_id%type
                                    , ev_maquina        in log_plano_conta.maquina%type );
-------------------------------------------------------------------------------------------------------

--| Procedimento para gravar o log/altera��o do plano referencial
procedure pkb_inclui_log_pc_referen( en_pcreferen_id  in log_pc_referen.pcreferen_id%type
                                   , ev_resumo        in log_pc_referen.resumo%type
                                   , ev_mensagem      in log_pc_referen.mensagem%type
                                   , en_usuario_id    in log_pc_referen.usuario_id%type
                                   , ev_maquina       in log_pc_referen.maquina%type );

-------------------------------------------------------------------------------------------------------


-- Procedimento de integra��o de dados do Controle de Vers�o Cont�bil
procedure pkb_integr_ctrl_ver_contab ( est_log_generico        in out nocopy  dbms_sql.number_table
                                     , est_ctrl_ver_contab     in out nocopy  ctrl_versao_contabil%rowtype
                                     , en_multorg_id           in             mult_org.id%type 
                                     , ev_cpf_cnpj_emit        in             varchar2
                                     );

-------------------------------------------------------------------------------------------------------
-- Processo de leitura dos Par�metros DE-PARA de Item de Fornecedor para Emp. Usu�ria
procedure pkb_integr_param_item_entr ( est_log_generico      in out nocopy dbms_sql.number_table
                                     , est_row_paramitementr in out nocopy param_item_entr%rowtype
                                     );

-------------------------------------------------------------------------------------------------------
--| Par�metros de Convers�o de NFe
procedure pkb_integr_param_oper_entr ( est_log_generico      in out nocopy dbms_sql.number_table
                                     , est_row_paramoperentr in out param_oper_fiscal_entr%rowtype
                                     );

-------------------------------------------------------------------------------------------------------

-- Procedimento de integra��o da Aglutina��o Contabil
procedure pkb_integr_aglutcontabil ( est_log_generico      in out nocopy dbms_sql.number_table
                                   , est_row_aglutcontabil in out aglut_contabil%rowtype
                                   , ev_cnpj_empr          in            varchar2
                                   , en_multorg_id         in            mult_org.id%type
                                   , ev_cod_nat            in            varchar2
                                   , ev_ar_cod_agl         in            varchar2
                                   , en_loteintws_id       in            lote_int_ws.id%type default 0
                                   );

-------------------------------------------------------------------------------------------------------

-- Procedimento de integra��es da tabela PC_AGLUT_CONTABIL
procedure pkb_integr_pcaglutcontabil ( est_log_generico        in out nocopy dbms_sql.number_table
                                     , est_row_pcaglutcontabil in out nocopy pc_aglut_contabil%rowtype
                                     , en_cnpj_empr            in            varchar2
                                     , en_multorg_id           in            mult_org.id%type
                                     , ev_cod_agl              in            aglut_contabil.cod_agl%type
                                     , ev_cod_ccus             in            centro_custo.cod_ccus%type
                                     );

-------------------------------------------------------------------------------------------------------    

-- Procedimento de integra��es dos Retornos dos itens do FCI
procedure pkb_integr_retornofci ( est_log_generico    in out nocopy dbms_sql.number_table
                                , est_row_retornofci  in out nocopy retorno_fci%rowtype
                                , en_cnpj_empr        in            varchar2
                                , en_multorg_id       in            mult_org.id%type
                                , ev_cod_item         in            item.cod_item%type
                                );

-------------------------------------------------------------------------------------------------------

-- Procedimento de integra��es dos itens da Ficha de Conteudo de Integra��o
procedure pkb_integr_infitemfci ( est_log_generico    in out nocopy dbms_sql.number_table
                                , est_row_infitemfci  in out nocopy inf_item_fci%rowtype
                                , en_cnpj_empr        in            varchar2
                                , en_multorg_id       in            mult_org.id%type
                                , ev_cod_item         in            item.cod_item%type
                                );

-------------------------------------------------------------------------------------------------------

-- Procedimento de integra��o da abertura do arquivo do FCI
procedure pkb_integr_aberturafciarq ( est_log_generico       in out nocopy  dbms_sql.number_table
                                    , est_row_aberturafciarq in out nocopy  abertura_fci_arq%rowtype
                                    );

-------------------------------------------------------------------------------------------------------

-- Procedimento de integra��o dos dados de abertura do FCI
procedure pkb_integr_aberturafci ( est_log_generico    in out nocopy  dbms_sql.number_table
                                 , est_row_aberturafci in out nocopy  abertura_fci%rowtype
                                 , en_multorg_id       in             mult_org.id%type
                                 , ev_cpf_cnpj_emit    in             varchar2
                                 , en_loteintws_id     in             lote_int_ws.id%type default 0
                                 );

------------------------------------------------------------------------------------------

-- Procedimento de integra��o dos dados de Item Componente/Insumo - Bloco K - Sped Fiscal
procedure pkb_integr_item_insumo ( est_log_generico    in out nocopy  dbms_sql.number_table
                                 , est_item_insumo     in out nocopy  item_insumo%rowtype
                                 , en_multorg_id       in             mult_org.id%type
                                 , ev_cpf_cnpj_emit    in             varchar2
                                 , ev_cod_item         in             item.cod_item%type
                                 , ev_cod_item_insumo  in             item.cod_item%type
                                 , en_loteintws_id     in             lote_int_ws.id%type default 0
                                 );
                                 
-------------------------------------------------------------------------------------------------------
-- Procedimento integra as informa��es de Processos Administrativos e Judiciais da EFD Reinf
procedure pkb_integr_proc_adm_efd_reinf ( est_log_generico            in out nocopy  dbms_sql.number_table
                                        , est_row_proc_adm_efd_reinf  in out nocopy  proc_adm_efd_reinf%rowtype
                                        , en_multorg_id               in             mult_org.id%type
                                        , ev_cpf_cnpj                 in             varchar2
                                        , ev_ibge_cidade              in             varchar2
                                        , en_loteintws_id             in             lote_int_ws.id%type default 0
                                        );
                                        
-------------------------------------------------------------------------------------------------------
-- Procedimento integra as informa��es de Processos Administrativos e Judiciais Informa��es Tribut�rias da EFD Reinf
procedure pkb_integr_procadmefdreinftrib ( est_log_generico                in out nocopy  dbms_sql.number_table
                                         , est_row_procadmefdreinfinftrib  in out nocopy  proc_adm_efd_reinf_inf_trib%rowtype
                                         , en_empresa_id                   in             empresa.id%type
                                         , ev_ind_susp_exig                in             ind_susp_exig.cd%type
                                         );

-------------------------------------------------------------------------------------------------------

procedure pkb_ret_multorg_id( est_log_generico       in out nocopy  dbms_sql.number_table
                            , ev_cod_mult_org        in             mult_org.cd%type
                            , ev_hash_mult_org       in             mult_org.hash%type
                            , sn_multorg_id          in out nocopy  mult_org.id%type
                            , en_referencia_id       in             log_generico_cad.referencia_id%type
                            , ev_obj_referencia      in             log_generico_cad.obj_referencia%type
                            );

-------------------------------------------------------------------------------------------------------

-- Procedimento valida o mult org de acordo com o COD e o HASH das tabelas Flex-Field

procedure pkb_val_atrib_multorg ( est_log_generico   in out nocopy  dbms_sql.number_table
                                , ev_obj_name        in             VARCHAR2
                                , ev_atributo        in             VARCHAR2
                                , ev_valor           in             VARCHAR2
                                , sv_cod_mult_org    out            VARCHAR2
                                , sv_hash_mult_org   out            VARCHAR2
                                , en_referencia_id   in             log_generico_cad.referencia_id%type
                                , ev_obj_referencia  in             log_generico_cad.obj_referencia%type
                                );


-------------------------------------------------------------------------------------------------------

-- Procedimento valida o Valor do Diferencial de Al�quota de acordo com o vl_dif_aliq das tabelas Flex-Field

procedure pkb_val_atrib_bem_ativo ( est_log_generico   in out nocopy  dbms_sql.number_table
                                , ev_obj_name        in             VARCHAR2
                                , ev_atributo        in             VARCHAR2
                                , ev_valor           in             VARCHAR2
                                , sv_vl_dif_aliq     out            VARCHAR2                               
                                , en_referencia_id   in             log_generico_cad.referencia_id%type
                                , ev_obj_referencia  in             log_generico_cad.obj_referencia%type
                                );

-------------------------------------------------------------------------------------------------------

-- Procedimento valida o atributo cod_nif da tabela Flex-Field
procedure pkb_val_atrib_nif ( est_log_generico   in out nocopy  dbms_sql.number_table
                            , ev_obj_name        in             VARCHAR2
                            , ev_atributo        in             VARCHAR2
                            , ev_valor           in             VARCHAR2
                            , ev_cod_part        in             pessoa.cod_part%type
                            , sv_cod_nif         in out nocopy  pessoa.cod_nif%type
                            , en_referencia_id   in             log_generico_cad.referencia_id%type
                            , ev_obj_referencia  in             log_generico_cad.obj_referencia%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento valida e inclui o atributo nat_setor_pessoa da tabela Flex-Field
procedure pkb_integr_nat_set_pessoa ( est_log_generico   in out nocopy  dbms_sql.number_table
                                    , ev_obj_name        in             VARCHAR2
                                    , ev_atributo        in             VARCHAR2
                                    , ev_valor           in             VARCHAR2
                                    , ev_cod_part        in             pessoa.cod_part%type
                                    , en_multorg_id      in             mult_org.id%type                                     
                                    , en_referencia_id   in             log_generico_cad.referencia_id%type
                                    , ev_obj_referencia  in             log_generico_cad.obj_referencia%type );

-------------------------------------------------------------------------------------------------------

--| Procedimento de replicar os registros das tabelas filhas da nat_op de uma empresa para outra
procedure pkb_replica_nat_oper (en_nat_oper_id             nat_oper.id%type,
                                en_empr_id_orig            empresa.id%type, 
                                en_empr_id_dest            empresa.id%type);
                                
-------------------------------------------------------------------------------------------------------

end pk_csf_api_cad;
/
