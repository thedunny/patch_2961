CREATE OR REPLACE PACKAGE csf_own.pk_csf_ct IS
--
-- Especifica��o do pacote de fun��es auxiliares para Conhecimento de Transporte
--
-- Em 08/01/2020   - Karina de Paula
-- Redmine #74868  - Erro de Valida��o: Dominio conhec_transp.dm_st_integra
--          74768  - Liberar de valida��o CTE legado
-- Rotina Alterada - Criada a pkb_busca_dm_ind_emit para buscar o dm_ind_emit e o dm_legado do conhecimento de transporte
-- Liberado        - Release_2.9.6
--
--
-- Em 08/04/2020 - Luis Marques - 2.9.2-4 / 2.9.3-1 / 2.9.4
-- Redmine #66713 - Nao gerou valor de base outras
-- Rotina Alterada: pkb_vlr_fiscal_ct - Para conhecimento com CST 90 e redu��o de base e o valor da redu��o sendo 
--                  colocado na base isenta foi implementado para colocar a diferen�a entre o valor da opera��o com
--                  a base isenta na base outras para fechar as bases com o valor da opera��o.
--
-- Em 31/03/2020 - Luis Marques
-- Redmine #64039 - Valor base isenta ICMS - Livro de entrada P1
-- Rotina Alterada: pkb_vlr_fiscal_ct - Verificado se o CST do conhecimento � 90 o percentual de redu��o for zero emiss�o
--                  existir valores para base de icms isenta e base para icms outras integradas no conhecimento
--                  devolver essas bases nos valores de saida da rotina.
--
-- Em 20/09/2019   - Karina de Paula
-- Redmine #53132  - Atualizar Campos Chaves da View VW_CSF_CT_INF_OUTRO
-- Rotina Alterada - fkg_ct_inf_outro_id => Incluido o campo NRO_DOCTO para ser usado como chave
--
-- Em 21/08/2019 - Eduardo Linden
-- Redmine #50987 - Exclus�o de Notas Fiscais e CTE vinculados ao REINF
-- Cria��o das fun��es para validar se Conhec. Transporte est� submetido ou n�o aos eventos R-2010 e R-2020 do Reinf.
-- Rotina criada: fkg_existe_reinf_r2010_ct e fkg_existe_reinf_r2020_ct
--
-- Em 28/07/2019 - Luis Marques
-- Redmine #56675 - feed - Est� validando CT-e que est� com a chave errada
-- Rotina Verificada: fkg_ret_valid_integr - N�o foi encontrado problema, convertido Spec e Body para ANSI e aplica��o no banco de dados.
--
-- Em 12/07/2019 - Luis MArques
-- Redmine #56155 - feed - Valida��o de chave de CT-e
-- RotinaS Alterada: pfkg_ret_valid_integr, ajustando passagem do dm_forma_emiss
--                   
-- Em 05/07/2018 - Luis Marques
-- Redmine #56042 - Parou de validar a chave de cte de terceiro
-- Rotina Alterada: fkg_ret_valid_integr incluido campos dm_forma_emiss para valida��o
--                  de forma de emiss�o <> 8 e conhecimento n�o de terceiros, DM_IND_EMIT = 0
--                  e legado (1,2,3,4), DM_LEGADO in (1,2,3,4)
--
-- Em 05/06/2019 - Karina de Paula
-- Redmine #55008 - feed - est� validando a forma de emiss�o 8
-- Rotina Alterada: fkg_ret_valid_integr => N�o valida se for NRO_CHAVE_CTE para TERCEIRO e EMISSAO PR�PRIA LEGADO
--
-- Em 31/05/2019 - Karina de Paula
-- Redmine #53834 - Erro de valida��o CTe Terceiro - Forma de emiss�o SVC-SP (LCA)
-- Rotina Criada: fkg_ret_valid_integr =. Function retorna se o dado de integra��o deve ser validado ou n�o
--
-- === AS ALTERA��ES ABAIXO EST�O NA ORDEM CRESCENTE USADA ANTERIORMENTE ================================================================================= --
--
-- Em 06/08/2013 - Angela In�s.
-- Redmine #451 - Valida��o de informa��es Fiscais.
-- Inclus�o da fun��o para retornar os dados do conhecimento de transporte para mensagens de log de inconsist�ncia.
-- Rotina: fkg_dados_conhectransp_id.
--
-- Em 05/01/2015 - Angela In�s.
-- Redmine #5616 - Adequa��o dos objetos que utilizam dos novos conceitos de Mult-Org.
-- Inclus�o da fun��o que retorna o identificador da empresa atrav�s do conhecimento de transporte. Rotina: fkg_busca_empresa_ct.
--
-- Em 26/12/2017 - Marcelo Ono
-- Redmine #36867 - Atualiza��o no processo de Integra��o do Conhecimento de Transporte para Emiss�o Pr�pria - CTe 3.00.
-- Atualizado o processo para validar o modelo fiscal 67 - Conhecimento de Transporte Eletr�nico - Outros Servi�os.
-- Rotinas: fkg_cte_nao_integrar
--
-- Em 20/09/2018 - Karina de Paula
-- Redmine #47066 - Integra��o de Conhecimento de Transporte
-- Rotina Criada: fkg_legado_ct
-- Rotina Alterada: FKG_CTE_NAO_INTEGRAR => Inclu�do o tratamento dm_legado para trazer CTE de N�O LEGADO e LEGADO
-- O campo dm_legado foi criado na tb como NULL, como o processo de integra��o de LEGADO(dm_legado=1)
-- foi criado qdo j� existia a integra��o do N�O LEGADO, esse tratamento nvl foi inclu�do para n�o ter problema
-- de integra��o com poss�veis valores nulos enviados pelo dm_legado na view de conhec_transp
-- Rotina Alterada: FKG_CTE_NAO_INTEGRAR => Inclu�do tramento do LEGADO
--
-- Em 20/09/2018 - Karina de Paula
-- Redmine #47519 - Feed - n�o integrou para a definitiva
-- Rotina Alterada: FKG_CTE_NAO_INTEGRAR => Foi retirada a verifica��o para LEGADO(dm_legado=1)
--
-- Em 29/01/2019 - Marcos Ferreira
-- Redmine #49524 - Funcionalidade - Base Isenta e Outros de Conhecimento de Transporte cuja emiss�o � pr�pria
-- Solicita��o: Unificar a procedure que retorna os valores fiscais (ICMS/ICMS-ST/IPI) de um conhecimento de transporte na api principal do Conhecimento de Transporte
-- Altera��es: Transporte da procedure pk_csf_api_d100.pkb_vlr_fiscal_ct_d100 para pk_csf_ct.pkb_vlr_fiscal_ct
-- Procedures Alteradas: pkb_vlr_fiscal_ct
--
-- === AS ALTERA��ES PASSARAM A SER INCLU�DAS NO IN�CIO DA PACKAGE ================================================================================= --
--
----------------------------------------------------------------------------------------------------------------
-- Procedure retorna o dm_ind_emit e o dm_legado do conhecimento da do Conhecimento de Transporte atrav�s do ID
procedure pkb_busca_dm_ind_emit ( en_conhectransp_id in  conhec_transp.id%type
                               , sn_dm_ind_emit     out conhec_transp.dm_ind_emit%type
                               , sn_dm_legado       out conhec_transp.dm_legado%type );

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna o id da empresa atrav�s do ID do Conhecimento de Transporte
function fkg_busca_empresa_ct ( en_conhectransp_id in conhec_transp.id%type )
         return conhec_transp.empresa_id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID do Conhecimento de Transporte conforme chave UNIQUE
