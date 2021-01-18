create or replace package pk_entr_cte_terceiro is

------------------------------------------------------------------------------------------
--| Especifica��o do pacote utilizado para Entrada de CTe de Terceiro
--
-- Em 28/12/2020   - Eduardo Linden
-- Redmine #74671  - Inclus�o do Flexfield UNID_ORG - VW_CSF_CONHEC_TRANSP_EFD_FF
-- Rotina alterada - pkb_ler_Conhec_Transp_orig => Inclus�o do novo parametro ev_cd_unid_org na rotina pk_csf_api_d100.pkb_integr_ct_d100
--
-- Em 22/12/2020     - Wendel Albino Patch 2.9.5-3 e release 296
-- Redmine #74429    - Origem integra��o CT-e Terceiro
-- Rotina Alterada   - pkb_copiar_cte - > criado parametro  en_usuario_id e ev_maquina para geracao de logs na chamada da pk_csf_api.pkb_inclui_log_conhec_transp
--
-- Em 14/09/2020     - Luis Marques - 2.9.3-6 / 2.9.4-3 / 2.9.5
-- Redmine #71120    - Ajuste de package de convers�o de CTE
-- Rotinas Alteradas - pkb_copiar_cte, pkb_desfazer_copia_cte, pkb_copiar_cte_todos, pkb_desfazer_copia_cte_todos -
--                     incluido parametro "en_empr_tomadora_serv" onde (0-N�o/1-Sim) a empresa � tomadora de servi�os
--                     e se sim (1-Sim) validar se existe na view "v_conhec_transp_tomador".
--
-- Em 26/08/2019 - Allan Magrini
-- Redmine #57655 - Alterar filtros de convers�o de CT-e do bot�o converter todos e desfazer convers�o
--                  Implementado nos cursores das duas pkb a query din�mica devido a qtde de filtros.
-- Rotina Criadas: pkb_copiar_cte_todos e pkb_desfazer_copia_cte_todos
--
-- Em 12/08/2019 - Luis Marques
-- Redmine #57250 - Convers�o de Cte�s
-- Rotina Alterada: pkb_ler_Conhec_Transp_orig - Ajustado se n�o tiver natoper(Cfop) na parametriza��o pegar da informa��o
--                  de entrada na pela.
--
-- Em 29/07/2019 - Allan Magrini
-- Redmine #56861 - N�o est� desfazendo mesmo problema das fichas Feedback #56848 e Feedback #56825
--                  Corrigido o cursor da procedure pkb_desfazer_copia_cte_todos.
-- Rotina Criadas: pkb_desfazer_copia_cte_todos
--
-- Em 26/07/2019 - Allan Magrini
-- Redmine #54939 - Altera��o no totalizador de visualiza��o de CT-e na Convers�o de Ct-e, Foram criadas as procedures
--                  para poder ser feita a convers�o de at� 9999 CT-e
-- Rotina Criadas: pkb_copiar_cte_todos e pkb_desfazer_copia_cte_todos
--
-- Em 23/05/2019 - Karina de Paula
-- Redmine #54711 - CT-e n�o exclui.
-- Rotina Alterada: pkb_desfazer_copia_cte => Inclu�do o par�metro de entrada en_excl_rloteintwsct na chamada da rotina pk_csf_api_ct.pkb_excluir_dados_ct
--
-- Em 26/04/2019 - Karina de Paula
-- Redmine #52645 - Erro na exclus�o do CT-e.
-- Rotina Alterada: pkb_desfazer_copia_cte => Inclu�da a verifica��o da vari�vel global pkb_desfazer_copia_cte que  � carregada na pk_csf_api_ct.pkb_excluir_dados_ct
--                                          gn_ind_exclu number := 0; -- Indica que o CT foi exclu�do (0-N�o / 1-Sim).
--
-- Em 28/01/2019 - Karina de Paula
-- Redmine #49617 - Erro reincidente - n�o desfazer convers�o de CT-e
-- Rotina Alterada: pkb_desfazer_copia_cte => Inclu�do tratamento de erro ORA-02292
--
-- === AS ALTERA��ES ABAIXO EST�O NA ORDEM CRESCENTE USADA ANTERIORMENTE ================================================================================= --
--
-- Em 05/06/2017 - Leandro Savenhago
-- Cria��o da Package
--
-- Em 13/10/2017 - Marcelo Ono.
-- Redmine: 35462 - Implementado o filtro de empresa, para os processos que recuperam os par�metros de PIS e COFINS.
-- Rotina: fkg_verif_param_da_cte.
--
-- Em 04/11/2017 - Marcelo Ono.
-- Redmine: 37043 - Altera��o no processo para recuperar o par�metro de ICMS do Estado do Destinat�rio.
-- Rotina: pkb_copiar_cte.
--
-- Em 11/01/2019 - Leandro Savenhago.
-- Redmine: 38209 - Uploade de Cte e Convers�o de CTe.
-- Realizar corre��o na package csf_own.pk_entr_cte_terceiro para s� permitir a convers�o de Cte que est�o com o dm_st_proc = 4
-- Rotina: fkg_verif_param_da_cte.
--
-- Em 16/04/2018 - Angela In�s.
-- Redmine #41770 - Utilizar o valor da base de ICMS do XML.
-- Para comp�r o valor da base de ICMS do registro anal�tico (ct_reg_anal), do imposto ICMS (conhec_transp_imp), e dos impostos PIS e COFINS (ct_comp_doc_pis e
-- ct_comp_doc_cofins), utilizar o valor da base de ICMS do XML/Conhecimento de origem.
-- Caso o imposto ICMS n�o exista, utilizar como era antes: valores do registro anal�tico.
-- Rotina: pkb_ler_Conhec_Transp_orig.
--
-- Em 25/04/2018 - Angela In�s.
-- Redmine #42169 - Corre��es: Registro C100 - Atualiza��o do Plano de Contas; Convers�o de CTE - CFOP.
-- O CFOP recuperado para atualizar o C�digo da Conta Cont�bil, � do Conhecimento de Transporte (conhec_transp.cfop_id).
-- Por�m o processo de convers�o de CTE considera o CFOP 1000, como valor inicial, e a rotina que gera os registros anal�ticos desse conhecimento (ct_reg_anal),
-- est� utilizando o CFOP dos par�metros de c�lculo de ICMS da empresa (param_calc_icms_empr).
-- Rotina: pkb_ler_conhec_transp_orig.
--
-- Em 20/06/2018 - Karina de Paula
-- Redmine #40168 - Convers�o de CTE e Gera��o dos campo COD_MUN_ORIG e COD_MUN_DEST no registro D100 do Sped de ICMS e IPI
-- Rotina Alterada: pkb_ler_Conhec_Transp_orig => Inclu�do os novos par�metros na chamda da pk_csf_api_d100.pkb_integr_ct_d100
--
-- Em 25/06/2018 - Karina de Paula
-- Redmine #43872 - Convers�o de CTE nao recuperando Base de Calculo (Tupperware)
-- Rotina Alterada: pkb_ler_Conhec_Transp_orig => Inclu�da a verifica��o se existe vlr para a vari�vel global gt_row_ct_reg_anal.vl_bc_icms
-- se n�o existir carrega o vlr da gt_row_ct_compdoc_pisefd.vl_bc_pis e da gt_row_ct_compdoc_cofinsefd.vl_bc_cofins com o valor da
-- gt_row_ct_reg_anal.vl_opr
--
-- Em 17/10/2018 - Karina de Paula
-- Redmine #47311 - Convers�o de CT-e modelo 67
-- Rotina Alterada: fkg_verif_param_da_cte / pkb_ler_Conhec_Transp_orig / pkb_desfazer_copia_cte => Inclu�da a rotina para o INSS
-- Rotina Criada: gt_aliq_tipoimp_ncm_empr_cof  aliq_tipoimp_ncm_empresa%rowtype;
--
-- Em 01/11/2018 - Karina de Paula
-- Redmine #47558 - Altera��es na package pk_entr_cte_terceiro para atender INSS
-- Rotina Alterada: pkb_ler_Conhec_Transp_orig => Alterada a chamada da pk_csf_api_d100.pkb_integr_ctimpret_inssefd para pk_csf_api_d100.pkb_integr_ctimpretefd
-- Rotina Alterada: pkb_ler_Conhec_Transp_orig => Inclu�da a pk_csf_api_d100.pkb_integr_ctimpretefd_ff
-- Rotina Alterada: pkb_ler_Conhec_Transp_orig => pkb_integr_ct_d100 => Inclu�dos novos par�metros de entrada dm_modal e dm_tp_serv
--
-- Em 06/11/2018 - Karina de Paula
-- Redmine #48430 - Valor Base C�lculo do INSS Fica zerado quando a redu��o � zero
-- Rotina Alterada: pkb_ler_Conhec_Transp_orig => Alterado o c�lculo do INSS
--
-- Em 13/11/2018 - Karina de Paula
-- Redmine #48611 - Karina de Paula - Convers�o de CTe criando Imposto Retido de INSS para CTe que n�o possu� (Tupperware)
-- Na atividade original pede para gerar os dados de INSS se:
-- "4 - Na procedure pkb_copiar_cte.pkb_ler_Conhec_Transp_orig realizar o c�lculo do INSS se na fun��o fkg_verif_param_da_cte
-- houver par�metros de INSS e na vt_cconhec_transp_imp_ret houver dados"
-- **** FOI INTERPRETADO QUE SE HOUVER DADOS NA CONHEC_TRANSP(vt_cconhec_transp_imp_ret) MESMO NAO HAVENDO DADOS NA fkg_verif_param_da_cte de INSS deveria ser criado o imposto.
-- Rotina Alterada: pkb_ler_Conhec_Transp_orig => A insercao do impostos foi incluida no if do valor da aliquota, se houver valor insere
--
-- === AS ALTERA��ES PASSARAM A SER INCLU�DAS NO IN�CIO DA PACKAGE ================================================================================= --
--
------------------------------------------------------------------------------------------------------------------------------------------------
--
   -- vari�veis globais
   gv_mensagem       log_generico.mensagem%type := 'Inicio';
   gv_resumo         log_generico.mensagem%type := 'Inicio';
   gd_dt_sai_ent     conhec_transp.dt_sai_ent%type;
   gn_empresa_id     empresa.id%type;
   gn_multorg_id     mult_org.id%type;
   gn_natoper_id     nat_oper.id%type;
   gn_estado_id      estado.id%type;
   gv_sql             varchar2(32767);
   --
