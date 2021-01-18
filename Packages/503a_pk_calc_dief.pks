create or replace package csf_own.pk_calc_dief is

-------------------------------------------------------------------------------------------------------
--| Especifica��o do pacote de C�lculo e Gera��o dos dados da DIEF-Par� 
-------------------------------------------------------------------------------------------------------
--
-- Em 20/10/2020 - Renan Alves    
-- Redmine #71898 - DIEF - PA >> Informado apenas o "Valor Cont�bil"
-- No for do cursor C_NF_SC foi inclu�do a rotina pk_csf_api.pkb_vlr_fiscal_nfsc.
-- No for do cursor C_CT foi inclu�do a rotina pk_csf_ct.pkb_vlr_fiscal_ct.
-- Rotina: pkb_gerar_livro_apur
-- Patch_2.9.5.2 / Patch_2.9.4.5 / Release_2.9.6
--
-- Em 19/10/2020 - Renan Alves
-- Redmine #71903 - DIEF - PA >> Campos "Outros Cr�ditos � Total" e "Total de Cr�ditos"
-- Foi alterado o valor (vn_vl_total_debito) da coluna Por sa�da e/ou presta��o e
-- Outros D�bitos - Total, pois, o mesmo devera ser a soma das colunas Saldo Credor Transferido entre Estabelecimento do mesmo Grupo,
-- Saldos Credores Transferido para outro Estabelecimento e Outros D�bitos
-- Rotina: pkb_gerar_apur_icms
-- Patch_2.9.5.1 / Patch_2.9.4.4 / Release_2.9.6
--
-- Em 19/10/2020 - Renan Alves
-- Redmine #71903 - DIEF - PA >> Campos "Outros Cr�ditos - Total" e "Total de Cr�ditos"
-- Foi incluido o valor total ajuste a cr�dito (VN_VL_TOTAL_AJUST_CRED) na soma da coluna
-- outros cr�dito (VL_OUTRO_CRED_TOTAL) no insert da tabela DIEF_APUR_ICMS.
-- Rotina: pkb_gerar_apur_icms
-- Patch_2.9.5.1 / Patch_2.9.4.4 / Release_2.9.6
--
-- Em 23/01/2019 - Angela In�s.
-- Redmine #48915 - ICMS FCP e ICMS FCP ST.
-- Atribuir os campos referente aos valores de FCP que s�o retornados na fun��o de valores do Item da Nota Fiscal (pkb_vlr_fiscal_item_nf).
--
-- Em 28/10/2016 - Angela In�s.
-- Redmine #24798 - Erro de calculo da dief.
-- Utilizar o comando TO_CHAR ao inv�s do TRUNC para data de emiss�o dos cupons fiscais (cupom_fiscal.dt_emissao).
-- Rotina: pkb_gerar_livro_apur.
--
-- Em 29/09/2016 - Angela In�s.
-- Redmine #23897 - Atualiza��o da montagem do arquivo DIEF-PAR�.
-- No processo de calcular a DIEF, livro de apura��es, o processo n�o est� gravando os dados da tabela correta.
-- Rotina: pkb_gerar_livro_apur.pkb_grava_livro_apur.
--
-- Em 20/09/2016 - Angela In�s. 
-- Redmine #23594 - Corre��o no c�lculo e valida��o da DIEF-Par�.
-- 1) No processo de c�lculo alterar o registro da aba de Apura��o do ICMS quando o mesmo j� existir, passando a alterar o registro j� existente com as informa��es
-- da Apura��o do ICMS.
-- Rotina: pkb_gerar_apur_icms.
--
-------------------------------------------------------------------------------------------------------
   --
   type t_tab_dief_livro_apur is table of dief_livro_apur%rowtype index by binary_integer;
   vt_tab_dief_livro_apur t_tab_dief_livro_apur;
   --
   gn_dm_dt_escr_dfepoe   empresa.dm_dt_escr_dfepoe%type;
   --
-------------------------------------------------------------------------------------------------------
-- Procedimento de C�lculo e Gera��o dos dados da DIEF-Par�
procedure pkb_calcular ( en_aberturadief_id in abertura_dief.id%type );

-------------------------------------------------------------------------------------------------------

end pk_calc_dief;
/