function fkg_busca_conhectransp_id ( en_empresa_id       in empresa.id%type
                                   , ev_cod_part         in pessoa.cod_part%type
                                   , ev_cod_mod          in mod_fiscal.cod_mod%type
                                   , ev_serie            in conhec_transp.serie%type
                                   , ev_subserie         in conhec_transp.subserie%type
                                   , en_nro_ct           in conhec_transp.nro_ct%type
                                   , en_dm_ind_oper      in conhec_transp.dm_ind_oper%type
                                   , en_dm_ind_emit      in conhec_transp.dm_ind_emit%type
                                   , en_dm_arm_cte_terc  in conhec_transp.dm_arm_cte_terc%type
                                   )
         return conhec_transp.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o DM_ST_PROC (Situa��o do Processo) do Conhecimento de Transporte
function fkg_st_proc_ct ( en_conhectransp_id  in conhec_transp.id%type )
         return conhec_transp.dm_st_proc%type;
--
-- ==================================================================================================== --
-- Fun��o retorna o DM_LEGADO (Integra��o informa��o de CTe Legado) do Conhecimento de Transporte
-- ==================================================================================================== --
function fkg_legado_ct ( en_conhectransp_id in conhec_transp.id%type ) return conhec_transp.dm_legado%type;
--
-------------------------------------------------------------------------------------------------------

--| Fun��o retorna "1" se o conhecimento de transporte est� inutilizado e "0" se n�o est�
function fkg_ct_inutiliza ( en_empresa_id  in empresa.id%type
                          , ev_cod_mod     in mod_fiscal.cod_mod%type
                          , en_serie       in conhec_transp.serie%type
                          , en_nro_ct      in conhec_transp.nro_ct%type
                          )
         return number;

-------------------------------------------------------------------------------------------------------