------------------------------------------------------------------------------------------
   -- Vari�veis globais de c�pia do CTe
   --
   gt_nat_oper                   nat_oper%rowtype;
   gt_aliq_tipoimp_ncm_empr_pis  aliq_tipoimp_ncm_empresa%rowtype;
   gt_aliq_tipoimp_ncm_empr_cof  aliq_tipoimp_ncm_empresa%rowtype;
   gt_aliq_tipoimp_ncm_empr_inss aliq_tipoimp_ncm_empresa%rowtype;
   gt_param_calc_icms_empr       param_calc_icms_empr%rowtype;
   gt_nat_oper_ct                nat_oper_ct%rowtype;
   --
   gt_row_conhec_transp          conhec_transp%rowtype;
   gt_row_ct_reg_anal            ct_reg_anal%rowtype;
   gt_row_ct_compdoc_pisefd      ct_comp_doc_pis%rowtype;
   gt_row_ct_compdoc_cofinsefd   ct_comp_doc_cofins%rowtype;
   gt_row_ct_compdoc_inssefd     conhec_transp_imp_ret%rowtype;
   --
------------------------------------------------------------------------------------------
--| Informa��o adicional do conhec_transp
   --
   type tab_csf_conhec_transp is record ( id  number
                                            );
------------------------------------------------------------------------------------------

   type t_tab_csf_conhec_transp is table of tab_csf_conhec_transp index by PLS_INTEGER;
   vt_tab_csf_conhec_transp t_tab_csf_conhec_transp;

-- Procedimento de C�pia dos dados da CTe de Armazenamento de XML de Terceiro
-- para gerar um CTe de Terceiro

procedure pkb_copiar_cte ( en_conhectransp_id_orig  in conhec_transp.id%type
                         , en_empresa_id            in empresa.id%type
                         , ed_dt_sai_ent            in conhec_transp.dt_sai_ent%type
                         , en_natoper_id            in nat_oper.id%type
                         , en_empr_tomadora_serv    in number default 0 -- 0-N�o / 1-Sim				 
                         -- #74429 novos parametros
                         , en_usuario_id            in neo_usuario.id%type default null
                         , ev_maquina               in varchar2            default null					 
                         );

------------------------------------------------------------------------------------------

-- Procedimento desfaz a c�pia da CTe

procedure pkb_desfazer_copia_cte ( en_conhectransp_id_dest  in conhec_transp.id%type
                                 , en_empr_tomadora_serv    in number default 0  -- 0-N�o / 1-Sim	
                                 );

------------------------------------------------------------------------------------------

-- Procedimento de C�pia dos dados da CTe de Armazenamento de XML de Terceiro
-- para gerar um CTe de Terceiro

procedure pkb_copiar_cte_todos  ( en_empresa_id          in empresa.id%type
                                , ed_dt_ini              in  date
                                , ed_dt_fin              in  date
                                , en_coid_ini            CONHEC_TRANSP.NRO_CT%type
                                , en_coid_fin            CONHEC_TRANSP.NRO_CT%type
                                , ev_serie               CONHEC_TRANSP.SERIE%type
                                , ev_cnpj                CONHEC_TRANSP_EMIT.CNPJ%type
                                , ev_uf_ibge_emit        CONHEC_TRANSP.sigla_uf_emit%type
                                , ev_sigla_uf_ini        CONHEC_TRANSP.sigla_uf_ini%type
                                , ev_sigla_uf_fim        CONHEC_TRANSP.sigla_uf_fim%type
                                , en_dm_dacte_rec        CONHEC_TRANSP.dm_dacte_rec%type
                                , en_dm_st_proc          CONHEC_TRANSP.dm_st_proc%type
                                , en_estado_operacao     number
                                , ev_modelo              number
                                , ed_dt_sai_ent          in conhec_transp.dt_sai_ent%type
                                , en_natoper_id          in nat_oper.id%type
                                , en_empr_tomadora_serv  in number default 0);  -- 0-N�o / 1-Sim