--| Fun��o retorna "true" se a CT-e existe e "false" se n�o existe
function fkg_existe_cte ( en_conhec_transp  in conhec_transp.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna "true" se for uma NFe de emiss�o pr�pria j� autorizada, cancelada, denegada ou inutulizada, n�o pode ser re-integrada
function fkg_cte_nao_integrar ( en_conhectransp_id in conhec_transp.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna identifica��o do Conhecimento de Transporte atrav�s do identificador
function fkg_dados_conhectransp_id ( en_conhectransp_id in conhec_transp.id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da NF referenciada do CTe

function fkg_ct_inf_nf_id ( en_conhectransp_id in conhec_transp.id%type
                          , ev_cod_mod_nf      in mod_fiscal.cod_mod%type
                          , ev_serie_nf        in ct_inf_nf.serie%type
                          , en_nro_nf          in ct_inf_nf.nro_nf%type
                          )
          return ct_inf_nf.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da INforma��o de Unidade de Transporte COnforme o CTe

function fkg_ct_inf_unid_transp_id ( en_conhectransp_id in conhec_transp.id%type
                                   , en_dm_tp_unid_transp in ct_inf_unid_transp.dm_tp_unid_transp%type
                                   , ev_ident_unid_transp in ct_inf_unid_transp.ident_unid_transp%type
                                   )
         return ct_inf_unid_transp.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o Retona do ID da Unidade de Carga

function fkg_ct_inf_unid_carga_id ( en_conhectransp_id in conhec_transp.id%type
                                  , en_dm_tp_unid_carga in ct_inf_unid_carga.dm_tp_unid_carga%type
                                  , ev_ident_unid_carga in ct_inf_unid_carga.ident_unid_carga%type
                                  )
         return ct_inf_unid_carga.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da NFe referenciada do CTe

function fkg_ct_inf_nfe_id ( en_conhectransp_id in conhec_transp.id%type
                           , ev_nro_chave_nfe   in ct_inf_nfe.nro_chave_nfe%type
                           )
          return ct_inf_nf.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID de OUtros Documentos referenciada do CTe

function fkg_ct_inf_outro_id ( en_conhectransp_id in conhec_transp.id%type
                             , ev_dm_tipo_doc     in ct_inf_outro.dm_tipo_doc%type
                             , ev_nro_docto       in ct_inf_outro.nro_docto%type
                             ) return ct_inf_nf.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da ESTRUT_CTE desde que seja um GRUPO ou Elemento de Grupo

function fkg_estrutcte_id_grupo ( ev_campo in estrut_cte.campo%type )
         return estrut_cte.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da ESTRUT_CTE desde que seja um campo, conforme o grupo

function fkg_estrutcte_id_campo ( en_estrutcte_id  in estrut_cte.id%type
                                , ev_campo         in estrut_cte.campo%type
                                )
         return estrut_cte.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o CAMPO da ESTRUT_CTE conforme o ID

function fkg_estrutcte_campo ( en_estrutcte_id  in estrut_cte.id%type )
         return estrut_cte.campo%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna a chave de acesso de CTe de Armazenamento de Terceiro
function fkg_ret_chave_cte_arm_terc ( ev_cpf_cnpj_emit in varchar2
                                    , ev_serie         in conhec_transp.serie%type
                                    , en_nro_ct        in conhec_transp.nro_ct%type
                                    )
         return conhec_transp.nro_chave_cte%type;

-------------------------------------------------------------------------------------------------------

--Procedimento que retorna os valores fiscais (ICMS/ICMS-ST/IPI) de um conhecimento de transporte
procedure pkb_vlr_fiscal_ct ( en_ctreganal_id        in   ct_reg_anal.id%type
                            , sv_cod_st_icms         out  cod_st.cod_st%type
                            , sn_cfop                out  cfop.cd%type
                            , sn_aliq_icms           out  ct_reg_anal.aliq_icms%type
                            , sn_vl_opr              out  ct_reg_anal.vl_opr%type
                            , sn_vl_bc_icms          out  ct_reg_anal.vl_bc_icms%type
                            , sn_vl_icms             out  ct_reg_anal.vl_icms%type
                            , sn_vl_bc_isenta_icms   out  number
                            , sn_vl_bc_outra_icms    out  number
                            );
--
-------------------------------------------------------------------------------------------------------
-- Function retorna se o dado de integra��o deve ser validado ou n�o
function fkg_ret_valid_integr ( en_conhectransp_id in conhec_transp.id%type
                              , en_dm_ind_emit     in conhec_transp.dm_ind_emit%type
                              , en_dm_legado       in conhec_transp.dm_legado%type
                              , en_dm_forma_emiss  in conhec_transp.dm_forma_emiss%type
                              , ev_campo           in varchar2 ) return number;
-----------------------------------------------------------------------------------------------------
--Fun��o retorna se Conhecimento Transporte foi submetido ao evento R-2010 do REINF ou n�o. 
--E se o Conhecimento de tranporte est� no dm_st_proc igual � 7 (Exclus�o) do evento R-2010 do Reinf.
function fkg_existe_reinf_r2010_ct (en_conhectransp_id conhec_transp.id%type) return boolean;
--
-----------------------------------------------------------------------------------------------------
--Fun��o retorna se Conhecimento Transporte foi submetido ao evento R-2020 do REINF ou n�o. 
--E se o Conhecimento de tranporte est� no dm_st_proc igual � 7 (Exclus�o) do evento R-2020 do Reinf.
function fkg_existe_reinf_r2020_ct (en_conhectransp_id conhec_transp.id%type) return boolean;
--
END PK_CSF_CT;
/