------------------------------------------------------------------------------------------

-- Procedimento desfaz a c�pia da CTe

procedure pkb_desfazer_copia_cte_todos ( en_empresa_id           in empresa.id%type
                                        , ed_dt_ini              in  date
                                        , ed_dt_fin              in  date
                                        , en_coid_ini            CONHEC_TRANSP.NRO_CT%type
                                        , en_coid_fin            CONHEC_TRANSP.NRO_CT%type
                                        , ev_serie               CONHEC_TRANSP.SERIE%type
                                        , ev_cnpj                CONHEC_TRANSP_EMIT.CNPJ%type
                                        , ev_uf_ibge_emit        CONHEC_TRANSP.sigla_uf_emit%type
                                        , ev_sigla_uf_ini        CONHEC_TRANSP.sigla_uf_ini%type
                                        , ev_sigla_uf_fim        CONHEC_TRANSP.sigla_uf_fim%type
                                        , en_dm_dacte_rec        CONHEC_TRANSP.dm_dacte_rec%type
                                        , en_dm_st_proc          CONHEC_TRANSP.dm_st_proc%type
                                        , en_estado_operacao     number
                                        , ev_modelo              number
                                        , en_empr_tomadora_serv  in number default 0  -- 0-N�o / 1-Sim										
                                        );

------------------------------------------------------------------------------------------



end pk_entr_cte_terceiro;
/
