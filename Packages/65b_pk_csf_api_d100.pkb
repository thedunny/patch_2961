create or replace package body csf_own.pk_csf_api_d100 is
--
-------------------------------------------------------------------------------------------------------
--| Corpo do pacote de procedimentos de integra��o e valida��o do Registro D100
-------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna o ID do conhecimento de transporte se existir
-------------------------------------------------------------------------------------------------------
function fkg_conhec_transp_id ( en_empresa_id    in empresa.id%type
                              , en_dm_ind_emit   in conhec_transp.dm_ind_emit%type
                              , en_dm_ind_oper   in conhec_transp.dm_ind_oper%type
                              , en_pessoa_id     in pessoa.id%type
                              , en_modfiscal_id  in mod_fiscal.id%type
                              , ev_serie         in conhec_transp.serie%type
                              , ev_subserie      in conhec_transp.subserie%type
                              , en_nro_ct        in conhec_transp.nro_ct%type )
         return conhec_transp.id%type
is
   --
   vn_conhectransp_id conhec_transp.id%type;
   --
begin
   --
   select max(ct.id)
     into vn_conhectransp_id
     from conhec_transp ct
    where ct.empresa_id       = en_empresa_id
      and ct.dm_ind_emit      = en_dm_ind_emit
      and ct.dm_ind_oper      = en_dm_ind_oper
      and (ct.pessoa_id is null or ct.pessoa_id = en_pessoa_id)
      and ct.modfiscal_id     = en_modfiscal_id
      and ct.serie            = ev_serie
      and (ev_subserie is null or ct.subserie = ev_subserie)
      and ct.nro_ct           = en_nro_ct
      and ct.dm_arm_cte_terc  = 0;
   --
   return vn_conhectransp_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      return null;
end fkg_conhec_transp_id;
--------------------------------------------------------------------------------------------------------------------------------
-- Fun��o retorna o ID do XML do conhecimento de transporte atrav�s da chave de acesso, e retornar se o mesmo estiver cancelado
--------------------------------------------------------------------------------------------------------------------------------
function fkg_xml_conhec_transp_chv ( ev_nro_chave_cte in conhec_transp.nro_chave_cte%type )
         return boolean
is
   --
   vn_conhectransp_id conhec_transp.id%type;
   --
begin
   --
   begin
      select max(ct.id)
        into vn_conhectransp_id
        from conhec_transp ct
       where ct.nro_chave_cte   = ev_nro_chave_cte
         and ct.dm_arm_cte_terc = 1;
   exception
      when others then
         vn_conhectransp_id := 0;
   end;
   --
   if nvl(vn_conhectransp_id,0) <> 0 then
      --
      begin
         select ct.id
           into vn_conhectransp_id
           from conhec_transp ct
          where ct.id         = vn_conhectransp_id
            and ct.dm_st_proc = 7; -- cancelado
      exception
         when others then
            vn_conhectransp_id := 0;
      end;
      --
   end if;
   --
   if nvl(vn_conhectransp_id,0) = 0 then
      return false;
   else
      return true;
   end if;
   --
exception
   when others then
      return false;
end fkg_xml_conhec_transp_chv;
-------------------------------------------------------------------------------------------------------
-- Fun��o que retorna a exist�ncia do conhecimentos de transporte
-------------------------------------------------------------------------------------------------------
function fkg_existe_conhec_transp_id ( en_conhectransp_id in conhec_transp.id%type )
         return boolean
is
   --
   vn_dummy number := 0;
   --
begin
   --
   select 1 into vn_dummy
     from conhec_transp
    where id = en_conhectransp_id;
   --
   if nvl(vn_dummy,0) > 0 then
      return true;
   else
      return false;
   end if;
   --
exception
   when no_data_found then
      return false;
   when others then
      return false;
end fkg_existe_conhec_transp_id;
-------------------------------------------------------------------------------------------------------
-- Retorna ID do Valores Prestados atrav�s do id do conhecimento de transporte
-------------------------------------------------------------------------------------------------------
function fkg_conhec_transp_vlprest_id ( en_conhectransp_id in conhec_transp.id%type )
         return conhec_transp_vlprest.id%type
is
   --
   vn_ct_vlprest_id conhec_transp_vlprest.id%type;
   --
begin
   --
   if nvl(en_conhectransp_id, 0) > 0 then
      --
      select max(a.id)
        into vn_ct_vlprest_id
        from conhec_transp_vlprest a
       where a.conhectransp_id = en_conhectransp_id;
      --
   end if;
   --
   return vn_ct_vlprest_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      return null;
end fkg_conhec_transp_vlprest_id;
-------------------------------------------------------------------------------------------------------
-- Retorna ID do imposto do ICMS atrav�s do id do conhecimento de transporte
-------------------------------------------------------------------------------------------------------
function fkg_conhec_transp_imp_id ( en_conhectransp_id in conhec_transp.id%type )
         return conhec_transp_imp.id%type
is
   --
   vn_ct_imp_id conhec_transp_imp.id%type;
   --
begin
   --
   if nvl(en_conhectransp_id, 0) > 0 then
      --
      select max(a.id)
        into vn_ct_imp_id
        from conhec_transp_imp a
           , tipo_imposto b
       where a.conhectransp_id = en_conhectransp_id
         and b.cd = 1 --ICMS
         and a.tipoimp_id = b.id;
      --
   end if;
   --
   return vn_ct_imp_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      return null;
end fkg_conhec_transp_imp_id;
-------------------------------------------------------------------------------------------------------
-- Retorna dm_st_proc atrav�s do id do conhecimento de transporte
-------------------------------------------------------------------------------------------------------
function fkg_ct_dm_st_proc ( en_conhectransp_id in conhec_transp.id%type )
         return conhec_transp.dm_st_proc%type
is
   --
   vn_dm_st_proc conhec_transp.dm_st_proc%type;
   --
begin
   --
   if nvl(en_conhectransp_id, 0) > 0 then
      --
      select dm_st_proc
        into vn_dm_st_proc
        from conhec_transp p
       where p.id = en_conhectransp_id;
      --
   end if;
   --
   return vn_dm_st_proc;
   --
exception
   when no_data_found then
      return null;
   when others then
      return null;
end fkg_ct_dm_st_proc;
-------------------------------------------------------------------------------------------------------------------------------------
-- Fun��o para retornar o tipo de emitente d� conhecimento de transporte - conhec_transp.dm_ind_emit = 0-emiss�o pr�pria, 1-terceiros
-------------------------------------------------------------------------------------------------------------------------------------
function fkg_dmindemit_conhectransp ( en_conhectransp_id in conhec_transp.id%type )
         return conhec_transp.dm_ind_emit%type
is
   --
   vn_dm_ind_emit  conhec_transp.dm_ind_emit%type;
   --
begin
   --
   select ct.dm_ind_emit
     into vn_dm_ind_emit
     from conhec_transp ct
    where ct.id = en_conhectransp_id;
   --
   return vn_dm_ind_emit;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Problemas em fkg_dmindemit_conhectransp. Erro = '||sqlerrm);
end fkg_dmindemit_conhectransp;
-------------------------------------------------------------------------------------------------------
--| Procedimento para excluir registros de conhecimento de transporte
-------------------------------------------------------------------------------------------------------
procedure pkb_excluir_dados_ct ( en_conhectransp_id in conhec_transp.id%type )
is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_ct.id%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
   delete from r_loteintws_ct where conhectransp_id = en_conhectransp_id;
   --
   delete from ct_aereo_carg_esp a
    where a.conhectranspaereo_id in (select b.id
                                       from conhec_transp_aereo b
                                      where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 2;
   delete from ct_aereo_dimen a
    where a.conhectranspaereo_id in (select b.id
                                       from conhec_transp_aereo b
                                      where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 3;
   delete from ct_aereo_inf_man a
    where a.conhectranspaereo_id in (select b.id
                                       from conhec_transp_aereo b
                                      where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 4;
   delete from conhec_transp_aereo a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 5;
   delete from conhec_transp_anul a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 6;
   delete from ct_aquav_balsa a
    where a.conhectranspaquav_id in (select b.id
                                       from conhec_transp_aquav b
                                      where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 7;
   delete from ct_aquav_cont_lacre a
    where a.ctaquavcont_id in (select b.id
                                 from ct_aquav_cont b
                                where b.conhectranspaquav_id in (select c.id
                                                                   from conhec_transp_aquav c
                                                                  where c.conhectransp_id = en_conhectransp_id));
   --
   vn_fase := 8;
   delete from ct_aquav_cont_nf a
    where a.ctaquavcont_id in (select b.id
                                 from ct_aquav_cont b
                                where b.conhectranspaquav_id in (select c.id
                                                                   from conhec_transp_aquav c
                                                                  where c.conhectransp_id = en_conhectransp_id));
   --
   vn_fase := 9;
   delete from ct_aquav_cont_nfe a
    where a.ctaquavcont_id in (select b.id
                                 from ct_aquav_cont b
                                where b.conhectranspaquav_id in (select c.id
                                                                   from conhec_transp_aquav c
                                                                  where c.conhectransp_id = en_conhectransp_id));
   --
   vn_fase := 10;
   delete from ct_aquav_cont a
    where a.conhectranspaquav_id in (select b.id
                                       from conhec_transp_aquav b
                                      where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 11;
   delete from ctaquav_lacre a
    where a.conhectranspaquav_id in (select b.id
                                       from conhec_transp_aquav b
                                      where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 12;
   delete from conhec_transp_aquav a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 13;
   delete from conhec_transp_canc a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 14;
   delete from ct_carga_doc_fiscal a
    where a.conhectranspcarga_id in (select b.id
                                       from conhec_transp_carga b
                                      where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 15;
   delete from ct_carga_local a
    where a.conhectranspcarga_id in (select b.id
                                       from conhec_transp_carga b
                                      where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 16;
   delete from conhec_transp_carga a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 17;
   delete from ct_compl_obs a
    where a.conhectranspcompl_id in (select b.id
                                       from conhec_transp_compl b
                                      where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 18;
   delete from ct_compl_pass a
    where a.conhectranspcompl_id in (select b.id
                                       from conhec_transp_compl b
                                      where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 19;
   delete from conhec_transp_compl a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 20;
   delete from ctcompltado_comp a
    where a.conhectranspcompltado_id in (select b.id
                                           from conhec_transp_compltado b
                                          where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 21;
   delete from ctcompltado_imp a
    where a.conhectranspcompltado_id in (select b.id
                                           from conhec_transp_compltado b
                                          where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 22;
   delete from conhec_transp_compltado a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 23;
   delete from ctcont_lacre a
    where a.conhectranspcont_id in (select b.id
                                      from conhec_transp_cont b
                                     where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 24;
   delete from conhec_transp_cont a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 25;
   delete from ctdest_locent a
    where a.conhectranspdest_id in (select b.id
                                      from conhec_transp_dest b
                                     where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 26;
   delete from conhec_transp_dest a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 27;
   delete from ctdocant_eletr a
    where a.conhectranspdocant_id in (select b.id
                                        from conhec_transp_docant b
                                       where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 28;
   delete from ctdocant_papel a
    where a.conhectranspdocant_id in (select b.id
                                        from conhec_transp_docant b
                                       where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 29;
   delete from conhec_transp_docant a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 30;
   delete from conhec_transp_dup a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 31;
   delete from conhec_transp_duto a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 32;
   delete from conhec_transp_email a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 33;
   delete from conhec_transp_emit a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 34;
   delete from conhec_transp_exped a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 35;
   delete from conhec_transp_fat a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 36;
   delete from ctferrovdcldetvag_cont a
    where a.ctferrovdcldetvag_id in (select b.id
                                       from ctferrovdcl_detvag b
                                      where b.ctferrovdcl_id in (select c.id
                                                                   from ctferrov_dcl c
                                                                  where c.conhectranspferrov_id in (select d.id
                                                                                                      from conhec_transp_ferrov d
                                                                                                     where d.conhectransp_id = en_conhectransp_id)));
   --
   vn_fase := 37;
   delete from ctferrovdcldetvag_lacre a
    where a.ctferrovdcldetvag_id in (select b.id
                                       from ctferrovdcl_detvag b
                                      where b.ctferrovdcl_id in (select c.id
                                                                   from ctferrov_dcl c
                                                                  where c.conhectranspferrov_id in (select d.id
                                                                                                      from conhec_transp_ferrov d
                                                                                                     where d.conhectransp_id = en_conhectransp_id)));
   --
   vn_fase := 38;
   delete from ctferrovdcl_detvag a
    where a.ctferrovdcl_id in (select b.id
                                 from ctferrov_dcl b
                                where b.conhectranspferrov_id in (select c.id
                                                                    from conhec_transp_ferrov c
                                                                   where c.conhectransp_id = en_conhectransp_id));
   --
   vn_fase := 39;
   delete from ctferrov_dcl a
    where a.conhectranspferrov_id in (select b.id
                                        from conhec_transp_ferrov b
                                       where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 40;
   delete from ct_ferrov_detvag_cont a
    where a.ctferrovdetvag_id in (select b.id
                                    from ct_ferrov_detvag b
                                   where b.conhectranspferrov_id in (select c.id
                                                                       from conhec_transp_ferrov c
                                                                      where c.conhectransp_id = en_conhectransp_id));
   --
   vn_fase := 41;
   delete from ct_ferrov_detvag_lacre a
    where a.ctferrovdetvag_id in (select b.id
                                    from ct_ferrov_detvag b
                                   where b.conhectranspferrov_id in (select c.id
                                                                       from conhec_transp_ferrov c
                                                                      where c.conhectransp_id = en_conhectransp_id));
   --
   vn_fase := 42;
   delete from ct_ferrov_detvag_nf a
    where a.ctferrovdetvag_id in (select b.id
                                    from ct_ferrov_detvag b
                                   where b.conhectranspferrov_id in (select c.id
                                                                       from conhec_transp_ferrov c
                                                                      where c.conhectransp_id = en_conhectransp_id));
   --
   vn_fase := 43;
   delete from ct_ferrov_detvag_nfe a
    where a.ctferrovdetvag_id in (select b.id
                                    from ct_ferrov_detvag b
                                   where b.conhectranspferrov_id in (select c.id
                                                                       from conhec_transp_ferrov c
                                                                      where c.conhectransp_id = en_conhectransp_id));
   --
   vn_fase := 44;
   delete from ct_ferrov_detvag a
    where a.conhectranspferrov_id in (select b.id
                                        from conhec_transp_ferrov b
                                       where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 45;
   delete from ctferrov_subst a
    where a.conhectranspferrov_id in (select b.id
                                        from conhec_transp_ferrov b
                                       where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 46;
   delete from conhec_transp_ferrov a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 47;
   delete from conhec_transp_imp a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 47.1;
   delete from conhec_transp_imp_ret a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 48;
   delete from conhec_transp_impr a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 49;
   delete from ctinfcarga_qtde a
    where a.conhectranspinfcarga_id in (select b.id
                                          from conhec_transp_infcarga b
                                         where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 50;
   delete from conhec_transp_infcarga a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 51;
   delete from ct_item_compl a
    where a.conhectranspitem_id in (select b.id
                                      from conhec_transp_item b
                                     where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 52;
   delete from conhec_transp_item a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 53;
   delete from conhec_transp_pdf a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 54;
   delete from conhec_transp_peri a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 55;
   delete from conhec_transp_receb a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 56;
   delete from ctrem_inf_nf_locret a
    where a.ctreminfnf_id in (select b.id
                                from ctrem_inf_nf b
                               where b.conhectransprem_id in (select c.id
                                                                from conhec_transp_rem c
                                                               where c.conhectransp_id = en_conhectransp_id));
   --
   vn_fase := 57;
   delete from ctrem_inf_nf a
    where a.conhectransprem_id in (select b.id
                                     from conhec_transp_rem b
                                    where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 58;
   delete from ctrem_inf_nfe a
    where a.conhectransprem_id in (select b.id
                                     from conhec_transp_rem b
                                    where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 59;
   delete from ctrem_inf_outro a
    where a.conhectransprem_id in (select b.id
                                     from conhec_transp_rem b
                                    where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 60;
   delete from ctrem_loc_colet a
    where a.conhectransprem_id in (select b.id
                                     from conhec_transp_rem b
                                    where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 61;
   delete from conhec_transp_rem a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 62;
   delete from ctrodo_inf_valeped a
    where a.conhectransprodo_id in (select b.id
                                      from conhec_transp_rodo b
                                     where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 63;
   delete from ctrodo_lacre a
    where a.conhectransprodo_id in (select b.id
                                      from conhec_transp_rodo b
                                     where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 64;
   delete from ctrodo_moto a
    where a.conhectransprodo_id in (select b.id
                                      from conhec_transp_rodo b
                                     where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 65;
   delete from ctrodo_occ a
    where a.conhectransprodo_id in (select b.id
                                      from conhec_transp_rodo b
                                     where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 66;
   delete from ctrodo_valeped_disp a
    where a.ctrodovaleped_id in (select b.id
                                   from ctrodo_valeped b
                                  where b.conhectransprodo_id in (select c.id
                                                                    from conhec_transp_rodo c
                                                                   where c.conhectransp_id = en_conhectransp_id));
   --
   vn_fase := 67;
   delete from ctrodo_valeped a
    where a.conhectransprodo_id in (select b.id
                                      from conhec_transp_rodo b
                                     where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 68;
   delete from ctrodo_veic_prop a
    where a.ctrodoveic_id in (select b.id
                                from ctrodo_veic b
                               where b.conhectransprodo_id in (select c.id
                                                                 from conhec_transp_rodo c
                                                                where c.conhectransp_id = en_conhectransp_id));
   --
   vn_fase := 69;
   delete from ctrodo_veic a
    where a.conhectransprodo_id in (select b.id
                                      from conhec_transp_rodo b
                                     where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 70;
   delete from conhec_transp_rodo a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 71;
   delete from conhec_transp_seg a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 72;
   delete from conhec_transp_subst a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 73;
   delete from conhec_transp_tomador a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 74;
   delete from conhec_transp_veic a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 75;
   delete from ctvlprest_comp a
    where a.conhectranspvlprest_id in (select b.id
                                         from conhec_transp_vlprest b
                                        where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 76;
   delete from conhec_transp_vlprest a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 77;
   delete from ct_aut_xml a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 78;
   delete from ct_comp_doc_cofins a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 79;
   delete from ct_comp_doc_pis a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 80;
   delete from ct_compl_aereo a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 81;
   delete from ct_compl_aquav a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 82;
   delete from ct_compl_rodo a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 83;
   delete from ct_inf_prov a
    where a.ctinforfiscal_id in (select b.id
                                   from ctinfor_fiscal b
                                  where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 84;
   delete from ctinfor_fiscal a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 85;
   delete from ct_cons_sit a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 86;
   delete from ct_modais a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 87;
   delete from ct_multimodal a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 88;
   delete from ct_proc_ref a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 89;
   delete from ct_reg_anal a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 90;
   delete from r_ctinfnf_ctinfunidcarga a
    where a.ctinfnf_id in (select b.id
                             from ct_inf_nf b
                            where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 91;
   delete from r_ctinfnf_ctinfunidtransp a
    where a.ctinfnf_id in (select b.id
                             from ct_inf_nf b
                            where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 92;
   delete from r_ctinfnfe_ctinfunidcarga a
    where a.ctinfnfe_id in (select b.id
                              from ct_inf_nfe b
                             where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 93;
   delete from r_ctinfnfe_ctinfunidtransp a
    where a.ctinfnfe_id in (select b.id
                              from ct_inf_nfe b
                             where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 94;
   delete from r_ctinfoutro_ctinfunidcarga a
    where a.ctinfoutro_id in (select b.id
                              from ct_inf_outro b
                             where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 95;
   delete from r_ctinfoutro_ctinfunidtransp a
    where a.ctinfoutro_id in (select b.id
                              from ct_inf_outro b
                             where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 96;
   delete from ct_inf_unid_carga_lacre a
    where a.ctinfunidcarga_id in (select b.id
                                    from ct_inf_unid_carga b
                                   where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 97;
   delete from r_ctinfnf_ctinfunidcarga a
    where a.ctinfunidcarga_id in (select b.id
                                    from ct_inf_unid_carga b
                                   where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 98;
   delete from r_ctinfnfe_ctinfunidcarga a
    where a.ctinfunidcarga_id in (select b.id
                                    from ct_inf_unid_carga b
                                   where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 99;
   delete from r_ctinfoutro_ctinfunidcarga a
    where a.ctinfunidcarga_id in (select b.id
                                    from ct_inf_unid_carga b
                                   where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 100;
   delete from ct_iut_carga_lacre a
    where a.ctinfunidtranspcarga_id in (select b.id
                                          from ct_inf_unid_transp_carga b
                                         where b.ctinfunidtransp_id in (select c.id
                                                                          from ct_inf_unid_transp c
                                                                         where c.conhectransp_id = en_conhectransp_id));
   --
   vn_fase := 101;
   delete from ct_inf_unid_transp_carga a
    where a.ctinfunidtransp_id in (select b.id
                                     from ct_inf_unid_carga b
                                    where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 102;
   delete from ct_inf_unid_transp_lacre a
    where a.ctinfunidtransp_id in (select b.id
                                     from ct_inf_unid_carga b
                                    where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 103;
   delete from r_ctinfnf_ctinfunidtransp a
    where a.ctinfunidtransp_id in (select b.id
                                     from ct_inf_unid_carga b
                                    where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 104;
   delete from r_ctinfnfe_ctinfunidtransp a
    where a.ctinfunidtransp_id in (select b.id
                                     from ct_inf_unid_carga b
                                    where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 105;
   delete from r_ctinfoutro_ctinfunidtransp a
    where a.ctinfunidtransp_id in (select b.id
                                     from ct_inf_unid_carga b
                                    where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 106;
   delete from ct_inf_nf a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 107;
   delete from ct_inf_nfe a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 108;
   delete from ct_inf_outro a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 109;
   delete from ct_inf_unid_carga a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 110;
   delete from ct_inf_unid_transp a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 111;
   delete from evento_cte_cce a
    where a.eventocte_id in (select b.id
                               from evento_cte b
                              where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 112;
   delete from evento_cte_cce a
    where a.eventocte_id in (select b.id
                               from evento_cte b
                              where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 113;
   delete from evento_cte_epec a
    where a.eventocte_id in (select b.id
                               from evento_cte b
                              where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 114;
   delete from evento_cte_multimodal a
    where a.eventocte_id in (select b.id
                               from evento_cte b
                              where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 115;
   delete from evento_cte_retorno a
    where a.eventocte_id in (select b.id
                               from evento_cte b
                              where b.conhectransp_id = en_conhectransp_id);
   --
   vn_fase := 116;
   delete from evento_cte a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 117;
   delete from frete_itemnf a
    where a.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 118;
   delete from r_ctrlintegrarq_ct r
    where r.conhectransp_id = en_conhectransp_id;
   --
   vn_fase := 119;
   delete from ct_dif_aliq r
    where r.conhectransp_id = en_conhectransp_id;   
   --   
   vn_fase := 120;
   delete from log_conhec_transp a
    where a.conhectransp_id = en_conhectransp_id;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_d100.pkb_excluir_dados_ct fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_mensagem_log
                                           , ev_resumo          => null
                                           , en_tipo_log        => erro_de_sistema
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_excluir_dados_ct;
-------------------------------------------------------------------------------------------------------
--| Procedimento seta o tipo de integra��o que ser� feito
-- 0 - Somente v�lida os dados e registra o Log de ocorr�ncia
-- 1 - V�lida os dados e registra o Log de ocorr�ncia e insere a informa��o
-- Todos os procedimentos de integra��o fazem refer�ncia a ele
-------------------------------------------------------------------------------------------------------
procedure pkb_seta_tipo_integr ( en_tipo_integr in number )
is
Begin
   --
   gn_tipo_integr := en_tipo_integr;
   --
end pkb_seta_tipo_integr;
-------------------------------------------------------------------------------------------------------
--| Procedimento seta o objeto de referencia utilizado na Valida��o da Informa��o
-------------------------------------------------------------------------------------------------------
procedure pkb_seta_obj_ref ( ev_objeto in varchar2 )
is
begin
   --
   gv_obj_referencia := upper(ev_objeto);
   --
end pkb_seta_obj_ref;
-------------------------------------------------------------------------------------------------------
--| Procedimento integra os dados de Observa��o do Lan�amento Fiscal
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
                             )
is
   --
   vn_fase                   number := 0;
   vn_loggenerico_id         Log_Generico_ct.id%TYPE;
   vt_log_generico           dbms_sql.number_table;
   vn_empresa_id             empresa.id%TYPE;
   vn_pessoa_id              pessoa.id%TYPE;
   vn_modfiscal_id           mod_fiscal.id%TYPE;
   vn_sitdocto_id            sit_docto.id%TYPE;
   vn_inforcompdctofiscal_id infor_comp_dcto_fiscal.id%TYPE;
   vv_cnpj_cpf               varchar2(14);
   vv_insc_estadual          varchar2(14);
   vv_sigla_estado           varchar2(2);
   vn_ct_vlserv              number;
   vn_ct_imp                 number;
   vn_natoper_id             nat_oper.id%type;
   vv_nro_chave_cte          conhec_transp.nro_chave_cte%type;
   vv_cpf_cnpj_emit          varchar2(14);
   vv_nro_lote               varchar2(30) := null;
   vn_cfop_id                cfop.id%type;
   vn_cd_cfop                cfop.cd%type;
   vn_qtde_erro_chave        number := 0;
   vv_dummy                  varchar2(255);
   vn_valida                 number(1);
   vn_dm_forma_emiss         conhec_transp.dm_forma_emiss%type;
   --
   vn_unidorg_id             conhec_transp.unidorg_id%type;
   --
begin
   --
   vn_fase := 1;
   --
   pkb_seta_obj_ref ( ev_objeto => 'CONHEC_TRANSP');
   --
   vn_pessoa_id := pk_csf.fkg_pessoa_id_cod_part ( en_multorg_id => en_multorg_id
                                                 , ev_cod_part   => trim(ev_cod_part) );
   --
   vn_fase := 2;
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_cabec_log := 'Empresa: ' || ev_cpf_cnpj_emit;
   gv_cabec_log := gv_cabec_log || chr(10) || 'N�mero: ' || en_nro_nf;
   gv_cabec_log := gv_cabec_log || chr(10) || 'S�rie: ' || ev_serie;
   gv_cabec_log := gv_cabec_log || chr(10) || 'Participante: ' || pk_csf.fkg_nome_pessoa_id ( en_pessoa_id => vn_pessoa_id );
   gv_cabec_log := gv_cabec_log || chr(10) || vv_nro_lote;
   --
   vn_fase := 3;
   --
   vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id => en_multorg_id
                                                        , ev_cpf_cnpj   => ev_cpf_cnpj_emit );
   --
   if nvl(vn_empresa_id,0) <= 0 then
      --
      if length(ev_cpf_cnpj_emit) = 14 then
         --
         select max(e.id)
           into vn_empresa_id
           from Empresa   e
              , Juridica  j
          where j.num_cnpj     = to_number( substr(ev_cpf_cnpj_emit, 1, 8) )
            and j.num_filial   = to_number( substr(ev_cpf_cnpj_emit, 9, 4) )
            and j.dig_cnpj     = to_number( substr(ev_cpf_cnpj_emit, 13, 2) )
            and e.pessoa_id    = j.pessoa_id
            and e.multorg_id   = en_multorg_id;
         --
      elsif length(ev_cpf_cnpj_emit) = 11 then
         --
         select max(e.id)
           into vn_empresa_id
           from Empresa   e
              , Fisica    f
          where f.num_cpf      = to_number( substr(ev_cpf_cnpj_emit, 1, 9) )
            and f.dig_cpf      = to_number( substr(ev_cpf_cnpj_emit, 10, 2) )
            and e.pessoa_id    = f.pessoa_id
            and e.multorg_id   = en_multorg_id;
         --
      end if;
      --
   end if;
   --
   vn_fase := 4;
   --
   vn_modfiscal_id := pk_csf.fkg_Mod_Fiscal_id ( ev_cod_mod => ev_cod_mod );
   --
   vn_fase := 5;
   --
   vn_sitdocto_id := pk_csf.fkg_Sit_Docto_id ( ev_cd => ev_sit_docto );
   --
   vn_fase := 6;
   --
   vn_inforcompdctofiscal_id := pk_csf.fkg_Infor_Comp_Dcto_Fiscal_id ( en_multorg_id => en_multorg_id
                                                                     , en_cod_infor  => ev_cod_inf );
   --
   vn_fase := 7;
   --
   sn_conhectransp_id := fkg_conhec_transp_id ( en_empresa_id    => vn_empresa_id
                                              , en_dm_ind_emit   => en_dm_ind_emit
                                              , en_dm_ind_oper   => en_dm_ind_oper
                                              , en_pessoa_id     => vn_pessoa_id
                                              , en_modfiscal_id  => vn_modfiscal_id
                                              , ev_serie         => ev_serie
                                              , ev_subserie      => ev_subserie
                                              , en_nro_ct        => en_nro_nf );
   --
   vn_fase := 8;
   --
   if nvl(sn_conhectransp_id,0) <= 0 then
      --
      select conhectransp_seq.nextval
        into sn_conhectransp_id
        from dual;
      --
   end if;
   --
   gn_referencia_id := sn_conhectransp_id;
   --
   vn_fase := 9;
   -- Exclui dos dados p/ realizar nova integra��o
   if nvl(gn_tipo_integr, 0) = 1 then
      --
      vn_fase := 9.1;
      -- Excluir os dados do Conhecimento de Transporte para integrar Novamente
      pkb_excluir_dados_ct ( en_conhectransp_id => sn_conhectransp_id );
      --
   end if;
   --
   vn_fase := 9.2;
   -- Limpa os logs
   delete log_generico_ct o
    where o.obj_referencia = gv_obj_referencia
      and o.referencia_id  = sn_conhectransp_id;
   --
   commit;
   --
   vn_fase := 10;
   --
   if nvl(vn_pessoa_id,0) <= 0 then
      --
      vn_fase := 10.1;
      --
      gv_mensagem_log := '"Participante" n�o informado ou inv�lido (' || ev_cod_part || ').';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 11;
   --
   if nvl(vn_pessoa_id,0) > 0 then
      --
      vn_fase := 11.1;
      -- Busca o CNPJ ou CPF, Inscri��o Estadual e UF do Participante
      vv_cnpj_cpf      := pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => vn_pessoa_id );
      vv_insc_estadual := pk_csf.fkg_ie_pessoa_id ( en_pessoa_id => vn_pessoa_id );
      vv_sigla_estado  := pk_csf.fkg_siglaestado_pessoaid ( en_pessoa_id => vn_pessoa_id );
      --
      -- Valida CNPJ ou CPF
      if trim(vv_cnpj_cpf) is not null
         and nvl(pk_valida_docto.fkg_valida_cpf_cgc(ev_numero => vv_cnpj_cpf), 0) = 0 then
         --
         vn_fase := 11.2;
         --
         gv_mensagem_log := 'O "CPF ou CNPJ do Participante" est� inv�lido (' || vv_cnpj_cpf || ').';
         --
         vn_loggenerico_id := null;
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => ERRO_DE_VALIDACAO
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
        --
        -- Armazena o "loggenerico_id" na mem�ria
        pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                          , est_log_generico  => est_log_generico );
      --
      end if;
      --
      -- Valida Inscri��o Estadual
      if trim(vv_insc_estadual) is not null
         and trim(vv_sigla_estado) is not null
         and nvl(pk_valida_docto.fkg_valida_ie( ev_inscr_est => vv_insc_estadual
                                              , ev_estado    => vv_sigla_estado ), 0) = 0 then
         --
         vn_fase := 11.3;
         --
         gv_mensagem_log := 'A "Inscri��o Estadual do Participante" est� inv�lida (' || vv_insc_estadual || ').';
         --
         vn_loggenerico_id := null;
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => ERRO_DE_VALIDACAO
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
        --
        -- Armazena o "loggenerico_id" na mem�ria
        pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico );
      --
      end if;
      --
   end if;
   --
   vn_fase := 12;
   --
   if nvl(vn_empresa_id,0) <= 0 then
      --
      vn_fase := 12.1;
      --
      gv_mensagem_log := '"Empresa" n�o informada ou inv�lida (' || ev_cpf_cnpj_emit || ').';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 13;
   --
   if nvl(en_dm_ind_emit,-1) not in (0,1) then
      --
      vn_fase := 13.1;
      --
      gv_mensagem_log := '"Indicador do Emitente" inv�lido(' || en_dm_ind_emit || ') .';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 14;
   --
   if nvl(en_dm_ind_oper,-1) not in (0,1) then
      --
      vn_fase := 14.1;
      --
      gv_mensagem_log := '"Indicador da opera��o" inv�lido (' || en_dm_ind_oper || ') .';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 14.2;
   -- Se o cte for de emiss�o de terceiros(1) o indicador de opera��o
   -- obrigat�riamente deve ser de entrada (dm_st_proc = 0)
   if nvl(en_dm_ind_emit, -1 ) = 1 and nvl(en_dm_ind_oper, -1) = 1 then
      --
      vn_fase := 14.3;
      --
      gv_mensagem_log := 'O "Indicador do Tipo de Opera��o" (' || en_dm_ind_oper || ')' ||
                         ' deve ser de Aquisi��o p/ Conhec. Transp. emitidos por Terceiros';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 15;
   --
   if nvl(vn_modfiscal_id,0) <= 0 then
      --
      vn_fase := 15.1;
      --
      gv_mensagem_log := '"Modelo do Documento Fiscal" inv�lido (' || ev_cod_mod || ').';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 15.2;
   -- Registro D100: Orienta��o de Preenchimento do Modelo Documento segundo Manual do Sped Fiscal
   if trim( ev_cod_mod ) not in ('07', '08', '8B', '09', '10', '11', '26', '27', '57', '67') then
      --
      vn_fase := 15.3;
      --
      gv_mensagem_log := 'O "Modelo do Documento Fiscal" est� inv�lido (' || ev_cod_mod || ') para opera��es de Transporte.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 15.4;
   -- Registro D100: Orienta��o de Preenchimento da Situa��o do Documento Fiscal segundo Manual do Sped Fiscal
   if trim( ev_sit_docto ) not in ('00', '01', '02', '03', '06', '07', '08') then
      --
      vn_fase := 15.5;
      --
      gv_mensagem_log := 'A "Situa��o do Documento Fiscal" est� inv�lida (' || ev_sit_docto || ').';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 15.6;
   -- Orienta��o de Preenchimento D100: Para Ct-e (modelo 57) o campo Tipo do Ct-e � obrigat�rio
   -- Alterada a rotina para tratar tb modelo 67
   if trim( ev_cod_mod ) in ('57', '67')
      and nvl(en_dm_tp_cte, -1) not in (0, 1, 2, 3) then
      --
      vn_fase := 15.7;
      --
      gv_mensagem_log := 'O "Tipo de CT-e" est� inv�lido (' || en_dm_tp_cte || ').';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 15.8;
   -- Valida��o D100: A chave do Ct-e quando a emiss�o for pr�pria
   -- Incluido tratamento tb para modelo 67
   if trim(ev_cod_mod) in ('57', '67')
      and length(nvl(trim(ev_nro_chave_cte),0)) <> 44 then
      --
      vn_fase := 15.9;
      --
      vv_cpf_cnpj_emit := pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => vn_pessoa_id );
      --
      vv_nro_chave_cte := PK_CSF_CT.fkg_ret_chave_cte_arm_terc ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit
                                                               , ev_serie         => ev_serie
                                                               , en_nro_ct        => en_nro_nf
                                                               );
      --
      if trim(vv_nro_chave_cte) is null then
         --
         gv_mensagem_log := 'A "A Chave do CT-e" est� inv�lida (' || trim(ev_nro_chave_cte) || ').';
         --
         vn_loggenerico_id := null;
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => ERRO_DE_VALIDACAO
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                              , est_log_generico  => est_log_generico );
         --
      end if;
      --
   else
      --
      vv_nro_chave_cte := ev_nro_chave_cte;
      --
   end if;
   --
   vn_fase := 15.10;
   -- Valida��o D100: A chave do Ct-e j� existe com XML armazenado e est� cancelado
   -- Incluido na rotina tb a verificacao do modelo 67
   if nvl(en_dm_ind_emit,0) = 1 and
      trim(ev_cod_mod) in ('57', '67') and
      length(nvl(trim(ev_nro_chave_cte),0)) = 44 and
      fkg_xml_conhec_transp_chv ( ev_nro_chave_cte => ev_nro_chave_cte ) = true then
      --
      vn_fase := 15.11;
      --
      gv_mensagem_log := 'Atrav�s da Chave do CT-e de terceiro, foi encontrado XML armazenado com situa��o de Cancelamento (chave = '||trim(ev_nro_chave_cte)||').';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 16;
   --
   if nvl(en_nro_nf,0) <= 0 then
      --
      vn_fase := 16.1;
      --
      gv_mensagem_log := '"N�mero" n�o informado ou inv�lido (' || en_nro_nf || ').';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 17;
   --
   if ed_dt_emiss is null then
      --
      vn_fase := 17.1;
      --
      gv_mensagem_log := '"Data de emiss�o" n�o informada.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 18;
   --
   if (nvl(en_vl_doc,0) <= 0 and en_dm_tp_cte in (0, 3)) then
      --
      vn_fase := 18.1;
      --
      gv_mensagem_log := '"Valor do Documento" n�o pode ser zero ou negativo.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 19;
   --
   if nvl(en_vl_desc,0) < 0 then
      --
      vn_fase := 19.1;
      --
      gv_mensagem_log := '"Valor do Desconto" n�o pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 20;
   --
   if nvl(en_dm_ind_frt,-1) not in (0, 1, 2, 9) then
      --
      vn_fase := 20.1;
      --
      gv_mensagem_log := '"Indicador do Frete" inv�lido (' || en_dm_ind_frt || ').';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 21;
   --
   if (nvl(en_vl_serv,0) <= 0 and en_dm_tp_cte in (0, 3)) then
      --
      vn_fase := 21.1;
      --
      gv_mensagem_log := '"Valor da Presta��o do Servi�o" n�o pode ser negativo ou zero (0).';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 22;
   --
   if nvl(en_vl_bc_icms,0) < 0 then
      --
      vn_fase := 22.1;
      --
      gv_mensagem_log := '"Base de C�lculo de ICMS" n�o pode ser negativa.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 23;
   --
   if nvl(en_vl_icms,0) < 0 then
      --
      vn_fase := 23.1;
      --
      gv_mensagem_log := '"Valor de ICMS" n�o pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 24;
   --
   if nvl(en_vl_nt,0) < 0 then
      --
      vn_fase := 24.1;
      --
      gv_mensagem_log := '"Valor de Servi�os n�o Tributados" n�o pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 25;
   --
   if nvl(vn_inforcompdctofiscal_id,0) <= 0 and trim(ev_cod_inf) is not null then
      --
      vn_fase := 25.1;
      --
      gv_mensagem_log := '"C�digo da Informa��o" inv�lido (' || ev_cod_inf || ').';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 26;
   --
   if ed_dt_sai_ent < ed_dt_emiss then
      --
      vn_fase := 26.1;
      --
      gv_mensagem_log := '"Data de Sa�da/Entrada" n�o pode ser menor que a data de emiss�o.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 27;
   -- Busca id do Servi�o e imposto
   vn_ct_vlserv := fkg_conhec_transp_vlprest_id (sn_conhectransp_id);
   vn_ct_imp    := fkg_conhec_transp_imp_id (sn_conhectransp_id);
   --
   vn_fase := 28;
   -- Se informou valor no ev_cod_nat valida a natureza da opera��o
   if trim(ev_cod_nat_oper) is not null then
      --
      vn_fase := 28.1;
      --
      pk_csf.pkb_cria_nat_oper( ev_cod_nat    => ev_cod_nat_oper
                              , en_multorg_id => en_multorg_id );
      --
      vn_fase := 28.2;
      --
      vn_natoper_id := PK_CSF_API_CT.fkg_natoper_id_cod_nat ( en_multorg_id => en_multorg_id
                                                     , ev_cod_nat    => trim(ev_cod_nat_oper) );
      --
   end if;
   --
   vn_fase := 29;
   --
   vn_cfop_id := en_cfop_id; -- Valor default = 1, caso contr�rio vir� do processo de convers�o de CTE - pk_entr_cte_terceiro
   vn_cd_cfop := pk_csf.fkg_cfop_cd(en_cfop_id); -- Valor default = 1000, caso contr�rio vir� do processo de convers�o de CTE - pk_entr_cte_terceiro
   --
   vn_fase := 30;
   --
   if trim(pk_csf.fkg_converte(ev_cd_unid_org)) is not null then
      --
      vn_fase := 30.1;
      --
      vn_unidorg_id := pk_csf.fkg_unig_org_id ( en_empresa_id   => vn_empresa_id
                                              , ev_cod_unid_org => trim(ev_cd_unid_org) );
      --
      -- Valida se o Codigo do Sistema de Origem
      if trim(pk_csf.fkg_converte(ev_cd_unid_org)) is not null
         and nvl(vn_unidorg_id, 0) = 0 then
         --
         vn_fase := 30.2;
         --
         gv_mensagem_log := null;
         --
         gv_mensagem_log := '"A Unidade Organizacional" ('
                         || ev_cd_unid_org || ') esta invalida ou nao esta cadastrada no sistema.';
         --
         vn_loggenerico_id := null;
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => ERRO_DE_VALIDACAO
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                              , est_log_generico  => est_log_generico ); 
         --
      end if;
      --
   end if;
   ---   
   vn_fase := 31;
   --
   -- Conhecimento de Transporte
   if fkg_existe_conhec_transp_id ( en_conhectransp_id => sn_conhectransp_id ) = true then
      --
      vn_fase := 31.1;
      --  Atualiza Cabe�alho do conhecimento de Transporte
      update conhec_transp set dt_hr_ent_sist            = sysdate
                             , empresa_id                = vn_empresa_id
                             , lotecte_id                = null
                             , inutilizaconhectransp_id  = null
                             , pessoa_id                 = vn_pessoa_id
                             , sitdocto_id               = vn_sitdocto_id
                             , versao                    = null
                             , id_tag_cte                = null
                             , uf_ibge_emit              = 0
                             , cct_cte                   = null
                             , cfop                      = vn_cd_cfop -- '1000'
                             , cfop_id                   = vn_cfop_id -- 1
                             , nat_oper                  = nvl(trim(ev_cod_nat_oper), 'Integracao de CT')
                             , dm_for_pag                = nvl(dm_for_pag,2)
                             , modfiscal_id              = vn_modfiscal_id
                             , serie                     = ev_serie
                             , subserie                  = ev_subserie
                             , nro_ct                    = en_nro_nf
                             , dt_hr_emissao             = ed_dt_emiss
                             , dm_tp_imp                 = 1
                             , dm_forma_emiss            = 1
                             , dig_verif_chave           = null
                             , nro_chave_cte             = vv_nro_chave_cte
                             , dm_tp_amb                 = 1
                             , dm_tp_cte                 = nvl(en_dm_tp_cte,1)
                             , dm_proc_emiss             = 0
                             , vers_apl_cte              = '1'
                             , chave_cte_ref             = ev_chave_cte_ref
                             , ibge_cidade_emit          = 0
                             , descr_cidade_emit         = 'XX'
                             , sigla_uf_emit             = 'XX'
                             , dm_modal                  = nvl(ev_dm_modal,'01') -- Antigo default '01'
                             , dm_tp_serv                = nvl(en_dm_tp_serv,0)  -- Antigo default 0
                             , ibge_cidade_ini           = nvl(en_ibge_cidade_ini,0)
                             , descr_cidade_ini          = nvl(ev_descr_cidade_ini,'XX')
                             , sigla_uf_ini              = nvl(ev_sigla_uf_ini,'XX')
                             , ibge_cidade_fim           = nvl(en_ibge_cidade_fim,0)
                             , descr_cidade_fim          = nvl(ev_descr_cidade_fim,'XX')
                             , sigla_uf_fim              = nvl(ev_sigla_uf_fim,'XX')
                             , dm_retira                 = 0
                             , det_retira                = null
                             , dm_tomador                = 0
                             , inf_adic_fisco            = null
                             , dm_st_proc                = 4
                             , dt_st_proc                = sysdate
                             , dm_impressa               = 1
                             , dm_st_email               = 1
                             , dm_st_integra             = 0
                             , dm_aut_sefaz              = 1
                             , dt_aut_sefaz              = sysdate
                             , id_usuario_erp            = null
                             , usuario_id                = null
                             , impressora_id             = null
                             , vias_dacte_custom         = null
                             , nro_tentativas_impr       = null
                             , dt_ult_tenta_impr         = null
                             , vers_apl                  = null
                             , dt_hr_recbto              = null
                             , nro_protocolo             = null
                             , digest_value              = null
                             , msgwebserv_id             = null
                             , cod_msg                   = null
                             , motivo_resp               = null
                             , cte_proc_xml              = null
                             , dm_ind_oper               = en_dm_ind_oper
                             , dm_ind_emit               = en_dm_ind_emit
                             , dm_ind_frt                = en_dm_ind_frt
                             , inforcompdctofiscal_id    = vn_inforcompdctofiscal_id
                             , cod_cta                   = ev_cod_cta
                             , dt_sai_ent                = ed_dt_sai_ent
                             , natoper_id                = vn_natoper_id
                             , unidorg_id                = nvl(vn_unidorg_id,null)
       where id = sn_conhectransp_id;
      --
      -- Atualiza forma de emissao     
      vn_dm_forma_emiss := trim( substr(vv_nro_chave_cte, 35, 1) );
      --
   else
      --
      vn_fase := 31.2;
      -- insere os dados
      insert into conhec_transp ( id
                                , dt_hr_ent_sist
                                , empresa_id
                                , lotecte_id
                                , inutilizaconhectransp_id
                                , pessoa_id
                                , sitdocto_id
                                , versao
                                , id_tag_cte
                                , uf_ibge_emit
                                , cct_cte
                                , cfop
                                , cfop_id
                                , nat_oper
                                , dm_for_pag
                                , modfiscal_id
                                , serie
                                , subserie
                                , nro_ct
                                , dt_hr_emissao
                                , dm_tp_imp
                                , dm_forma_emiss
                                , dig_verif_chave
                                , nro_chave_cte
                                , dm_tp_amb
                                , dm_tp_cte
                                , dm_proc_emiss
                                , vers_apl_cte
                                , chave_cte_ref
                                , ibge_cidade_emit
                                , descr_cidade_emit
                                , sigla_uf_emit
                                , dm_modal
                                , dm_tp_serv
                                , ibge_cidade_ini
                                , descr_cidade_ini
                                , sigla_uf_ini
                                , ibge_cidade_fim
                                , descr_cidade_fim
                                , sigla_uf_fim
                                , dm_retira
                                , det_retira
                                , dm_tomador
                                , inf_adic_fisco
                                , dm_st_proc
                                , dt_st_proc
                                , dm_impressa
                                , dm_st_email
                                , dm_st_integra
                                , dm_aut_sefaz
                                , dt_aut_sefaz
                                , id_usuario_erp
                                , usuario_id
                                , impressora_id
                                , vias_dacte_custom
                                , nro_tentativas_impr
                                , dt_ult_tenta_impr
                                , vers_apl
                                , dt_hr_recbto
                                , nro_protocolo
                                , digest_value
                                , msgwebserv_id
                                , cod_msg
                                , motivo_resp
                                , cte_proc_xml
                                , dm_ind_oper
                                , dm_ind_emit
                                , dm_ind_frt
                                , inforcompdctofiscal_id
                                , cod_cta
                                , dt_sai_ent
                                , natoper_id
                                , unidorg_id
                                )
                         values ( sn_conhectransp_id            -- id
                                , sysdate                       -- dt_hr_ent_sist
                                , vn_empresa_id                 -- empresa_id
                                , null                          -- lotecte_id
                                , null                          -- inutilizaconhectransp_id
                                , vn_pessoa_id                  -- pessoa_id
                                , vn_sitdocto_id                -- sitdocto_id
                                , null                          -- versao
                                , null                          -- id_tag_cte
                                , 0                             -- uf_ibge_emit
                                , null                          -- cct_cte
                                , vn_cd_cfop                    -- cfop -- '1000'
                                , vn_cfop_id                    -- cfop_id -- 1
                                , nvl(trim(ev_cod_nat_oper),'Integracao de CT') -- nat_oper
                                , 2                             -- dm_for_pag
                                , vn_modfiscal_id               -- modfiscal_id
                                , ev_serie                      -- serie
                                , ev_subserie                   -- subserie
                                , en_nro_nf                     -- nro_ct
                                , ed_dt_emiss                   -- dt_hr_emissao
                                , 1                             -- dm_tp_imp -- 1-Retrato, 2-Paisagem
                                , 1                             -- dm_forma_emiss -- 1-Normal, 2-Conting�ncia, 3-Conting�ncia SCAN - Inativado, 4-Conting�ncia DPEC/EPEC, 5-Conting�ncia FSDA, 6-Conting�ncia SVC-AN, 7-Autoriza��o pela SVC-RS, 8-Autoriza��o pela SVC-SP
                                , null                          -- dig_verif_chave
                                , vv_nro_chave_cte              -- nro_chave_cte
                                , 1                             -- dm_tp_amb -- 1-Produ��o, 2-Homologa��o
                                , nvl(en_dm_tp_cte,1)           -- dm_tp_cte
                                , 0                             -- dm_proc_emiss
                                , '1'                           -- vers_apl_cte
                                , ev_chave_cte_ref              -- chave_cte_ref
                                , 0                             -- ibge_cidade_emit
                                , 'XX'                          -- descr_cidade_emit
                                , 'XX'                          -- sigla_uf_emit
                                , nvl(ev_dm_modal,'01')         -- dm_modal    -- Antigo default '01'
                                , nvl(en_dm_tp_serv,0)          -- dm_tp_serv  -- Antigo default 0
                                , nvl(en_ibge_cidade_ini,0)     -- ibge_cidade_ini
                                , nvl(ev_descr_cidade_ini,'XX') -- descr_cidade_ini
                                , nvl(ev_sigla_uf_ini,'XX')     -- sigla_uf_ini
                                , nvl(en_ibge_cidade_fim,0)     -- ibge_cidade_fim
                                , nvl(ev_descr_cidade_fim,'XX') -- descr_cidade_fim
                                , nvl(ev_sigla_uf_fim,'XX')     -- sigla_uf_fim
                                , 0                             -- dm_retira
                                , null                          -- det_retira
                                , 0                             -- dm_tomador
                                , null                          -- inf_adic_fisco
                                , 4                             -- dm_st_proc
                                , sysdate                       -- dt_st_proc
                                , 1                             -- dm_impressa
                                , 1                             -- dm_st_email
                                , 0                             -- dm_st_integra
                                , 1                             -- dm_aut_sefaz
                                , sysdate                       -- dt_aut_sefaz
                                , null                          -- id_usuario_erp
                                , null                          -- usuario_id
                                , null                          -- impressora_id
                                , null                          -- vias_dacte_custom
                                , null                          -- nro_tentativas_impr
                                , null                          -- dt_ult_tenta_impr
                                , null                          -- vers_apl
                                , null                          -- dt_hr_recbto
                                , null                          -- nro_protocolo
                                , null                          -- digest_value
                                , null                          -- msgwebserv_id
                                , null                          -- cod_msg
                                , null                          -- motivo_resp
                                , null                          -- cte_proc_xml
                                , en_dm_ind_oper                -- dm_ind_oper
                                , en_dm_ind_emit                -- dm_ind_emit
                                , en_dm_ind_frt                 -- dm_ind_frt
                                , vn_inforcompdctofiscal_id     -- inforcompdctofiscal_id
                                , ev_cod_cta                    -- cod_cta
                                , ed_dt_sai_ent                 -- dt_sai_ent
                                , vn_natoper_id                 -- natoper_id
                                , nvl(vn_unidorg_id,null)       -- unidorg_id
                                );
      --
      -- atualiza forma de emissao
      vn_dm_forma_emiss := trim( substr(vv_nro_chave_cte, 35, 1) );
      --   
   end if;
   --
   -- Valida a Chave de acesso do CTE
   --
   vn_fase := 32;
   --
   -- Verifica se o campo � validado para o tipo de conhecimento de transporte
   vn_valida := pk_csf_ct.fkg_ret_valid_integr ( en_conhectransp_id => null
                                               , en_dm_ind_emit     => en_dm_ind_emit
                                               , en_dm_legado       => null
                                               , en_dm_forma_emiss  => vn_dm_forma_emiss
                                               , ev_campo           => 'NRO_CHAVE_CTE'                                               
                                               );
   --
   if nvl(vn_valida,0) in (0,1) then
      --
      -- Verifica se a chave foi informada pelo ERP
      if trim(vv_nro_chave_cte) is not null then
         --
         -- Valida se a informa��o da Chave est� correta
         pk_csf_api_ct.pkb_valida_chave_acesso(est_log_generico   => vt_log_generico,
                                               ev_nro_chave_cte   => vv_nro_chave_cte,
                                               en_empresa_id      => vn_empresa_id,
                                               en_pessoa_id       => vn_pessoa_id,
                                               en_dm_ind_emit     => en_dm_ind_emit,
                                               ed_dt_hr_emissao   => trunc(ed_dt_emiss),
                                               ev_cod_mod         => ev_cod_mod,
                                               en_serie           => ev_serie,
                                               en_nro_ct          => en_nro_nf,
                                               en_dm_forma_emiss  => 1,
                                               sn_cCT_cte         => vv_dummy,
                                               sn_dig_verif_chave => vv_dummy,
                                               sn_qtde_erro       => vn_qtde_erro_chave);
         --
         if nvl(vn_qtde_erro_chave,0) > 0 then
            --
            gv_mensagem_log := 'A "Chave do CT-e" est� inv�lida (' || trim(vv_nro_chave_cte) || ').'||
                               'Erro Retornado: '|| pk_csf_api_ct.gv_mensagem_log;
            --
            vn_loggenerico_id := null;
            --
            pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                              , ev_mensagem        => gv_cabec_log
                                              , ev_resumo          => gv_mensagem_log
                                              , en_tipo_log        => ERRO_DE_VALIDACAO
                                              , en_referencia_id   => gn_referencia_id
                                              , ev_obj_referencia  => gv_obj_referencia
                                              );
            --
            -- Armazena o "loggenerico_id" na mem�ria
            pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                                 , est_log_generico  => est_log_generico
                                                 );
         --
         end if;
         --
      end if;
      --
   end if;
   --
   -- C�lcula a quantidade de registros Totais integrados para ser
   -- mostrado na tela de agendamento.
   --
   begin
      pk_agend_integr.gvtn_qtd_total(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj),0) + 1;
   exception
      when others then
      null;
   end;
   --
   vn_fase := 33;
   -- Tabelas Filhas
   if nvl(vn_ct_vlserv, 0) > 0 then
      --
      vn_fase := 33.1;
      -- Atualiza Servi�os Prestados
      update conhec_transp_vlprest
         set vl_prest_serv    =  nvl(en_vl_serv,0)
           , vl_receb         =  0
           , vl_docto_fiscal  =  nvl(en_vl_doc,0)
           , vl_desc          =  nvl(en_vl_desc,0)
       where id = vn_ct_vlserv;
     --
   else
      --
      vn_fase := 34.2;
      -- Insere os dados do valor da presta��o de servi�o
      insert into conhec_transp_vlprest ( id
                                        , conhectransp_id
                                        , vl_prest_serv
                                        , vl_receb
                                        , vl_docto_fiscal
                                        , vl_desc )
                                 values ( conhectranspvlprest_seq.nextval
                                        , sn_conhectransp_id
                                        , nvl(en_vl_serv,0)
                                        , 0
                                        , nvl(en_vl_doc,0)
                                        , nvl(en_vl_desc,0) );
      --
   end if;
   --
   vn_fase := 35;
   --
   if nvl(vn_ct_imp, 0) > 0 then
      --
      vn_fase := 35.1;
      --  Atualiza o valorres de impostos
      update conhec_transp_imp
         set tipoimp_id   =  pk_csf.fkg_Tipo_Imposto_id ( 1 )
           , codst_id     =  codst_id                 -- Mantive o mesmo
           , vl_base_calc =  nvl(en_vl_bc_icms, 0)
           , aliq_apli    =  aliq_apli                -- Mantive o mesmo
           , vl_imp_trib  =  nvl(en_vl_icms, 0)
           , perc_reduc   =  perc_reduc               -- Mantive o mesmo
           , vl_cred      =  vl_cred                  -- Mantive o mesmo
       where id = vn_ct_imp;
     --
   else
      --
      vn_fase := 35.2;
      --
      if nvl(en_vl_icms,0) > 0 then
         --
         vn_fase := 35.3;
         --
         insert into conhec_transp_imp ( id
                                       , conhectransp_id
                                       , tipoimp_id
                                       , codst_id
                                       , vl_base_calc
                                       , aliq_apli
                                       , vl_imp_trib
                                       , perc_reduc
                                       , vl_cred )
                                values ( conhectranspimp_seq.nextval
                                       , sn_conhectransp_id
                                       , pk_csf.fkg_Tipo_Imposto_id ( 1 )
                                       , pk_csf.fkg_Cod_ST_id ( '00', pk_csf.fkg_Tipo_Imposto_id ( 1 ) )
                                       , nvl(en_vl_bc_icms,0)
                                       , 0
                                       , nvl(en_vl_icms,0)
                                       , null
                                       , null );
         --
      else
         --
         vn_fase := 35.4;
         --
         insert into conhec_transp_imp ( id
                                       , conhectransp_id
                                       , tipoimp_id
                                       , codst_id
                                       , vl_base_calc
                                       , aliq_apli
                                       , vl_imp_trib
                                       , perc_reduc
                                       , vl_cred )
                                values ( conhectranspimp_seq.nextval
                                       , sn_conhectransp_id
                                       , pk_csf.fkg_Tipo_Imposto_id ( 1 )
                                       , pk_csf.fkg_Cod_ST_id ( '41', pk_csf.fkg_Tipo_Imposto_id ( 1 ) )
                                       , nvl(en_vl_bc_icms,0)
                                       , 0
                                       , nvl(en_vl_icms,0)
                                       , null
                                       , null );
         --
      end if;
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_d100.pkb_integr_ct_d100 fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_mensagem_log
                                           , ev_resumo          => null
                                           , en_tipo_log        => ERRO_DE_SISTEMA
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_ct_d100;

------------------------------------------------------------------------------------
-- Integra as informa��es do emitente da Nota Fiscal quando emitida por terceiros --
------------------------------------------------------------------------------------
PROCEDURE PKB_REG_PESSOA_EMIT_CT ( EST_LOG_GENERICO_CT       IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                                 , ET_ROW_CONHEC_TRANSP_EMIT IN OUT NOCOPY CONHEC_TRANSP_EMIT%ROWTYPE
                                 , EV_COD_PART               IN            PESSOA.COD_PART%TYPE ) IS
   --
   vt_log_generico_ct  dbms_sql.number_table;
   vn_dm_atual_part    empresa.dm_atual_part%type;
   vn_fase             number := null;
   vv_cod_part         pessoa.cod_part%type;
   vn_dm_tipo_incl     pessoa.dm_tipo_incl%type;
   vn_multorg_id       empresa.multorg_id%type;
   vn_pessoa_id        pessoa.id%type;
   vv_cpf_cnpj         varchar2(14);
   --
BEGIN
   --
   vt_log_generico_ct.delete;
   --
   vn_fase := 1;
   -- verifica se a empresa que emitiu a nota atualiza o cadastro do participante
   -- somente para notas de emitidas por Terceiro
   begin
      --
      select em.dm_atual_part
           , em.multorg_id
        into vn_dm_atual_part
           , vn_multorg_id
        from empresa em
       where em.id = gt_row_conhec_transp.empresa_id;
      --
   exception
      when others then
         vn_dm_atual_part := 0;
   end;
   --
   vn_fase := 2;
   --
   if nvl(vn_dm_atual_part,0) = 1
      and gt_row_conhec_transp.dm_ind_emit = 1
      then
      --
      vn_fase := 3;
      --
      vv_cod_part := trim(ev_cod_part);
      --
      if trim(vv_cod_part) is null then
         --
         if trim(et_row_Conhec_Transp_Emit.cnpj) is not null then
            --
            vv_cod_part := et_row_Conhec_Transp_Emit.uf || trim(et_row_Conhec_Transp_Emit.cnpj);
            --
         else
            --
            vv_cod_part := et_row_Conhec_Transp_Emit.conhectransp_id;
            --
         end if;
         --
      else
         --
         vn_pessoa_id := pk_csf.fkg_pessoa_id_cod_part ( en_multorg_id  => vn_multorg_id
                                                       , ev_cod_part    => vv_cod_part
                                                       );
         --
         vv_cpf_cnpj := trim(pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => vn_pessoa_id ));
         --
         if length(vv_cpf_cnpj) = 14 then
            et_row_Conhec_Transp_Emit.cnpj := vv_cpf_cnpj;
         end if;
         --
      end if;
      --
      if trim(vv_cod_part) is not null then
         --
         vn_fase := 4;
         --
         pk_csf_api_cad.gt_row_pessoa := null;
         --
         vn_fase := 4.1;
         --
         pk_csf_api_cad.gt_row_pessoa.dm_tipo_incl  := 1; -- Externo, cadastrado na importa��o dos dados
         pk_csf_api_cad.gt_row_pessoa.cod_part      := vv_cod_part;
         pk_csf_api_cad.gt_row_pessoa.nome          := et_row_Conhec_Transp_Emit.nome;
         pk_csf_api_cad.gt_row_pessoa.fantasia      := et_row_Conhec_Transp_Emit.nome_fant;
         pk_csf_api_cad.gt_row_pessoa.lograd        := et_row_Conhec_Transp_Emit.lograd;
         pk_csf_api_cad.gt_row_pessoa.nro           := et_row_Conhec_Transp_Emit.nro;
         pk_csf_api_cad.gt_row_pessoa.cx_postal     := null;
         pk_csf_api_cad.gt_row_pessoa.compl         := et_row_Conhec_Transp_Emit.compl;
         pk_csf_api_cad.gt_row_pessoa.bairro        := et_row_Conhec_Transp_Emit.bairro;
         --
         vn_fase := 4.2;
         --
         if nvl(et_row_Conhec_Transp_Emit.ibge_cidade,0) > 0 then
            pk_csf_api_cad.gt_row_pessoa.cidade_id     := pk_csf.fkg_Cidade_ibge_id ( ev_ibge_cidade => et_row_Conhec_Transp_Emit.ibge_cidade );
         else
            pk_csf_api_cad.gt_row_pessoa.cidade_id     := pk_csf.fkg_Cidade_ibge_id ( ev_ibge_cidade => 9999999 );
         end if;
         --
         pk_csf_api_cad.gt_row_pessoa.cep           := et_row_Conhec_Transp_Emit.cep;
         pk_csf_api_cad.gt_row_pessoa.fone          := et_row_Conhec_Transp_Emit.fone;
         pk_csf_api_cad.gt_row_pessoa.fax           := null;
         --
         vn_fase := 4.3;
         --
         pk_csf_api_cad.gt_row_pessoa.pais_id       := pk_csf.fkg_Pais_siscomex_id ( ev_cod_siscomex => 1058 );
         pk_csf_api_cad.gt_row_pessoa.multorg_id    := vn_multorg_id;
         --
         vn_fase := 4.4;
         --
         -- Sendo Emiss�o de Terceiro, sempre atribui Juridica
         pk_csf_api_cad.gt_row_pessoa.dm_tipo_pessoa := 1; -- JURIDICA
         --
         vn_fase := 4.5;
         --
         -- Procura pelo CPF/CNPJ
         if nvl(pk_csf_api_cad.gt_row_pessoa.id,0) <= 0 then
            --
            vn_fase := 4.6;
            -- Verifica se existe o participante no Compliance NFe (procura pelo C�digo do participante e se n�o achar, pelo CPF/CNPJ)
            pk_csf_api_cad.gt_row_pessoa.id := pk_csf.fkg_pessoa_id_cod_part ( en_multorg_id => vn_multorg_id
                                                                             , ev_cod_part   => ev_cod_part );
            --
            if nvl(pk_csf_api_cad.gt_row_pessoa.id,0) <= 0 then
               --
               if trim(et_row_Conhec_Transp_Emit.cnpj) is not null then
                  --
                  vn_fase := 4.7;
                  pk_csf_api_cad.gt_row_pessoa.id := pk_csf.fkg_pessoa_id_cpf_cnpj_uf ( en_multorg_id => vn_multorg_id
                                                                                      , en_cpf_cnpj   => trim(et_row_Conhec_Transp_Emit.cnpj)
                                                                                      , ev_uf         => trim(et_row_Conhec_Transp_Emit.uf)
                                                                                      );
                  --               
               end if;
               --
            end if;
            --
         end if;
         --
         if nvl(pk_csf_api_cad.gt_row_pessoa.id,0) > 0 then
            --
            vn_dm_tipo_incl := pk_csf.fkg_pessoa_id_dm_tipo_incl ( en_pessoa_id => pk_csf_api_cad.gt_row_pessoa.id );
            --
         else
            vn_dm_tipo_incl := 1;
         end if;
         --
         vn_fase := 4.8;
         -- Somente atualiza pessoas incluidas por meio de integra��o
         if vn_dm_tipo_incl = 1 then
            -- Valida se o participante n�o est� cadastrado como empresa
            if pk_csf.fkg_valida_part_empresa ( en_multorg_id => pk_csf_api_cad.gt_row_pessoa.multorg_id
                                              , ev_cod_part   => pk_csf_api_cad.gt_row_pessoa.cod_part ) = FALSE then
               -- chama procedimento de resgitro da pessoa
               pk_csf_api_cad.pkb_ins_atual_pessoa ( est_log_generico => vt_log_generico_ct
                                                   , est_pessoa       => pk_csf_api_cad.gt_row_pessoa
                                                   , en_empresa_id    => gt_row_conhec_transp.empresa_id
                                                   );
               --
            end if;
            --
            vn_fase := 4.9;
            --
            if nvl(pk_csf_api_cad.gt_row_pessoa.id,0) > 0 then
               --
               vn_fase := 5;
               -- Faz o Registro de pessoa 
               if pk_csf_api_cad.gt_row_pessoa.dm_tipo_pessoa = 1 then -- Jur�dica
                  --
                  vn_fase := 7;
                  --
                  pk_csf_api_cad.gt_row_juridica := null;
                  --
                  pk_csf_api_cad.gt_row_juridica.pessoa_id     := pk_csf_api_cad.gt_row_pessoa.id;
                  --
                  vn_fase := 7.1;
                  --
                  begin
                     --
                     pk_csf_api_cad.gt_row_juridica.num_cnpj      := to_number(substr(et_row_Conhec_Transp_Emit.cnpj, 1, 8));
                     pk_csf_api_cad.gt_row_juridica.num_filial    := to_number(substr(et_row_Conhec_Transp_Emit.cnpj, 9, 4));
                     pk_csf_api_cad.gt_row_juridica.dig_cnpj      := to_number(substr(et_row_Conhec_Transp_Emit.cnpj, 13, 2));
                     --
                  exception
                     when others then
                        --
                        gv_mensagem_log := 'Erro inconsist�ncia no CNPJ do emitente da NFe (fase: '||vn_fase||' - pkb_reg_pessoa_emit_nf): '||sqlerrm;
                        --
                        declare
                           vn_loggenerico_id  log_generico_nf.id%type;
                        begin
                           pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id   => vn_loggenerico_id
                                                             , ev_mensagem         => gv_cabec_log
                                                             , ev_resumo           => gv_mensagem_log
                                                             , en_tipo_log         => erro_de_validacao
                                                             , en_referencia_id    => gn_referencia_id
                                                             , ev_obj_referencia   => gv_obj_referencia );
                           -- Armazena o "loggenerico_id" na mem�ria
                           pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico => vn_loggenerico_id
                                                                , est_log_generico  => est_log_generico_ct );
                        exception
                           when others then
                              null;
                        end;
                        --
                  end;
                  --
                  vn_fase := 7.2;
                  --
                  pk_csf_api_cad.gt_row_juridica.ie            := et_row_Conhec_Transp_Emit.ie;
                  pk_csf_api_cad.gt_row_juridica.iest          := null;
                  pk_csf_api_cad.gt_row_juridica.im            := null;
                  pk_csf_api_cad.gt_row_juridica.cnae          := null;
                  pk_csf_api_cad.gt_row_juridica.suframa       := null;
                  pk_csf_api_cad.gt_row_juridica.codentref_id  := null;
                  pk_csf_api_cad.gt_row_juridica.nire          := null;
                  pk_csf_api_cad.gt_row_juridica.dt_arq        := null;
                  pk_csf_api_cad.gt_row_juridica.dt_arq_conv   := null;
                  --
                  vn_fase := 7.3;
                  --
                  pk_csf_api_cad.pkb_ins_atual_juridica ( est_log_generico => vt_log_generico_ct
                                                        , est_juridica     => pk_csf_api_cad.gt_row_juridica
                                                        , en_empresa_id    => gt_row_conhec_transp.empresa_id
                                                        );
                  --
               end if;
               --
            end if;
            --
         end if;
         --
      end if;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_reg_pessoa_emit_ct fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%type;
      begin
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id   => vn_loggenerico_id
                                           , ev_mensagem         => gv_cabec_log
                                           , ev_resumo           => gv_mensagem_log
                                           , en_tipo_log         => erro_de_validacao
                                           , en_referencia_id    => gn_referencia_id
                                           , ev_obj_referencia   => gv_obj_referencia );
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico      => vn_loggenerico_id
                                              , est_log_generico    => est_log_generico_ct );
      exception
         when others then
            null;
      end;
      --
END PKB_REG_PESSOA_EMIT_CT;

-------------------------------------------------------------------------------------------------------

-- Procedimento Integra as Informa��es relativas do Emitente do CT.
procedure pkb_integr_conhec_transp_emit ( est_log_generico           in out nocopy dbms_sql.number_table
                                        , est_row_conhec_transp_emit in out nocopy Conhec_Transp_Emit%rowtype
                                        , en_conhectransp_id         in            Conhec_Transp.id%TYPE
                                        , ev_cod_part                in            pessoa.cod_part%TYPE )
is
   --
   vn_fase           number := 0;
   vn_loggenerico_id log_generico_ct.id%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf_ct.fkg_cte_nao_integrar ( en_conhectransp_id => en_conhectransp_id ) then
      --
      goto sair_integr;
      --
   end if;
   --
   vn_fase := 1.1;
   --
   if nvl(est_row_conhec_transp_emit.conhectransp_id,0) = 0
      and nvl(est_log_generico.count,0) = 0 then
      --
      vn_fase := 1.2;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'N�o informado o Conhec. Transp. para registro do Emitente';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_SISTEMA
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 2;
   -- Valida se o o tamanho do campo CNPJ caso ele seja informado.
   --
   if trim(pk_csf.fkg_converte(est_row_conhec_transp_emit.cnpj)) is null then
      --
      vn_fase := 2.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'O "N�mero do CNPJ" do Emitente n�o informado.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   --
   vn_fase := 2.2;
   -- Valida o CNPJ do emitente.
   --
   if nvl(pk_valida_docto.fkg_valida_cpf_cgc(ev_numero => est_row_conhec_transp_emit.cnpj), 0) = 0 then
      --
      vn_fase := 2.3;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'O "N�mero do CNPJ" do Emitente (' || est_row_conhec_transp_emit.cnpj || ') est� inv�lido.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 3;
   -- Valida se o campo Inscri��o Estadual.
   est_row_conhec_transp_emit.ie := trim ( replace(replace(replace(replace(replace(upper(est_row_conhec_transp_emit.ie), ' ', ''), '.', ''), '-', ''), '/', ''), ',', '') );
   --
   if nvl(length(trim(pk_csf.fkg_converte(est_row_conhec_transp_emit.ie))), 0) not between 2 and 14 then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'A "Inscri��o Estadual" do Emitente (' || est_row_conhec_transp_emit.ie || ') est� inv�lida.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   if trim(est_row_conhec_transp_emit.ie) like 'ISENT%' then
      --
      gv_mensagem_log := 'A "Inscri��o Estadual" do Emitente n�o pode ser (' || est_row_conhec_transp_emit.ie || ').';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 3.2;
   -- Valida o campo Inscri��o Estadual.
   --
   if trim(est_row_conhec_transp_emit.uf) is not null
      and nvl(pk_valida_docto.fkg_valida_ie( ev_inscr_est => est_row_conhec_transp_emit.ie
                                           , ev_estado    => est_row_conhec_transp_emit.uf ), 0) = 0 then
      --
      vn_fase := 3.3;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'A "Inscri��o Estadual" do Emitente (' || est_row_conhec_transp_emit.ie || ') est� inv�lida.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 4;
   -- Valida se o campo Raz�o Social ou Nome est� nulo.
   --
   if trim(pk_csf.fkg_converte(est_row_conhec_transp_emit.nome)) is null then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'A "Raz�o Social ou Nome" do Emitente n�o foi informada.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 5;
   -- Valida se o campo Logradouro est� nulo.
   --
   if trim(pk_csf.fkg_converte(est_row_conhec_transp_emit.lograd)) is null then
      --
      vn_fase := 5.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'O "Logradouro" do Emitente n�o foi informado.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 6;
   -- Valida se o campo N�mero do Logradouro est� nulo.
   --
   if trim(pk_csf.fkg_converte(est_row_conhec_transp_emit.nro)) is null then
      --
      vn_fase := 6.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'O "N�mero do Logradouro" do Emitente n�o foi informado.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 7;
   -- Valida se o campo Bairro est� nulo.
   --
   if trim(pk_csf.fkg_converte(est_row_conhec_transp_emit.bairro)) is null then
      --
      vn_fase := 7.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'O "Bairro" do Emitente n�o foi informado.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 8;
   -- Valida se o campo C�digo do munic�pio.
   --
   if pk_csf.fkg_ibge_cidade ( ev_ibge_cidade  => est_row_conhec_transp_emit.ibge_cidade ) = False then
      --
      vn_fase := 8.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'O "C�digo do munic�pio" do Emitente (' || est_row_conhec_transp_emit.ibge_cidade || ') est� inv�lido.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 9;
   -- Valida se o campo C�digo do munic�pio est� nulo.
   --
   if nvl(est_row_conhec_transp_emit.ibge_cidade, -1) < 0 then
      --
      vn_fase := 9.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'O "C�digo do munic�pio" do Emitente n�o foi informado.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 10;
   -- Valida se o campo Descri��o do munic�pio est� nulo.
   --
   if trim(pk_csf.fkg_converte(est_row_conhec_transp_emit.descr_cidade)) is null then
      --
      vn_fase := 10.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'O "Nome do munic�pio" do Emitente n�o foi informado.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 11;
   -- Valida se o campo Sigla da UF est� nulo.
   --
   if trim(pk_csf.fkg_converte(est_row_conhec_transp_emit.uf)) is null then
      --
      vn_fase := 11.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'A "Sigla da UF" do Emitente n�o foi informada.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 12;
   -- Valida se o campo Sigla da UF existe.
   --
   if pk_csf.fkg_uf_valida ( ev_sigla_estado  => est_row_conhec_transp_emit.uf ) = False then
      --
      vn_fase := 12.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'A "Sigla da UF" do Emitente (' || est_row_conhec_transp_emit.uf || ') est� inv�lida.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 13;
   -- Valida se o campo C�digo do Pa�s existe caso ele seja informado.
   --
   if est_row_conhec_transp_emit.cod_pais >= 0
      and pk_csf.fkg_codpais_siscomex_valido ( en_cod_siscomex  => est_row_conhec_transp_emit.cod_pais ) = False then
      --
      vn_fase := 13.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'O "C�digo do Pa�s" do Emitente (' || est_row_conhec_transp_emit.cod_pais || ') est� inv�lido.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 14;
   -- Valida indicador do Simples Nacional
   if nvl(est_row_conhec_transp_emit.dm_ind_sn,0) not in (0, 1) then
      --
      vn_fase := 14.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'O "Indicador do Simples Nacional" do Emitente (' || est_row_conhec_transp_emit.dm_ind_sn || ') est� inv�lido.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   -- Se n�o foi encontrado erro e o Tipo de Integra��o � 1 (V�lida e insere)
   -- ent�o realiza a condi��o de inserir o imposto
   if nvl(est_log_generico.count,0) > 0 and 
      pk_csf_api_ct.fkg_ver_erro_log_generico_ct( en_conhec_transp_id => est_row_conhec_transp_emit.conhectransp_id ) = 1  then
      --
      vn_fase := 99.1;
      --
      update conhec_transp set dm_st_proc = 10
       where id = est_row_conhec_transp_emit.conhectransp_id;

      --
   end if;
   --
   vn_fase := 99.2;
   --
   est_row_conhec_transp_emit.cnpj          := trim(pk_csf.fkg_converte(est_row_conhec_transp_emit.cnpj));
   est_row_conhec_transp_emit.nome          := trim(pk_csf.fkg_converte(est_row_conhec_transp_emit.nome));
   est_row_conhec_transp_emit.nome_fant     := trim(pk_csf.fkg_converte(est_row_conhec_transp_emit.nome_fant));
   est_row_conhec_transp_emit.lograd        := trim(pk_csf.fkg_converte(est_row_conhec_transp_emit.lograd));
   est_row_conhec_transp_emit.nro           := trim(pk_csf.fkg_converte(est_row_conhec_transp_emit.nro));
   est_row_conhec_transp_emit.compl         := trim(pk_csf.fkg_converte(est_row_conhec_transp_emit.compl));
   est_row_conhec_transp_emit.bairro        := trim(pk_csf.fkg_converte(est_row_conhec_transp_emit.bairro));
   est_row_conhec_transp_emit.ibge_cidade   := nvl(est_row_conhec_transp_emit.ibge_cidade, 0);
   est_row_conhec_transp_emit.descr_cidade  := trim(pk_csf.fkg_converte(est_row_conhec_transp_emit.descr_cidade));
   est_row_conhec_transp_emit.cep           := lpad(trim(pk_csf.fkg_converte(est_row_conhec_transp_emit.cep)), 8, '0');
   est_row_conhec_transp_emit.uf            := trim(pk_csf.fkg_converte(est_row_conhec_transp_emit.uf));
   est_row_conhec_transp_emit.descr_pais    := trim(pk_csf.fkg_converte(est_row_conhec_transp_emit.descr_pais));
   --
   vn_fase := 99.3;
   --
   if nvl(est_row_conhec_transp_emit.conhectransp_id, 0) > 0
      and est_row_conhec_transp_emit.cnpj is not null
      and est_row_conhec_transp_emit.ie is not null
      and est_row_conhec_transp_emit.nome is not null
      and est_row_conhec_transp_emit.lograd is not null
      and est_row_conhec_transp_emit.nro is not null
      and est_row_conhec_transp_emit.bairro is not null
      and est_row_conhec_transp_emit.descr_cidade is not null
      and est_row_conhec_transp_emit.uf is not null
      then
      --
      vn_fase := 99.4;
      --
      if nvl(gn_tipo_integr,0) = 1 then
         --
         vn_fase := 99.5;
         --
         select conhectranspemit_seq.nextval
           into est_row_conhec_transp_emit.id
           from dual;
         --
         vn_fase := 99.6;
         --
         insert into conhec_transp_emit ( id
                                        , conhectransp_id
                                        , cnpj
                                        , ie
                                        , nome
                                        , nome_fant
                                        , lograd
                                        , nro
                                        , compl
                                        , bairro
                                        , ibge_cidade
                                        , descr_cidade
                                        , cep
                                        , uf
                                        , cod_pais
                                        , descr_pais
                                        , fone
                                        , dm_ind_sn
                                        )
                                 values ( est_row_conhec_transp_emit.id
                                        , est_row_conhec_transp_emit.conhectransp_id
                                        , est_row_conhec_transp_emit.cnpj
                                        , est_row_conhec_transp_emit.ie
                                        , est_row_conhec_transp_emit.nome
                                        , est_row_conhec_transp_emit.nome_fant
                                        , est_row_conhec_transp_emit.lograd
                                        , est_row_conhec_transp_emit.nro
                                        , est_row_conhec_transp_emit.compl
                                        , est_row_conhec_transp_emit.bairro
                                        , est_row_conhec_transp_emit.ibge_cidade
                                        , est_row_conhec_transp_emit.descr_cidade
                                        , est_row_conhec_transp_emit.cep
                                        , est_row_conhec_transp_emit.uf
                                        , est_row_conhec_transp_emit.cod_pais
                                        , est_row_conhec_transp_emit.descr_pais
                                        , est_row_conhec_transp_emit.fone
                                        , est_row_conhec_transp_emit.dm_ind_sn
                                        );
         --
      else
         --
         vn_fase := 99.7;
         --
         update conhec_transp_emit set cnpj         = est_row_conhec_transp_emit.cnpj
                                     , ie           = est_row_conhec_transp_emit.ie
                                     , nome         = est_row_conhec_transp_emit.nome
                                     , nome_fant    = est_row_conhec_transp_emit.nome_fant
                                     , lograd       = est_row_conhec_transp_emit.lograd
                                     , nro          = est_row_conhec_transp_emit.nro
                                     , compl        = est_row_conhec_transp_emit.compl
                                     , bairro       = est_row_conhec_transp_emit.bairro
                                     , ibge_cidade  = est_row_conhec_transp_emit.ibge_cidade
                                     , descr_cidade = est_row_conhec_transp_emit.descr_cidade
                                     , cep          = est_row_conhec_transp_emit.cep
                                     , uf           = est_row_conhec_transp_emit.uf
                                     , cod_pais     = est_row_conhec_transp_emit.cod_pais
                                     , descr_pais   = est_row_conhec_transp_emit.descr_pais
                                     , fone         = est_row_conhec_transp_emit.fone
                                     , dm_ind_sn    = est_row_conhec_transp_emit.dm_ind_sn
          where id = est_row_conhec_transp_emit.id;
         --
      end if;
      --
   end if;
   --
   vn_fase := 99.8;
   --
   pkb_reg_pessoa_emit_ct ( est_log_generico_ct       => est_log_generico
                          , et_row_conhec_transp_emit => est_row_conhec_transp_emit
                          , ev_cod_part               => ev_cod_part );
   --
   <<sair_integr>>
   null;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_integr_conhec_transp_emit fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => ERRO_DE_SISTEMA
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                              , est_log_generico  => est_log_generico );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_conhec_transp_emit;
--
------------------------------------------------------------------------------------------
-- Procedimento de Integra��o de Flex-Field de Conhecimento de Transporte
procedure pkb_integr_conhec_transp_ff ( est_log_generico    in out nocopy  dbms_sql.number_table
                                      , en_conhectransp_id  in             conhec_transp.id%type
                                      , ev_atributo         in             varchar2
                                      , ev_valor            in             varchar2 ) is
   --
   vn_fase              number := 0;
   vn_loggenerico_id    log_generico_ct.id%type;
   vv_mensagem          varchar2(1000) := null;
   vn_dmtipocampo       ff_obj_util_integr.dm_tipo_campo%type;
   vn_id_erp            conhec_transp.id_erp%type;
   vn_ibge_cidade_ini   conhec_transp.ibge_cidade_ini%type;
   vv_descr_cidade_ini  conhec_transp.descr_cidade_ini%type;
   vv_sigla_uf_ini      conhec_transp.sigla_uf_ini%type;
   vn_ibge_cidade_fim   conhec_transp.ibge_cidade_fim%type;
   vv_descr_cidade_fim  conhec_transp.descr_cidade_fim%type;
   vv_sigla_uf_fim      conhec_transp.sigla_uf_fim%type;
   --
   vv_cd_unid_org       unid_org.cd%type;
   vn_unidorg_id        conhec_transp.unidorg_id%type;
   --
begin
   --
   vn_fase := 1;
   --
   gv_mensagem_log := null;
   --
   if trim(ev_atributo) is null then
      --
      vn_fase := 2;
      --
      gv_mensagem_log := 'Conhecimento de Transp. - EFD: "Atributo" deve ser informado.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => erro_de_validacao
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                           , est_log_generico => est_log_generico );
      --
   end if;
   --
   vn_fase := 3;
   --
   if trim(ev_valor) is null then
      --
      vn_fase := 4;
      --
      gv_mensagem_log := 'Conhecimento de Transp. - EFD: "VALOR" referente ao atributo deve ser informado.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => erro_de_validacao
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 5;
   --
   vv_mensagem := pk_csf.fkg_ff_verif_campos( ev_obj_name => 'VW_CSF_CONHEC_TRANSP_EFD_FF'
                                            , ev_atributo => trim(ev_atributo)
                                            , ev_valor    => trim(ev_valor) );
   --
   vn_fase := 6;
   --
   if vv_mensagem is not null then
      --
      vn_fase := 7;
      --
      gv_mensagem_log := vv_mensagem;
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => erro_de_validacao
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   else
      --
      vn_fase := 8;
      --
      vn_dmtipocampo := pk_csf.fkg_ff_retorna_dmtipocampo( ev_obj_name => 'VW_CSF_CONHEC_TRANSP_EFD_FF'
                                                         , ev_atributo => trim(ev_atributo) );
      --
      vn_fase := 9;
      --
      -- Tratamento para o atributo => ID_ERP
      -- ====================================
      if trim(ev_atributo) = 'ID_ERP' then
         --
         vn_fase := 10;
         --
         if trim(ev_valor) is not null then
            --
            vn_fase := 11;
            --
            if vn_dmtipocampo = 1 then -- tipo de campo = 0-data, 1-num�rico, 2-caractere
               --
               vn_fase := 12;
               --
               vn_id_erp := pk_csf.fkg_ff_ret_vlr_number ( ev_obj_name => 'VW_CSF_CONHEC_TRANSP_EFD_FF'
                                                         , ev_atributo => trim(ev_atributo)
                                                         , ev_valor    => trim(ev_valor) );
               --
            else
               --
               vn_fase := 13;
               --
               gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR informado n�o confere com o tipo de campo, deveria ser NUM�RICO.';
               --
               vn_loggenerico_id := null;
               --
               pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                                 , ev_mensagem       => gv_cabec_log
                                                 , ev_resumo         => gv_mensagem_log
                                                 , en_tipo_log       => erro_de_validacao
                                                 , en_referencia_id  => gn_referencia_id
                                                 , ev_obj_referencia => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na mem�ria
               pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                                    , est_log_generico => est_log_generico );
               --
            end if;
            --
         else
            --
            vn_fase := 14;
            --
            gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR deve ser maior do que zero (0).';
            --
            vn_loggenerico_id := null;
            --
            pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                              , ev_mensagem       => gv_cabec_log
                                              , ev_resumo         => gv_mensagem_log
                                              , en_tipo_log       => erro_de_validacao
                                              , en_referencia_id  => gn_referencia_id
                                              , ev_obj_referencia => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na mem�ria
            pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                                 , est_log_generico => est_log_generico );
            --
         end if;
         --
      -- Tratamento para o atributo => IBGE_CIDADE_INI
      -- =============================================
      elsif trim(ev_atributo) = 'IBGE_CIDADE_INI' then
         --
         vn_fase := 15;
         --
         if trim(ev_valor) is not null then
            --
            vn_fase := 16;
            --
            if vn_dmtipocampo = 1 then -- tipo de campo = 0-data, 1-num�rico, 2-caractere
               --
               vn_fase := 17;
               --
               vn_ibge_cidade_ini := pk_csf.fkg_ff_ret_vlr_number ( ev_obj_name => 'VW_CSF_CONHEC_TRANSP_EFD_FF'
                                                                  , ev_atributo => trim(ev_atributo)
                                                                  , ev_valor    => trim(ev_valor) );
               --
               -- V�lida o c�digo IBGE da Cidade
               if pk_csf.fkg_ibge_cidade ( ev_ibge_cidade => to_char(vn_ibge_cidade_ini) ) = false then
                  --
                  vn_fase := 18;
                  --
                  gv_mensagem_log := 'O "C�digo do Munic�pio de in�cio da presta��o" (' || vn_ibge_cidade_ini || ') est� inv�lido!';
                  --
                  vn_loggenerico_id := null;
                  --
                  pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                                    , ev_mensagem        => gv_cabec_log
                                                    , ev_resumo          => gv_mensagem_log
                                                    , en_tipo_log        => ERRO_DE_VALIDACAO
                                                    , en_referencia_id   => gn_referencia_id
                                                    , ev_obj_referencia  => gv_obj_referencia );
                  --
                  -- Armazena o "loggenerico_id" na mem�ria
                  pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                                       , est_log_generico  => est_log_generico );
                  --
               end if;
               --
            else
               --
               vn_fase := 19;
               --
               gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR informado n�o confere com o tipo de campo, deveria ser NUM�RICO.';
               --
               vn_loggenerico_id := null;
               --
               pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                                 , ev_mensagem       => gv_cabec_log
                                                 , ev_resumo         => gv_mensagem_log
                                                 , en_tipo_log       => erro_de_validacao
                                                 , en_referencia_id  => gn_referencia_id
                                                 , ev_obj_referencia => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na mem�ria
               pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                                    , est_log_generico => est_log_generico );
               --
            end if;
            --
         else
            --
            vn_fase := 20;
            --
            gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR deve ser maior do que zero (0).';
            --
            vn_loggenerico_id := null;
            --
            pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                              , ev_mensagem       => gv_cabec_log
                                              , ev_resumo         => gv_mensagem_log
                                              , en_tipo_log       => erro_de_validacao
                                              , en_referencia_id  => gn_referencia_id
                                              , ev_obj_referencia => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na mem�ria
            pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                                 , est_log_generico => est_log_generico );
            --
         end if;
         --
      -- Tratamento para o atributo => DESCR_CIDADE_INI
      -- ==============================================
      elsif trim(ev_atributo) = 'DESCR_CIDADE_INI' then
         --
         vn_fase := 21;
         --
         if trim(ev_valor) is not null then
            --
            vn_fase := 22;
            --
            if vn_dmtipocampo = 2 then -- tipo de campo = 0-data, 1-num�rico, 2-caractere
               --
               vn_fase := 23;
               --
               vv_descr_cidade_ini := pk_csf.fkg_ff_ret_vlr_caracter ( ev_obj_name => 'VW_CSF_CONHEC_TRANSP_EFD_FF'
                                                                     , ev_atributo => trim(ev_atributo)
                                                                     , ev_valor    => trim(ev_valor) );
               --
               vn_fase := 23.1;
               --
               -- Valida o campo Nome do Munic�pio do in�cio da presta��o foi informado.
               if trim(pk_csf.fkg_converte(vv_descr_cidade_ini)) is null then
                  --
                  gv_mensagem_log := null;
                  --
                  gv_mensagem_log := 'O "Nome do Munic�pio do in�cio da presta��o - Origem" (' || vv_descr_cidade_ini || ') � obrigat�rio.';
                  --
                  vn_loggenerico_id := null;
                  --
                  pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                                    , ev_mensagem        => gv_cabec_log
                                                    , ev_resumo          => gv_mensagem_log
                                                    , en_tipo_log        => ERRO_DE_VALIDACAO
                                                    , en_referencia_id   => gn_referencia_id
                                                    , ev_obj_referencia  => gv_obj_referencia );
                  --
                  -- Armazena o "loggenerico_id" na mem�ria
                  pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                                       , est_log_generico  => est_log_generico );
                  --
               end if;
         --
            else
               --
               vn_fase := 24;
               --
               gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR informado n�o confere com o tipo de campo, deveria ser CARACTERE.';
               --
               vn_loggenerico_id := null;
               --
               pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                                 , ev_mensagem       => gv_cabec_log
                                                 , ev_resumo         => gv_mensagem_log
                                                 , en_tipo_log       => erro_de_validacao
                                                 , en_referencia_id  => gn_referencia_id
                                                 , ev_obj_referencia => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na mem�ria
               pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                                    , est_log_generico => est_log_generico );
               --
            end if;
            --
         else
            --
            vn_fase := 25;
            --
            gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR n�o pode ser nulo.';
            --
            vn_loggenerico_id := null;
            --
            pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                              , ev_mensagem       => gv_cabec_log
                                              , ev_resumo         => gv_mensagem_log
                                              , en_tipo_log       => erro_de_validacao
                                              , en_referencia_id  => gn_referencia_id
                                              , ev_obj_referencia => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na mem�ria
            pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                                 , est_log_generico => est_log_generico );
            --
         end if;
         --
      --
      -- Tratamento para o atributo => SIGLA_UF_INI
      -- ==========================================
      elsif trim(ev_atributo) = 'SIGLA_UF_INI' then
         --
         vn_fase := 26;
         --
         if trim(ev_valor) is not null then
            --
            vn_fase := 27;
            --
            if vn_dmtipocampo = 2 then -- tipo de campo = 0-data, 1-num�rico, 2-caractere
               --
               vn_fase := 28;
               --
               vv_sigla_uf_ini := pk_csf.fkg_ff_ret_vlr_caracter ( ev_obj_name => 'VW_CSF_CONHEC_TRANSP_EFD_FF'
                                                                 , ev_atributo => trim(ev_atributo)
                                                                 , ev_valor    => trim(ev_valor) );
               --
               -- Valida o campo Sigla da UF do in�cio da presta��o.
               if pk_csf.fkg_uf_valida ( ev_sigla_estado  => trim(pk_csf.fkg_converte(vv_sigla_uf_ini)) ) = false then
                  --
                  vn_fase := 28.1;
                  --
                  gv_mensagem_log := null;
                  --
                  gv_mensagem_log := 'A "Sigla da UF do in�cio da presta��o - Origem" (' || vv_sigla_uf_ini || ') est� inv�lida.';
                  --
                  vn_loggenerico_id := null;
                  --
                  pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                                    , ev_mensagem        => gv_cabec_log
                                                    , ev_resumo          => gv_mensagem_log
                                                    , en_tipo_log        => ERRO_DE_VALIDACAO
                                                    , en_referencia_id   => gn_referencia_id
                                                    , ev_obj_referencia  => gv_obj_referencia );
                  --
                  -- Armazena o "loggenerico_id" na mem�ria
                  pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                                       , est_log_generico  => est_log_generico );
                  --
               end if;
               --
            else
               --
               vn_fase := 30;
               --
               gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR informado n�o confere com o tipo de campo, deveria ser CARACTERE.';
               --
               vn_loggenerico_id := null;
               --
               pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                                 , ev_mensagem       => gv_cabec_log
                                                 , ev_resumo         => gv_mensagem_log
                                                 , en_tipo_log       => erro_de_validacao
                                                 , en_referencia_id  => gn_referencia_id
                                                 , ev_obj_referencia => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na mem�ria
               pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                                    , est_log_generico => est_log_generico );
               --
            end if;
            --
         else
            --
            vn_fase := 31;
            --
            gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR n�o pode ser nulo.';
            --
            vn_loggenerico_id := null;
            --
            pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                              , ev_mensagem       => gv_cabec_log
                                              , ev_resumo         => gv_mensagem_log
                                              , en_tipo_log       => erro_de_validacao
                                              , en_referencia_id  => gn_referencia_id
                                              , ev_obj_referencia => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na mem�ria
            pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                                 , est_log_generico => est_log_generico );
            --
         end if;
         --
      --
      -- Tratamento para o atributo => IBGE_CIDADE_FIM
      -- =============================================
      elsif trim(ev_atributo) = 'IBGE_CIDADE_FIM' then
         --
         vn_fase := 32;
         --
         if trim(ev_valor) is not null then
            --
            vn_fase := 33;
            --
            if vn_dmtipocampo = 1 then -- tipo de campo = 0-data, 1-num�rico, 2-caractere
               --
               vn_fase := 34;
               --
               vn_ibge_cidade_fim := pk_csf.fkg_ff_ret_vlr_number ( ev_obj_name => 'VW_CSF_CONHEC_TRANSP_EFD_FF'
                                                                  , ev_atributo => trim(ev_atributo)
                                                                  , ev_valor    => trim(ev_valor) );
               --
               -- V�lida o c�digo IBGE da Cidade
               if pk_csf.fkg_ibge_cidade ( ev_ibge_cidade => to_char(vn_ibge_cidade_fim) ) = false then
                  --
                  vn_fase := 18;
                  --
                  gv_mensagem_log := 'O "C�digo do de t�rmino da presta��o - Destino" (' || vn_ibge_cidade_fim || ') est� inv�lido!';
                  --
                  vn_loggenerico_id := null;
                  --
                  pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                                    , ev_mensagem        => gv_cabec_log
                                                    , ev_resumo          => gv_mensagem_log
                                                    , en_tipo_log        => ERRO_DE_VALIDACAO
                                                    , en_referencia_id   => gn_referencia_id
                                                    , ev_obj_referencia  => gv_obj_referencia );
                  --
                  -- Armazena o "loggenerico_id" na mem�ria
                  pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                                       , est_log_generico  => est_log_generico );
                  --
               end if;
               --
            else
               --
               vn_fase := 35;
               --
               gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR informado n�o confere com o tipo de campo, deveria ser NUM�RICO.';
               --
               vn_loggenerico_id := null;
               --
               pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                                 , ev_mensagem       => gv_cabec_log
                                                 , ev_resumo         => gv_mensagem_log
                                                 , en_tipo_log       => erro_de_validacao
                                                 , en_referencia_id  => gn_referencia_id
                                                 , ev_obj_referencia => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na mem�ria
               pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                                    , est_log_generico => est_log_generico );
               --
            end if;
            --
         else
            --
            vn_fase := 36;
            --
            gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR deve ser maior do que zero (0).';
            --
            vn_loggenerico_id := null;
            --
            pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                              , ev_mensagem       => gv_cabec_log
                                              , ev_resumo         => gv_mensagem_log
                                              , en_tipo_log       => erro_de_validacao
                                              , en_referencia_id  => gn_referencia_id
                                              , ev_obj_referencia => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na mem�ria
            pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                                 , est_log_generico => est_log_generico );
            --
         end if;
         --
      --
      -- Tratamento para o atributo => DESCR_CIDADE_FIM
      -- ==============================================
      elsif trim(ev_atributo) = 'DESCR_CIDADE_FIM' then
         --
         vn_fase := 37;
         --
         if trim(ev_valor) is not null then
            --
            vn_fase := 38;
            --
            if vn_dmtipocampo = 2 then -- tipo de campo = 0-data, 1-num�rico, 2-caractere
               --
               vn_fase := 39;
               --
               vv_descr_cidade_fim := pk_csf.fkg_ff_ret_vlr_caracter ( ev_obj_name => 'VW_CSF_CONHEC_TRANSP_EFD_FF'
                                                                     , ev_atributo => trim(ev_atributo)
                                                                     , ev_valor    => trim(ev_valor) );
               --
               -- Valida o campo Nome do Munic�pio do t�rmino da presta��o foi informado.
               if trim(pk_csf.fkg_converte(vv_descr_cidade_fim)) is null then
                  --
                  vn_fase := 39.1;
                  --
                  gv_mensagem_log := null;
                  --
                  gv_mensagem_log := 'O "Nome do Munic�pio de t�rmino da presta��o - Destino" (' || vv_descr_cidade_fim || ') � obrigat�rio .';
                  --
                  vn_loggenerico_id := null;
                  --
                  pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                                    , ev_mensagem        => gv_cabec_log
                                                    , ev_resumo          => gv_mensagem_log
                                                    , en_tipo_log        => ERRO_DE_VALIDACAO
                                                    , en_referencia_id   => gn_referencia_id
                                                    , ev_obj_referencia  => gv_obj_referencia );
                  --
                  -- Armazena o "loggenerico_id" na mem�ria
                  pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                                       , est_log_generico  => est_log_generico );
                  --
               end if;
               --
            else
               --
               vn_fase := 40;
               --
               gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR informado n�o confere com o tipo de campo, deveria ser CARACTERE.';
               --
               vn_loggenerico_id := null;
               --
               pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                                 , ev_mensagem       => gv_cabec_log
                                                 , ev_resumo         => gv_mensagem_log
                                                 , en_tipo_log       => erro_de_validacao
                                                 , en_referencia_id  => gn_referencia_id
                                                 , ev_obj_referencia => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na mem�ria
               pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                                    , est_log_generico => est_log_generico );
               --
            end if;
            --
         else
            --
            vn_fase := 41;
            --
            gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR n�o pode ser nulo.';
            --
            vn_loggenerico_id := null;
            --
            pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                              , ev_mensagem       => gv_cabec_log
                                              , ev_resumo         => gv_mensagem_log
                                              , en_tipo_log       => erro_de_validacao
                                              , en_referencia_id  => gn_referencia_id
                                              , ev_obj_referencia => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na mem�ria
            pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                                 , est_log_generico => est_log_generico );
            --
         end if;
         --
      --
      -- Tratamento para o atributo => SIGLA_UF_FIM
      -- ==========================================
      elsif trim(ev_atributo) = 'SIGLA_UF_FIM' then
         --
         vn_fase := 42;
         --
         if trim(ev_valor) is not null then
            --
            vn_fase := 43;
            --
            if vn_dmtipocampo = 2 then -- tipo de campo = 0-data, 1-num�rico, 2-caractere
               --
               vn_fase := 44;
               --
               vv_sigla_uf_fim := pk_csf.fkg_ff_ret_vlr_caracter ( ev_obj_name => 'VW_CSF_CONHEC_TRANSP_EFD_FF'
                                                                 , ev_atributo => trim(ev_atributo)
                                                                 , ev_valor    => trim(ev_valor) );
               --
               -- Valida o campo Sigla da UF do t�rmino da presta��o.
               if pk_csf.fkg_uf_valida ( ev_sigla_estado  => trim(pk_csf.fkg_converte(vv_sigla_uf_fim)) ) = false then
                  --
                  vn_fase := 44.1;
                  --
                  gv_mensagem_log := null;
                  --
                  gv_mensagem_log := 'A "Sigla da UF do t�rmino da presta��o - Destino" (' || vv_sigla_uf_fim || ') est� inv�lida.';
                  --
                  vn_loggenerico_id := null;
                  --
                  pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                                    , ev_mensagem        => gv_cabec_log
                                                    , ev_resumo          => gv_mensagem_log
                                                    , en_tipo_log        => ERRO_DE_VALIDACAO
                                                    , en_referencia_id   => gn_referencia_id
                                                    , ev_obj_referencia  => gv_obj_referencia );
                  --
                  -- Armazena o "loggenerico_id" na mem�ria
                  pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                                       , est_log_generico  => est_log_generico );
                  --
               end if;
               --
            else
               --
               vn_fase := 45;
               --
               gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR informado n�o confere com o tipo de campo, deveria ser CARACTERE.';
               --
               vn_loggenerico_id := null;
               --
               pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                                 , ev_mensagem       => gv_cabec_log
                                                 , ev_resumo         => gv_mensagem_log
                                                 , en_tipo_log       => erro_de_validacao
                                                 , en_referencia_id  => gn_referencia_id
                                                 , ev_obj_referencia => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na mem�ria
               pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                                    , est_log_generico => est_log_generico );
               --
            end if;
            --
         else
            --
            vn_fase := 46;
            --
            gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR n�o pode ser nulo.';
            --
            vn_loggenerico_id := null;
            --
            pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                              , ev_mensagem       => gv_cabec_log
                                              , ev_resumo         => gv_mensagem_log
                                              , en_tipo_log       => erro_de_validacao
                                              , en_referencia_id  => gn_referencia_id
                                              , ev_obj_referencia => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na mem�ria
            pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                                 , est_log_generico => est_log_generico );
            --
         end if;
         --
      -- Tratamento para o atributo => CD_UNID_ORG
      -- ==========================================
      elsif trim(ev_atributo) = 'CD_UNID_ORG' then
         --
         vn_fase := 48;
         --
         if trim(ev_valor) is not null then
            --
            vn_fase := 49;
            --
            if vn_dmtipocampo = 2 then -- tipo de campo = 0-data, 1-num�rico, 2-caractere
               --
               vn_fase := 50;
               --
               vv_cd_unid_org := pk_csf.fkg_ff_ret_vlr_caracter ( ev_obj_name => 'VW_CSF_CONHEC_TRANSP_EFD_FF'
                                                                 , ev_atributo => trim(ev_atributo)
                                                                 , ev_valor    => trim(ev_valor) );
               --
               vn_fase := 50.1;
               --               
               vn_unidorg_id:= pk_csf.fkg_unig_org_id(en_empresa_id   => gt_row_conhec_transp.empresa_id
                                                     ,ev_cod_unid_org => vv_cd_unid_org );
               --                                                                                             
               -- Valida o campo Codigo da Unidade Organizacional
               if nvl(vn_unidorg_id,0) = 0 then
                  --
                  vn_fase := 50.2;
                  --
                  gv_mensagem_log := null;
                  --
                  gv_mensagem_log := 'A "Unidade Organizacional" (' || vv_cd_unid_org || ') est� inv�lida.';
                  --
                  vn_loggenerico_id := null;
                  --
                  pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                                    , ev_mensagem        => gv_cabec_log
                                                    , ev_resumo          => gv_mensagem_log
                                                    , en_tipo_log        => ERRO_DE_VALIDACAO
                                                    , en_referencia_id   => gn_referencia_id
                                                    , ev_obj_referencia  => gv_obj_referencia );
                  --
                  -- Armazena o "loggenerico_id" na mem�ria
                  pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                                       , est_log_generico  => est_log_generico );
                  --
               end if;
               --
            else
               --
               vn_fase := 51;
               --
               gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR informado n�o confere com o tipo de campo, deveria ser CARACTERE.';
               --
               vn_loggenerico_id := null;
               --
               pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                                 , ev_mensagem       => gv_cabec_log
                                                 , ev_resumo         => gv_mensagem_log
                                                 , en_tipo_log       => erro_de_validacao
                                                 , en_referencia_id  => gn_referencia_id
                                                 , ev_obj_referencia => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na mem�ria
               pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                                    , est_log_generico => est_log_generico );
               --
            end if;
            --
         else
            --
            vn_fase := 52;
            --
            gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR n�o pode ser nulo.';
            --
            vn_loggenerico_id := null;
            --
            pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                              , ev_mensagem       => gv_cabec_log
                                              , ev_resumo         => gv_mensagem_log
                                              , en_tipo_log       => erro_de_validacao
                                              , en_referencia_id  => gn_referencia_id
                                              , ev_obj_referencia => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na mem�ria
            pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                                 , est_log_generico => est_log_generico );
            --
         end if;
         ---               
      else
         --
         vn_fase := 53;
         --
         gv_mensagem_log := '"Atributo" ('||ev_atributo||') e "VALOR" ('||ev_valor||') relacionados, n�o especificados no processo.';
         --
         vn_loggenerico_id := null;
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => ERRO_DE_VALIDACAO
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                              , est_log_generico  => est_log_generico );
         --
      end if;
      --
   end if; -- Fim da verifica��o vv_mensagem is not null
   --
   vn_fase := 54;
   --
   if nvl(en_conhectransp_id,0) = 0 then
      --
      vn_fase := 55;
      --
      gv_mensagem_log := 'Identificador do imposto do conhecimento de transporte n�o informado.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => erro_de_validacao
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 80;
   --
   if nvl(en_conhectransp_id,0) > 0 and ev_atributo = 'ID_ERP'
                                    and vn_id_erp is not null
                                    and gv_mensagem_log is null then
      --
      vn_fase := 81;
      --
      update conhec_transp cr
         set cr.id_erp = vn_id_erp
       where cr.id     = en_conhectransp_id;
      --
   end if;
   --
   vn_fase := 82;
   --
   vn_fase := 83;
   --
   if nvl(en_conhectransp_id,0) > 0 and ev_atributo = 'IBGE_CIDADE_INI'
                                    and nvl(vn_ibge_cidade_ini ,-1) > 0
                                    and gv_mensagem_log                              is null then
      vn_fase := 84;
      --
      update conhec_transp cr
         set cr.ibge_cidade_ini   =  vn_ibge_cidade_ini
       where cr.id = en_conhectransp_id;
      --
   end if;
   --
   if nvl(en_conhectransp_id,0) > 0 and ev_atributo = 'DESCR_CIDADE_INI'
                                    and vv_descr_cidade_ini         is not null
                                    and gv_mensagem_log                              is null then

      vn_fase := 85;
      --
      update conhec_transp cr
         set cr.descr_cidade_ini  =  vv_descr_cidade_ini
       where cr.id = en_conhectransp_id;

   end if;
   --
   if nvl(en_conhectransp_id,0) > 0 and ev_atributo = 'SIGLA_UF_INI'
                                    and vv_sigla_uf_ini is not null
                                    and gv_mensagem_log                              is null then

      --
      vn_fase := 86;
      --
      update conhec_transp cr
         set cr.sigla_uf_ini      =  vv_sigla_uf_ini
       where cr.id = en_conhectransp_id;
      --
   end if;
   --
   if nvl(en_conhectransp_id,0) > 0 and ev_atributo = 'IBGE_CIDADE_FIM'
                                    and nvl(vn_ibge_cidade_fim ,-1) > 0
                                    and gv_mensagem_log                              is null then
      --
      vn_fase := 87;
      --
      update conhec_transp cr
         set cr.ibge_cidade_fim   =  vn_ibge_cidade_fim
       where cr.id = en_conhectransp_id;
      --
   end if;
   --
   if nvl(en_conhectransp_id,0) > 0 and ev_atributo = 'DESCR_CIDADE_FIM'
                                    and vv_descr_cidade_fim         is not null
                                    and gv_mensagem_log                              is null then

      vn_fase := 88;
      --
      update conhec_transp cr
         set cr.descr_cidade_fim  =  vv_descr_cidade_fim
       where cr.id = en_conhectransp_id;
      --
   end if;
   --
   if nvl(en_conhectransp_id,0) > 0 and ev_atributo = 'SIGLA_UF_FIM'
                                    and vv_sigla_uf_fim             is not null
                                    and gv_mensagem_log                              is null then
      vn_fase := 89;
      --
      update conhec_transp cr
         set cr.sigla_uf_fim      =  vv_sigla_uf_fim
       where cr.id = en_conhectransp_id;
      --
   end if;
   --
   if nvl(en_conhectransp_id,0) > 0 and ev_atributo = 'CD_UNID_ORG'
                                    and vv_cd_unid_org   is not null
                                    and gv_mensagem_log  is null then
      vn_fase := 90;
      --
      update conhec_transp cr
         set cr.unidorg_id      =  vn_unidorg_id
       where cr.id = en_conhectransp_id;
      --
   end if;   
   --
   vn_fase := 100;
   --
   <<sair_integr>>
   null;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_d100.pkb_integr_conhec_transp_ff fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_mensagem_log
                                           , ev_resumo          => null
                                           , en_tipo_log        => ERRO_DE_SISTEMA
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_conhec_transp_ff;
--
-------------------------------------------------------------------------------------------------------
--| Procedimento integra o resumo de impostos do Conhecimento de Transporte - Campos Flex Field
-------------------------------------------------------------------------------------------------------
procedure pkb_integr_ct_d190_ff ( est_log_generico in out nocopy  dbms_sql.number_table
                                , en_ctreganal_id  in             ct_reg_anal.id%type
                                , ev_atributo      in             varchar2
                                , ev_valor         in             varchar2 )
is
   --
   vn_fase             number := 0;
   vn_loggenerico_id   log_generico_ct.id%type;
   vv_mensagem         varchar2(1000) := null;
   vn_dmtipocampo      ff_obj_util_integr.dm_tipo_campo%type;
   vn_vl_base_outro    ct_reg_anal.vl_base_outro%type := 0;
   vn_vl_imp_outro     ct_reg_anal.vl_imp_outro%type := 0;
   vn_vl_base_isenta   ct_reg_anal.vl_base_isenta%type := 0;
   vn_aliq_aplic_outro ct_reg_anal.aliq_aplic_outro%type := 0;
   --
begin
   --
   vn_fase := 1;
   --
   gv_mensagem_log := null;
   --
   if trim(ev_atributo) is null then
      --
      vn_fase := 2;
      --
      gv_mensagem_log := 'Registro Analitico dos Documentos(Conhecimento de Transp.) - EFD: "Atributo" deve ser informado.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => erro_de_validacao
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                           , est_log_generico => est_log_generico );
      --
   end if;
   --
   vn_fase := 3;
   --
   if trim(ev_valor) is null then
      --
      vn_fase := 4;
      --
      gv_mensagem_log := 'Registro Analitico dos Documentos(Conhecimento de Transp.) - EFD: "VALOR" referente ao atributo deve ser informado.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => erro_de_validacao
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 5;
   --
   vv_mensagem := pk_csf.fkg_ff_verif_campos( ev_obj_name => 'VW_CSF_REGCONHECTRANSP_EFD_FF'
                                            , ev_atributo => trim(ev_atributo)
                                            , ev_valor    => trim(ev_valor) );
   --
   vn_fase := 6;
   --
   if vv_mensagem is not null then
      --
      vn_fase := 7;
      --
      gv_mensagem_log := vv_mensagem;
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => erro_de_validacao
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   else
      --
      vn_fase := 8;
      --
      vn_dmtipocampo := pk_csf.fkg_ff_retorna_dmtipocampo( ev_obj_name => 'VW_CSF_REGCONHECTRANSP_EFD_FF'
                                                         , ev_atributo => trim(ev_atributo) );
      --
      vn_fase := 9;
      --
      if trim(ev_atributo) = 'VL_BASE_OUTRO' or
         trim(ev_atributo) = 'VL_IMP_OUTRO' or
         trim(ev_atributo) = 'VL_BASE_ISENTA' or
         trim(ev_atributo) = 'ALIQ_APLIC_OUTRO' then
         --
         vn_fase := 10;
         --
         if trim(ev_valor) is not null then
            --
            vn_fase := 11;
            --
            if vn_dmtipocampo = 1 then -- tipo de campo = 0-data, 1-num�rico, 2-caractere
               --
               vn_fase := 12;
               --
               if trim(ev_atributo) = 'VL_BASE_OUTRO' then
                  --
                  vn_fase := 13;
                  --
                  vn_vl_base_outro := pk_csf.fkg_ff_ret_vlr_number( ev_obj_name => 'VW_CSF_REGCONHECTRANSP_EFD_FF'
                                                                  , ev_atributo => trim(ev_atributo)
                                                                  , ev_valor    => trim(ev_valor) );
                  --
               elsif trim(ev_atributo) = 'VL_IMP_OUTRO' then
                     --
                     vn_fase := 14;
                     --
                     vn_vl_imp_outro := pk_csf.fkg_ff_ret_vlr_number( ev_obj_name => 'VW_CSF_REGCONHECTRANSP_EFD_FF'
                                                                    , ev_atributo => trim(ev_atributo)
                                                                    , ev_valor    => trim(ev_valor) );
                     --
               elsif trim(ev_atributo) = 'VL_BASE_ISENTA' then
                     --
                     vn_fase := 15;
                     --
                     vn_vl_base_isenta := pk_csf.fkg_ff_ret_vlr_number( ev_obj_name => 'VW_CSF_REGCONHECTRANSP_EFD_FF'
                                                                      , ev_atributo => trim(ev_atributo)
                                                                      , ev_valor    => trim(ev_valor) );
                     --
               elsif trim(ev_atributo) = 'ALIQ_APLIC_OUTRO' then
                     --
                     vn_fase := 16;
                     --
                     vn_aliq_aplic_outro := pk_csf.fkg_ff_ret_vlr_number( ev_obj_name => 'VW_CSF_REGCONHECTRANSP_EFD_FF'
                                                                        , ev_atributo => trim(ev_atributo)
                                                                        , ev_valor    => trim(ev_valor) );
                     --
               end if;
               --
               vn_fase := 17;
               --
               if nvl(vn_vl_base_outro,0) < 0 or
                  nvl(vn_vl_imp_outro,0) < 0 or
                  nvl(vn_vl_base_isenta,0) < 0 or
                  nvl(vn_aliq_aplic_outro,0) < 0 then
                  --
                  vn_fase := 18;
                  --
                  gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR ('||ev_valor||') informado n�o pode ser negativo.';
                  --
                  vn_loggenerico_id := null;
                  --
                  pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                                    , ev_mensagem       => gv_cabec_log
                                                    , ev_resumo         => gv_mensagem_log
                                                    , en_tipo_log       => erro_de_validacao
                                                    , en_referencia_id  => gn_referencia_id
                                                    , ev_obj_referencia => gv_obj_referencia );
                  --
                  -- Armazena o "loggenerico_id" na mem�ria
                  pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                                       , est_log_generico => est_log_generico );
                  --
               end if;
               --
            else
               --
               vn_fase := 19;
               --
               gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR informado n�o confere com o tipo de campo, deveria ser NUM�RICO.';
               --
               vn_loggenerico_id := null;
               --
               pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                                 , ev_mensagem       => gv_cabec_log
                                                 , ev_resumo         => gv_mensagem_log
                                                 , en_tipo_log       => erro_de_validacao
                                                 , en_referencia_id  => gn_referencia_id
                                                 , ev_obj_referencia => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na mem�ria
               pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                                    , est_log_generico => est_log_generico );
               --
            end if;
            --
         else
            --
            vn_fase := 20;
            --
            gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR deve ser maior do que zero (0).';
            --
            vn_loggenerico_id := null;
            --
            pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                              , ev_mensagem       => gv_cabec_log
                                              , ev_resumo         => gv_mensagem_log
                                              , en_tipo_log       => erro_de_validacao
                                              , en_referencia_id  => gn_referencia_id
                                              , ev_obj_referencia => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na mem�ria
            pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                                 , est_log_generico => est_log_generico );
            --
         end if;
      else
         --
         vn_fase := 21;
         --
         gv_mensagem_log := '"Atributo" ('||ev_atributo||') e "VALOR" ('||ev_valor||') relacionados, n�o especificados no processo.';
         --
         vn_loggenerico_id := null;
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => ERRO_DE_VALIDACAO
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                              , est_log_generico  => est_log_generico );
         --
      end if;
      --
   end if;
   --
   vn_fase := 22;
   --
   if nvl(en_ctreganal_id,0) = 0 then
      --
      vn_fase := 23;
      --
      gv_mensagem_log := 'Identificador do imposto do conhecimento de transporte n�o informado.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => erro_de_validacao
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(en_ctreganal_id,0) > 0 and
      ev_atributo = 'VL_BASE_OUTRO' and
      vn_vl_base_outro is not null and
      gv_mensagem_log is null then
      --
      vn_fase := 99.1;
      --
      update ct_reg_anal cr
         set cr.vl_base_outro = vn_vl_base_outro
       where cr.id = en_ctreganal_id;
      --
   elsif nvl(en_ctreganal_id,0) > 0 and
         ev_atributo = 'VL_IMP_OUTRO' and
         vn_vl_imp_outro is not null and
         gv_mensagem_log is null then
         --
         vn_fase := 99.2;
         --
         update ct_reg_anal cr
            set cr.vl_imp_outro = vn_vl_imp_outro
          where cr.id = en_ctreganal_id;
         --
   elsif nvl(en_ctreganal_id,0) > 0 and
         ev_atributo = 'VL_BASE_ISENTA' and
         vn_vl_base_isenta is not null and
         gv_mensagem_log is null then
         --
         vn_fase := 99.3;
         --
         update ct_reg_anal cr
            set cr.vl_base_isenta = vn_vl_base_isenta
          where cr.id = en_ctreganal_id;
         --
   elsif nvl(en_ctreganal_id,0) > 0 and
         ev_atributo = 'ALIQ_APLIC_OUTRO' and
         vn_aliq_aplic_outro is not null and
         gv_mensagem_log is null then
         --
         vn_fase := 99.4;
         --
         update ct_reg_anal cr
            set cr.aliq_aplic_outro = vn_aliq_aplic_outro
          where cr.id = en_ctreganal_id;
         --
   end if;
   --
   vn_fase := 100;
   --
   <<sair_integr>>
   null;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_d100.pkb_integr_ct_d190_ff fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_mensagem_log
                                           , ev_resumo          => null
                                           , en_tipo_log        => ERRO_DE_SISTEMA
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_ct_d190_ff;
-------------------------------------------------------------------------------------------------------
--| Procedimento integra o resumo de impostos do Conhecimento de Transporte
-------------------------------------------------------------------------------------------------------
procedure pkb_integr_ct_d190 ( est_log_generico            in out nocopy  dbms_sql.number_table
                             , est_ct_reg_anal             in out nocopy  ct_reg_anal%rowtype
                             , ev_cod_st                   in             cod_st.cod_st%type
                             , en_cfop                     in             cfop.cd%type
                             , ev_cod_obs                  in             obs_lancto_fiscal.cod_obs%type
                             , en_multorg_id               in             mult_org.id%type )
is
   --
   vn_fase               number := 0;
   vn_loggenerico_id     log_generico_ct.id%TYPE;
   vn_obslanctofiscal_id obs_lancto_fiscal.id%type;
   vn_dm_tp_cte          conhec_transp.dm_tp_cte%type;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(est_ct_reg_anal.conhectransp_id,0) <= 0 then
      --
      vn_fase := 1.1;
      --
      gv_mensagem_log := 'N�o informado o relacionamento entre o Resumo de Impostos e o Conhecimento de Transportes.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 2;
   --
   est_ct_reg_anal.codst_id := pk_csf.fkg_Cod_ST_id ( ev_cod_st      => lpad(ev_cod_st, 2, '0')
                                                    , en_tipoimp_id  => pk_csf.fkg_Tipo_Imposto_id ( 1 ) );
   --
   vn_fase := 3;
   --
   if nvl(est_ct_reg_anal.codst_id,0) <= 0 then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := '"C�digo da situa��o Tribut�ria" inv�lido (' || ev_cod_st || ') para o tipo de imposto ICMS.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 4;
   --
   est_ct_reg_anal.cfop_id := pk_csf.fkg_cfop_id ( en_cd => en_cfop );
   --
   vn_fase := 5;
   --
   if nvl(est_ct_reg_anal.cfop_id,0) <= 0 then
      --
      vn_fase := 5.1;
      --
      gv_mensagem_log := '"CFOP" inv�lido (' || en_cfop || ').';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 6;
   --
   if nvl(est_ct_reg_anal.aliq_icms,0) < 0 then
      --
      vn_fase := 6.1;
      --
      gv_mensagem_log := '"Al�quota de ICMS" n�o pode ser negativa.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 7;
   --
   begin
     select c.dm_tp_cte
       into vn_dm_tp_cte
       from conhec_transp c
      where c.id = est_ct_reg_anal.conhectransp_id;
   exception
     when others then
       vn_dm_tp_cte := 0;
   end;
   --
   if (nvl(est_ct_reg_anal.vl_opr,0) <= 0 and vn_dm_tp_cte in (0, 3)) then
      --
      vn_fase := 7.1;
      --
      gv_mensagem_log := '"Valor da opera��o" n�o pode ser negativa ou zero (0).';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 8;
   --
   if nvl(est_ct_reg_anal.vl_bc_icms,0) < 0 then
      --
      vn_fase := 8.1;
      --
      gv_mensagem_log := '"Valor da base de c�lculo do ICMS" n�o pode ser negativa.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 9;
   --
   if nvl(est_ct_reg_anal.vl_icms,0) < 0 then
      --
      vn_fase := 9.1;
      --
      gv_mensagem_log := '"Valor do ICMS" n�o pode ser negativa.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 10;
   --
   if nvl(est_ct_reg_anal.vl_red_bc,0) < 0 then
      --
      vn_fase := 10.1;
      --
      gv_mensagem_log := '"Valor n�o tributado em fun��o da redu��o da base de c�lculo do ICMS" n�o pode ser negativa.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 10.2;
   -- Valida��o D190: O Campo Valor de Redu��o do ICMS s� pode ser preenchido
   -- se o c�digo da situa��o tribut�ria igual 20 ou 70.
   if  trim(ev_cod_st) not in ('20', '70') and
       nvl(est_ct_reg_anal.vl_red_bc, 0) > 0  then
       --
       vn_fase := 10.3;
       --
       gv_mensagem_log := 'O "Valor de Redu��o Base de ICMS" (' || est_ct_reg_anal.vl_red_bc || ') no Anal�tico de Impostos' ||
                         ' s� pode ser informada quando o C�digo da Situa��o Tribut�ria do ICMS for igual a 20 ou 70.';
       --
       vn_loggenerico_id := null;
       --
       pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                         , ev_mensagem        => gv_cabec_log
                                         , ev_resumo          => gv_mensagem_log
                                         , en_tipo_log        => ERRO_DE_VALIDACAO
                                         , en_referencia_id   => gn_referencia_id
                                         , ev_obj_referencia  => gv_obj_referencia );
       --
       -- Armazena o "loggenerico_id" na mem�ria
       pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                            , est_log_generico  => est_log_generico );
       --
   end if;
   --
   vn_fase := 11;
   --
   vn_obslanctofiscal_id := pk_csf.fkg_id_obs_lancto_fiscal ( en_multorg_id => en_multorg_id
                                                            , ev_cod_obs    => ev_cod_obs );
   --
   vn_fase := 12;
   --
   if nvl(vn_obslanctofiscal_id,0) <= 0 and trim(ev_cod_obs) is not null then
      --
      vn_fase := 12.1;
      --
      gv_mensagem_log := '"C�digo da observa��o do lan�amento fiscal" inv�lido (' || ev_cod_obs || ').';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_ct_reg_anal.conhectransp_id,0) > 0
      and nvl(est_ct_reg_anal.codst_id,0) > 0
      and nvl(est_ct_reg_anal.cfop_id,0) > 0 then
      --
      vn_fase := 99.1;
      --
      if nvl(gn_tipo_integr,0) = 1 then
         --
   vn_fase := 99.2;
         --
         select ctreganal_seq.nextval
           into est_ct_reg_anal.id
           from dual;
         --
         vn_fase := 99.3;
         --
         insert into ct_reg_anal ( id
                                 , conhectransp_id
                                 , codst_id
                                 , cfop_id
                                 , dm_orig_merc
                                 , aliq_icms
                                 , vl_opr
                                 , vl_bc_icms
                                 , vl_icms
                                 , vl_red_bc
                                 , obslanctofiscal_id )
                          values ( est_ct_reg_anal.id
                                 , est_ct_reg_anal.conhectransp_id
                                 , est_ct_reg_anal.codst_id
                                 , est_ct_reg_anal.cfop_id
                                 , 0
                                 , est_ct_reg_anal.aliq_icms
                                 , nvl(est_ct_reg_anal.vl_opr,0)
                                 , nvl(est_ct_reg_anal.vl_bc_icms,0)
                                 , nvl(est_ct_reg_anal.vl_icms,0)
                                 , nvl(est_ct_reg_anal.vl_red_bc,0)
                                 , vn_obslanctofiscal_id );
      else
         --
         vn_fase := 99.4;
         --
         update ct_reg_anal
            set codst_id           =  est_ct_reg_anal.codst_id
              , cfop_id            =  est_ct_reg_anal.cfop_id
              , dm_orig_merc       =  0
              , aliq_icms          =  est_ct_reg_anal.aliq_icms
              , vl_opr             =  nvl(est_ct_reg_anal.vl_opr,0)
              , vl_bc_icms         =  nvl(est_ct_reg_anal.vl_bc_icms,0)
              , vl_icms            =  nvl(est_ct_reg_anal.vl_icms,0)
              , vl_red_bc          =  nvl(est_ct_reg_anal.vl_red_bc,0)
              , obslanctofiscal_id =  vn_obslanctofiscal_id
          where id = est_ct_reg_anal.id;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_d100.pkb_integr_ct_d190 fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_mensagem_log
                                           , ev_resumo          => null
                                           , en_tipo_log        => ERRO_DE_SISTEMA
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_ct_d190;
-------------------------------------------------------------------------------------------------------
--| Procedimento integra o imposto PIS do Conhecimento de Transporte - Campos Flex Field
-------------------------------------------------------------------------------------------------------
procedure pkb_integr_ctcompdocpisefd_ff ( est_log_generico   in out nocopy dbms_sql.number_table
                                        , en_ctcompdocpis_id in            ct_comp_doc_pis.id%type
                                        , ev_atributo        in            varchar2
                                        , ev_valor           in            varchar2
                                        , en_multorg_id      in            mult_org.id%type )
is
   --
   vn_fase             number := 0;
   vn_loggenerico_id   log_generico_ct.id%type;
   vv_mensagem         varchar2(1000) := null;
   vn_dmtipocampo      ff_obj_util_integr.dm_tipo_campo%type;
   vn_cod_nat_rec_pc   nat_rec_pc.cod%type := 0;
   vn_codst_id         cod_st.id%type := 0;
   vn_natrecpc_id      nat_rec_pc.id%type := 0;
   --
begin
   --
   vn_fase := 1;
   --
   gv_mensagem_log := null;
   --
   if trim(ev_atributo) is null then
      --
      vn_fase := 2;
      --
      gv_mensagem_log := 'Complemento do Documento de Transporte - PIS/PASEP: "Atributo" deve ser informado.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => erro_de_validacao
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                           , est_log_generico => est_log_generico );
      --
   end if;
   --
   vn_fase := 3;
   --
   if trim(ev_valor) is null then
      --
      vn_fase := 4;
      --
      gv_mensagem_log := 'Complemento do Documento de Transporte - PIS/PASEP: "VALOR" referente ao atributo deve ser informado.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => erro_de_validacao
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 5;
   --
   vv_mensagem := pk_csf.fkg_ff_verif_campos( ev_obj_name => 'VW_CSF_CTCOMPDOCPIS_EFD_FF'
                                            , ev_atributo => trim(ev_atributo)
                                            , ev_valor    => trim(ev_valor) );
   --
   vn_fase := 6;
   --
   if vv_mensagem is not null then
      --
      vn_fase := 7;
      --
      gv_mensagem_log := vv_mensagem;
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => erro_de_validacao
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   else
      --
      vn_fase := 8;
      --
      vn_dmtipocampo := pk_csf.fkg_ff_retorna_dmtipocampo( ev_obj_name => 'VW_CSF_CTCOMPDOCPIS_EFD_FF'
                                                         , ev_atributo => trim(ev_atributo) );
      --
      vn_fase := 9;
      --
      if trim(ev_atributo) = 'COD_NAT_REC_PC' then
         --
         vn_fase := 10;
         --
         if trim(ev_valor) is not null then
            --
            vn_fase := 11;
            --
            if vn_dmtipocampo = 1 then -- tipo de campo = 0-data, 1-num�rico, 2-caractere
               --
               vn_fase := 12;
               --
               if trim(ev_atributo) = 'COD_NAT_REC_PC' then
                  --
                  vn_fase := 13;
                  --
                  begin
                     vn_cod_nat_rec_pc := pk_csf.fkg_ff_ret_vlr_number( ev_obj_name => 'VW_CSF_CTCOMPDOCPIS_EFD_FF'
                                                                      , ev_atributo => trim(ev_atributo)
                                                                      , ev_valor    => trim(ev_valor) );
                  exception
                     when others then
                        vn_cod_nat_rec_pc := null;
                  end;
                  --
                  vn_fase := 14;
                  --
                  begin
                     select cc.codst_id
                       into vn_codst_id
                       from ct_comp_doc_pis cc
                      where cc.id = en_ctcompdocpis_id;
                  exception
                     when others then
                        vn_codst_id := 0;
                  end;
                  --
                  vn_fase := 15;
                  --
                  begin
                     vn_natrecpc_id := pk_csf_efd_pc.fkg_codst_id_nat_rec_pc ( en_multorg_id        => en_multorg_id
                                                                             , en_natrecpc_codst_id => vn_codst_id
                                                                             , en_natrecpc_cod      => vn_cod_nat_rec_pc );
                  exception
                     when others then
                        vn_natrecpc_id := null;
                  end;
                  --
               end if;
               --
               vn_fase := 16;
               --
               if trim(ev_atributo) = 'COD_NAT_REC_PC' and
                  nvl(vn_natrecpc_id,0) <= 0 then
                  --
                  vn_fase := 17;
                  --
                  gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR ('||ev_valor||') informado est� inv�lido.';
                  --
                  vn_loggenerico_id := null;
                  --
                  pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                                    , ev_mensagem       => gv_cabec_log
                                                    , ev_resumo         => gv_mensagem_log
                                                    , en_tipo_log       => erro_de_validacao
                                                    , en_referencia_id  => gn_referencia_id
                                                    , ev_obj_referencia => gv_obj_referencia );
                  --
                  -- Armazena o "loggenerico_id" na mem�ria
                  pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                                       , est_log_generico => est_log_generico );
                  --
               end if;
               --
            else
               --
               vn_fase := 18;
               --
               gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR informado n�o confere com o tipo de campo, deveria ser NUM�RICO.';
               --
               vn_loggenerico_id := null;
               --
               pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                                 , ev_mensagem       => gv_cabec_log
                                                 , ev_resumo         => gv_mensagem_log
                                                 , en_tipo_log       => erro_de_validacao
                                                 , en_referencia_id  => gn_referencia_id
                                                 , ev_obj_referencia => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na mem�ria
               pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                                    , est_log_generico => est_log_generico );
               --
            end if;
            --
         else
            --
            vn_fase := 19;
            --
            gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR deve ser maior do que zero (0).';
            --
            vn_loggenerico_id := null;
            --
            pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                              , ev_mensagem       => gv_cabec_log
                                              , ev_resumo         => gv_mensagem_log
                                              , en_tipo_log       => erro_de_validacao
                                              , en_referencia_id  => gn_referencia_id
                                              , ev_obj_referencia => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na mem�ria
            pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                                 , est_log_generico => est_log_generico );
            --
         end if;
      else
         --
         vn_fase := 20;
         --
         gv_mensagem_log := '"Atributo" ('||ev_atributo||') e "VALOR" ('||ev_valor||') relacionados, n�o especificados no processo.';
         --
         vn_loggenerico_id := null;
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => ERRO_DE_VALIDACAO
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                              , est_log_generico  => est_log_generico );
         --
      end if;
      --
   end if;
   --
   vn_fase := 21;
   --
   if nvl(en_ctcompdocpis_id,0) = 0 then
      --
      vn_fase := 22;
      --
      gv_mensagem_log := 'Identificador do imposto do conhecimento de transporte n�o informado.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => erro_de_validacao
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(en_ctcompdocpis_id,0) > 0 and
      ev_atributo = 'COD_NAT_REC_PC' and
      vn_natrecpc_id is not null and
      gv_mensagem_log is null then
      --
      vn_fase := 99.1;
      --
      update ct_comp_doc_pis cc
         set cc.natrecpc_id = vn_natrecpc_id
       where cc.id = en_ctcompdocpis_id;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_d100.pkb_integr_ctcompdocpisefd_ff fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_mensagem_log
                                           , ev_resumo          => null
                                           , en_tipo_log        => erro_de_sistema
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_ctcompdocpisefd_ff;
-------------------------------------------------------------------------------------------------------
--| Procedimento integra o complemento da opera��o de PIS/PASEP
-------------------------------------------------------------------------------------------------------
procedure pkb_integr_ctcompdoc_pisefd ( est_log_generico      in out nocopy  dbms_sql.number_table
                                      , est_ctcompdoc_pisefd  in out nocopy  ct_comp_doc_pis%rowtype
                                      , ev_cpf_cnpj_emit      in             varchar2
                                      , ev_cod_st             in             cod_st.cod_st%type
                                      , ev_cod_bc_cred_pc     in             base_calc_cred_pc.cd%type
                                      , ev_cod_cta            in             plano_conta.cod_cta%type
                                      , en_multorg_id         in             mult_org.id%type )
is
   --
   vn_fase           number := 0;
   vn_loggenerico_id log_generico_ct.id%TYPE;
   vn_empresa_id     empresa.id%type;
   vv_descr          varchar2(1000) := null;
   vn_dm_valida_pis  empresa.dm_valida_pis%type;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(est_ctcompdoc_pisefd.conhectransp_id,0) <= 0 then
      --
      vn_fase := 1.1;
      --
      gv_mensagem_log := 'N�o informado o relacionamento entre o Resumo de Impostos e o Conhecimento de Transportes (PIS).';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 2;
   --
   -- Verifica se o conhecimento de transporte � de terceiros
   if nvl(fkg_dmindemit_conhectransp(est_ctcompdoc_pisefd.conhectransp_id), 0) = 1 then
     --
     if (ev_cod_st not between 50 and 56) and
        (ev_cod_st not between 60 and 66) and
        (ev_cod_st not between 70 and 75) and
        (ev_cod_st not between 98 and 99) then
       --
       vn_fase := 2.1;
       --
       gv_mensagem_log := '"C�digo da Situa��o Tribut�ria" inv�lido (' || ev_cod_st || ') deve estar entre 50 e 56, 60 e 66, 70 e 75, 98 e 99, para o tipo de imposto PIS.';
       --
       vn_loggenerico_id := null;
       --
       pk_csf_api_ct.pkb_log_generico_ct(sn_loggenerico_id => vn_loggenerico_id,
                                         ev_mensagem       => gv_cabec_log,
                                         ev_resumo         => gv_mensagem_log,
                                         en_tipo_log       => ERRO_DE_VALIDACAO,
                                         en_referencia_id  => gn_referencia_id,
                                         ev_obj_referencia => gv_obj_referencia);
       --
       -- Armazena o "loggenerico_id" na mem�ria
       pk_csf_api_ct.pkb_gt_log_generico_ct(en_loggenerico   => vn_loggenerico_id,
                                            est_log_generico => est_log_generico);
       -- 
     end if;
     --
   -- Verifica se o conhecimento de transporte � de emiss�o pr�pria
   else
     --
     if (ev_cod_st not in ('01', '02', '03', '04', '05', '06', '07', '08', '09', '49')) then
       --
       vn_fase := 2.2;
       --
       gv_mensagem_log := '"C�digo da Situa��o Tribut�ria" inv�lido (' || ev_cod_st || ') deve estar entre 01 e 09, ou 49, para o tipo de imposto PIS.';
       --
       vn_loggenerico_id := null;
       --
       pk_csf_api_ct.pkb_log_generico_ct(sn_loggenerico_id => vn_loggenerico_id,
                                         ev_mensagem       => gv_cabec_log,
                                         ev_resumo         => gv_mensagem_log,
                                         en_tipo_log       => ERRO_DE_VALIDACAO,
                                         en_referencia_id  => gn_referencia_id,
                                         ev_obj_referencia => gv_obj_referencia);
       --
       -- Armazena o "loggenerico_id" na mem�ria
       pk_csf_api_ct.pkb_gt_log_generico_ct(en_loggenerico   => vn_loggenerico_id,
                                            est_log_generico => est_log_generico);
       --
     end if;
     --
   end if;
   --
   vn_fase := 3;
   --
   est_ctcompdoc_pisefd.codst_id := pk_csf.fkg_cod_st_id ( ev_cod_st      => ev_cod_st
                                                         , en_tipoimp_id  => pk_csf.fkg_Tipo_Imposto_id ( 4 ) ); -- PIS
   --
   vn_fase := 4;
   --
   if nvl(est_ctcompdoc_pisefd.codst_id,0) <= 0 then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := '"C�digo da situa��o Tribut�ria" inv�lido (' || ev_cod_st || ') para o tipo de imposto PIS.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 5;
   --
   if ev_cod_bc_cred_pc not between '01' and '18' then
      --
      vn_fase := 5.1;
      --
      gv_mensagem_log := '"C�digo da Base de C�lculo do Cr�dito" inv�lido (' || ev_cod_bc_cred_pc || ') deve estar entre 01 e 18 (PIS).';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 5.2;
   --
   -- Recupera se valida ou n�o pis                       
   vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id => en_multorg_id
                                                        , ev_cpf_cnpj   => ev_cpf_cnpj_emit );
   -- 
   if fkg_dmindemit_conhectransp ( en_conhectransp_id => est_ctcompdoc_pisefd.conhectransp_id ) = 0 then -- emiss�o pr�pria
      --
      vn_dm_valida_pis := pk_csf.fkg_empresa_dmvalpis_emis ( en_empresa_id => vn_empresa_id );
      --
   elsif fkg_dmindemit_conhectransp ( en_conhectransp_id => est_ctcompdoc_pisefd.conhectransp_id  ) = 1 then -- terceiros
      --
      vn_dm_valida_pis := pk_csf.fkg_empresa_dmvalpis_terc ( en_empresa_id => vn_empresa_id );
      --
   else
      --
      vn_dm_valida_pis := 1; -- sim
      --
   end if;
   --
   vn_fase := 5.3;
   --
   if (ev_cod_st between 50 and 56) or
      (ev_cod_st between 60 and 66) then
      if nvl(est_ctcompdoc_pisefd.basecalccredpc_id,0) = 0 and -- base de credito n�o informada
         vn_dm_valida_pis = 1 and  -- valida pis
         nvl(est_ctcompdoc_pisefd.vl_bc_pis,0) > 0 and
         nvl(est_ctcompdoc_pisefd.aliq_pis,0) > 0 then
         --
         gv_mensagem_log := '"C�digo da Base de C�lculo do Cr�dito" para PIS n�o informada e existe base e aliquota para o conhecimento.';
         --
         vn_loggenerico_id := null;
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => INFORMACAO
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                              , est_log_generico  => est_log_generico );
         --         
      end if;  
      --
   end if;  
   --
   vn_fase := 6;
   --
   est_ctcompdoc_pisefd.basecalccredpc_id := pk_csf_efd_pc.fkg_base_calc_cred_pc_id ( ev_cd => ev_cod_bc_cred_pc );
   --
   vn_fase := 7;
   --
   if nvl(est_ctcompdoc_pisefd.basecalccredpc_id,0) <= 0 and ev_cod_bc_cred_pc is not null then
      --
      vn_fase := 7.1;
      --
      gv_mensagem_log := '"C�digo da Base de C�lculo do Cr�dito" inv�lido (' || ev_cod_bc_cred_pc || ') (PIS).';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 8;
   --
   vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id => en_multorg_id
                                                        , ev_cpf_cnpj   => ev_cpf_cnpj_emit );
   --
   vn_fase := 9;
   --
   est_ctcompdoc_pisefd.planoconta_id := pk_csf.fkg_plano_conta_id ( ev_cod_cta    => ev_cod_cta
                                                                   , en_empresa_id => vn_empresa_id );
   --
   vn_fase := 10;
   --
   if nvl(est_ctcompdoc_pisefd.planoconta_id,0) <= 0 and ev_cod_cta is not null then
      --
      vn_fase := 10.1;
      --
      gv_mensagem_log := '"C�digo da conta anal�tica cont�bil debitada/creditada" inv�lido (' || ev_cod_cta || ') (PIS).';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 11;
   --
   if est_ctcompdoc_pisefd.dm_ind_nat_frt not in (0,1,2,3,4,5,9) then
      --
      vn_fase := 11.1;
      --
      gv_mensagem_log := '"Indicador da Natureza do Frete Contratado" inv�lido (' || est_ctcompdoc_pisefd.dm_ind_nat_frt || ') deve estar entre 0 e 5 ou 9 (PIS).';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 12;
   --
   if est_ctcompdoc_pisefd.dm_ind_nat_frt in (0,1,2,3,4,5,9) then
      vv_descr := pk_csf.fkg_dominio ( ev_dominio => 'CT_COMP_DOC_PIS.DM_IND_NAT_FRT'
                                     , ev_vl      => est_ctcompdoc_pisefd.dm_ind_nat_frt );
      --
      vn_fase := 13;
      --
      if vv_descr is null then
         --
         vn_fase := 13.1;
         --
         gv_mensagem_log := '"Indicador da Natureza do Frete Contratado" inv�lido (' || est_ctcompdoc_pisefd.dm_ind_nat_frt || ') (PIS).';
         --
         vn_loggenerico_id := null;
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => ERRO_DE_VALIDACAO
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                              , est_log_generico  => est_log_generico );
         --
      end if;
   end if;
   --
   vn_fase := 14;
   --
   if nvl(est_ctcompdoc_pisefd.vl_item,0) < 0 then
      --
      vn_fase := 14.1;
      --
      gv_mensagem_log := '"Valor total dos itens" n�o pode ser negativo (PIS).';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 15;
   --
   if nvl(est_ctcompdoc_pisefd.vl_bc_pis,0) < 0 then
      --
      vn_fase := 15.1;
      --
      gv_mensagem_log := '"Valor da base de c�lculo do PIS/PASEP" n�o pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 16;
   --
   if nvl(est_ctcompdoc_pisefd.aliq_pis,0) < 0 then
      --
      vn_fase := 16.1;
      --
      gv_mensagem_log := '"Al�quota do PIS/PASEP (em percentual)" n�o pode ser negativa.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 17;
   --
   if nvl(est_ctcompdoc_pisefd.vl_pis,0) < 0 then
      --
      vn_fase := 17.1;
      --
      gv_mensagem_log := '"Valor do PIS/PASEP" n�o pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_ctcompdoc_pisefd.conhectransp_id,0) > 0
      and est_ctcompdoc_pisefd.dm_ind_nat_frt in (0,1,2,3,4,5,9)
      and est_ctcompdoc_pisefd.vl_item is not null
      and nvl(est_ctcompdoc_pisefd.codst_id,0) > 0 then
      --
      vn_fase := 99.1;
      --
      if nvl(gn_tipo_integr,0) = 1 then
         --
         vn_fase := 99.2;
         --
         select ctcompdocpis_seq.nextval
           into est_ctcompdoc_pisefd.id
           from dual;
         --
         vn_fase := 99.3;
         --
         insert into ct_comp_doc_pis ( id
                                     , conhectransp_id
                                     , dm_ind_nat_frt
                                     , vl_item
                                     , codst_id
                                     , basecalccredpc_id
                                     , vl_bc_pis
                                     , aliq_pis
                                     , vl_pis
                                     , planoconta_id )
                              values ( est_ctcompdoc_pisefd.id
                                     , est_ctcompdoc_pisefd.conhectransp_id
                                     , est_ctcompdoc_pisefd.dm_ind_nat_frt
                                     , est_ctcompdoc_pisefd.vl_item
                                     , est_ctcompdoc_pisefd.codst_id
                                     , est_ctcompdoc_pisefd.basecalccredpc_id
                                     , est_ctcompdoc_pisefd.vl_bc_pis
                                     , est_ctcompdoc_pisefd.aliq_pis
                                     , est_ctcompdoc_pisefd.vl_pis
                                     , est_ctcompdoc_pisefd.planoconta_id );
         --
      else
         --
         vn_fase := 99.4;
         --
         update ct_comp_doc_pis
            set dm_ind_nat_frt      = est_ctcompdoc_pisefd.dm_ind_nat_frt
              , vl_item             = est_ctcompdoc_pisefd.vl_item
              , codst_id            = est_ctcompdoc_pisefd.codst_id
              , basecalccredpc_id   = est_ctcompdoc_pisefd.basecalccredpc_id
              , vl_bc_pis           = est_ctcompdoc_pisefd.vl_bc_pis
              , aliq_pis            = est_ctcompdoc_pisefd.aliq_pis
              , vl_pis              = est_ctcompdoc_pisefd.vl_pis
              , planoconta_id       = est_ctcompdoc_pisefd.planoconta_id
          where id = est_ctcompdoc_pisefd.id;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_d100.pkb_integr_ctcompdoc_pisefd fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_mensagem_log
                                           , ev_resumo          => null
                                           , en_tipo_log        => ERRO_DE_SISTEMA
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_ctcompdoc_pisefd;
-------------------------------------------------------------------------------------------------------
--| Procedimento integra o imposto COFINS do Conhecimento de Transporte - Campos Flex Field
-------------------------------------------------------------------------------------------------------
procedure pkb_integr_ctcompdoccofefd_ff ( est_log_generico      in out nocopy dbms_sql.number_table
                                        , en_ctcompdoccofins_id in            ct_comp_doc_cofins.id%type
                                        , ev_atributo           in            varchar2
                                        , ev_valor              in            varchar2
                                        , en_multorg_id         in            mult_org.id%type )
is
   --
   vn_fase             number := 0;
   vn_loggenerico_id   log_generico_ct.id%type;
   vv_mensagem         varchar2(1000) := null;
   vn_dmtipocampo      ff_obj_util_integr.dm_tipo_campo%type;
   vn_cod_nat_rec_pc   nat_rec_pc.cod%type := 0;
   vn_codst_id         cod_st.id%type := 0;
   vn_natrecpc_id      nat_rec_pc.id%type := 0;
   --
begin
   --
   vn_fase := 1;
   --
   gv_mensagem_log := null;
   --
   if trim(ev_atributo) is null then
      --
      vn_fase := 2;
      --
      gv_mensagem_log := 'Complemento do Documento de Transporte - COFINS: "Atributo" deve ser informado.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => erro_de_validacao
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                           , est_log_generico => est_log_generico );
      --
   end if;
   --
   vn_fase := 3;
   --
   if trim(ev_valor) is null then
      --
      vn_fase := 4;
      --
      gv_mensagem_log := 'Complemento do Documento de Transporte - COFINS: "VALOR" referente ao atributo deve ser informado.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => erro_de_validacao
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 5;
   --
   vv_mensagem := pk_csf.fkg_ff_verif_campos( ev_obj_name => 'VW_CSF_CTCOMPDOCCOFINS_EFD_FF'
                                            , ev_atributo => trim(ev_atributo)
                                            , ev_valor    => trim(ev_valor) );
   --
   vn_fase := 6;
   --
   if vv_mensagem is not null then
      --
      vn_fase := 7;
      --
      gv_mensagem_log := vv_mensagem;
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => erro_de_validacao
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   else
      --
      vn_fase := 8;
      --
      vn_dmtipocampo := pk_csf.fkg_ff_retorna_dmtipocampo( ev_obj_name => 'VW_CSF_CTCOMPDOCCOFINS_EFD_FF'
                                                         , ev_atributo => trim(ev_atributo) );
      --
      vn_fase := 9;
      --
      if trim(ev_atributo) = 'COD_NAT_REC_PC' then
         --
         vn_fase := 10;
         --
         if trim(ev_valor) is not null then
            --
            vn_fase := 11;
            --
            if vn_dmtipocampo = 1 then -- tipo de campo = 0-data, 1-num�rico, 2-caractere
               --
               vn_fase := 12;
               --
               if trim(ev_atributo) = 'COD_NAT_REC_PC' then
                  --
                  vn_fase := 13;
                  --
                  begin
                     vn_cod_nat_rec_pc := pk_csf.fkg_ff_ret_vlr_number( ev_obj_name => 'VW_CSF_CTCOMPDOCCOFINS_EFD_FF'
                                                                      , ev_atributo => trim(ev_atributo)
                                                                      , ev_valor    => trim(ev_valor) );
                  exception
                     when others then
                        vn_cod_nat_rec_pc := null;
                  end;
                  --
                  vn_fase := 14;
                  --
                  begin
                     select cc.codst_id
                       into vn_codst_id
                       from ct_comp_doc_cofins cc
                      where cc.id = en_ctcompdoccofins_id;
                  exception
                     when others then
                        vn_codst_id := 0;
                  end;
                  --
                  vn_fase := 15;
                  --
                  begin
                     vn_natrecpc_id := pk_csf_efd_pc.fkg_codst_id_nat_rec_pc ( en_multorg_id        => en_multorg_id
                                                                             , en_natrecpc_codst_id => vn_codst_id
                                                                             , en_natrecpc_cod      => vn_cod_nat_rec_pc );
                  exception
                     when others then
                        vn_natrecpc_id := null;
                  end;
                  --
               end if;
               --
               vn_fase := 16;
               --
               if trim(ev_atributo) = 'COD_NAT_REC_PC' and
                  nvl(vn_natrecpc_id,0) <= 0 then
                  --
                  vn_fase := 17;
                  --
                  gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR ('||ev_valor||') informado est� inv�lido.';
                  --
                  vn_loggenerico_id := null;
                  --
                  pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                                    , ev_mensagem       => gv_cabec_log
                                                    , ev_resumo         => gv_mensagem_log
                                                    , en_tipo_log       => erro_de_validacao
                                                    , en_referencia_id  => gn_referencia_id
                                                    , ev_obj_referencia => gv_obj_referencia );
                  --
                  -- Armazena o "loggenerico_id" na mem�ria
                  pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                                       , est_log_generico => est_log_generico );
                  --
               end if;
               --
            else
               --
               vn_fase := 18;
               --
               gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR informado n�o confere com o tipo de campo, deveria ser NUM�RICO.';
               --
               vn_loggenerico_id := null;
               --
               pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                                 , ev_mensagem       => gv_cabec_log
                                                 , ev_resumo         => gv_mensagem_log
                                                 , en_tipo_log       => erro_de_validacao
                                                 , en_referencia_id  => gn_referencia_id
                                                 , ev_obj_referencia => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na mem�ria
               pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                                    , est_log_generico => est_log_generico );
               --
            end if;
            --
         else
            --
            vn_fase := 19;
            --
            gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR deve ser maior do que zero (0).';
            --
            vn_loggenerico_id := null;
            --
            pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                              , ev_mensagem       => gv_cabec_log
                                              , ev_resumo         => gv_mensagem_log
                                              , en_tipo_log       => erro_de_validacao
                                              , en_referencia_id  => gn_referencia_id
                                              , ev_obj_referencia => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na mem�ria
            pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                                 , est_log_generico => est_log_generico );
            --
         end if;
      else
         --
         vn_fase := 20;
         --
         gv_mensagem_log := '"Atributo" ('||ev_atributo||') e "VALOR" ('||ev_valor||') relacionados, n�o especificados no processo.';
         --
         vn_loggenerico_id := null;
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => ERRO_DE_VALIDACAO
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                              , est_log_generico  => est_log_generico );
         --
      end if;
      --
   end if;
   --
   vn_fase := 21;
   --
   if nvl(en_ctcompdoccofins_id,0) = 0 then
      --
      vn_fase := 22;
      --
      gv_mensagem_log := 'Identificador do imposto do conhecimento de transporte n�o informado.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => erro_de_validacao
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(en_ctcompdoccofins_id,0) > 0 and
      ev_atributo = 'COD_NAT_REC_PC' and
      vn_natrecpc_id is not null and
      gv_mensagem_log is null then
      --
      vn_fase := 99.1;
      --
      update ct_comp_doc_cofins cc
         set cc.natrecpc_id = vn_natrecpc_id
       where cc.id = en_ctcompdoccofins_id;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_d100.pkb_integr_ctcompdoccofefd_ff fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_mensagem_log
                                           , ev_resumo          => null
                                           , en_tipo_log        => ERRO_DE_SISTEMA
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_ctcompdoccofefd_ff;
-------------------------------------------------------------------------------------------------------
--| Procedimento integra o complemento da opera��o de COFINS
-------------------------------------------------------------------------------------------------------
procedure pkb_integr_ctcompdoc_cofinsefd ( est_log_generico        in out nocopy  dbms_sql.number_table
                                         , est_ctcompdoc_cofinsefd in out nocopy  ct_comp_doc_cofins%rowtype
                                         , ev_cpf_cnpj_emit        in             varchar2
                                         , ev_cod_st               in             cod_st.cod_st%type
                                         , ev_cod_bc_cred_pc       in             base_calc_cred_pc.cd%type
                                         , ev_cod_cta              in             plano_conta.cod_cta%type
                                         , en_multorg_id           in             mult_org.id%type )
is
   --
   vn_fase              number := 0;
   vn_loggenerico_id    log_generico_ct.id%TYPE;
   vn_empresa_id        empresa.id%type;
   vv_descr             varchar2(1000) := null;
   vn_dm_valida_cofins  empresa.dm_valida_cofins%type;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(est_ctcompdoc_cofinsefd.conhectransp_id,0) <= 0 then
      --
      vn_fase := 1.1;
      --
      gv_mensagem_log := 'N�o informado o relacionamento entre o Resumo de Impostos e o Conhecimento de Transportes (COFINS).';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 2;
   --
   -- Verifica se o conhecimento de transporte � de terceiros
   if nvl(fkg_dmindemit_conhectransp(est_ctcompdoc_cofinsefd.conhectransp_id), 0) = 1 then
     --
     if (ev_cod_st not between 50 and 56) and
        (ev_cod_st not between 60 and 66) and
        (ev_cod_st not between 70 and 75) and
        (ev_cod_st not between 98 and 99) then
       --
       vn_fase := 2.1;
       --
       gv_mensagem_log := '"C�digo da Situa��o Tribut�ria" inv�lido (' || ev_cod_st || ') deve estar entre 50 e 56, 60 e 66, 70 e 75, 98 e 99, para o tipo de imposto COFINS.';
       --
       vn_loggenerico_id := null;
       --
       pk_csf_api_ct.pkb_log_generico_ct(sn_loggenerico_id => vn_loggenerico_id,
                                         ev_mensagem       => gv_cabec_log,
                                         ev_resumo         => gv_mensagem_log,
                                         en_tipo_log       => ERRO_DE_VALIDACAO,
                                         en_referencia_id  => gn_referencia_id,
                                         ev_obj_referencia => gv_obj_referencia);
       --
       -- Armazena o "loggenerico_id" na mem�ria
       pk_csf_api_ct.pkb_gt_log_generico_ct(en_loggenerico   => vn_loggenerico_id,
                                            est_log_generico => est_log_generico);
       --
     end if;
     --
   -- Verifica se o conhecimento de transporte � de emiss�o pr�pria
   else
     --
     if (ev_cod_st not in ('01', '02', '03', '04', '05', '06', '07', '08', '09', '49')) then
       --
       vn_fase := 2.2;
       --
       gv_mensagem_log := '"C�digo da Situa��o Tribut�ria" inv�lido (' || ev_cod_st || ') deve estar entre 01 e 09, ou 49, para o tipo de imposto COFINS.';
       --
       vn_loggenerico_id := null;
       --
       pk_csf_api_ct.pkb_log_generico_ct(sn_loggenerico_id => vn_loggenerico_id,
                                         ev_mensagem       => gv_cabec_log,
                                         ev_resumo         => gv_mensagem_log,
                                         en_tipo_log       => ERRO_DE_VALIDACAO,
                                         en_referencia_id  => gn_referencia_id,
                                         ev_obj_referencia => gv_obj_referencia);
       --
       -- Armazena o "loggenerico_id" na mem�ria
       pk_csf_api_ct.pkb_gt_log_generico_ct(en_loggenerico   => vn_loggenerico_id,
                                            est_log_generico => est_log_generico);
     end if;
     --
   end if;
   --
   vn_fase := 3;
   --
   est_ctcompdoc_cofinsefd.codst_id := pk_csf.fkg_cod_st_id ( ev_cod_st      => ev_cod_st
                                                            , en_tipoimp_id  => pk_csf.fkg_Tipo_Imposto_id ( 5 ) ); -- COFINS
   --
   vn_fase := 4;
   --
   if nvl(est_ctcompdoc_cofinsefd.codst_id,0) <= 0 then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := '"C�digo da situa��o Tribut�ria" inv�lido (' || ev_cod_st || ') para o tipo de imposto COFINS.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 5;
   --
   if ev_cod_bc_cred_pc not between '01' and '18' then
      --
      vn_fase := 5.1;
      --
      gv_mensagem_log := '"C�digo da Base de C�lculo do Cr�dito" inv�lido (' || ev_cod_bc_cred_pc || ') deve estar entre 01 e 18 (COFINS).';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 5.2;
   --   
   -- Recupera se valida ou n�o cofins                       
   vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id => en_multorg_id
                                                        , ev_cpf_cnpj   => ev_cpf_cnpj_emit );
   --   
   if fkg_dmindemit_conhectransp ( en_conhectransp_id => est_ctcompdoc_cofinsefd.conhectransp_id ) = 0 then -- emiss�o pr�pria
      --
      vn_dm_valida_cofins := pk_csf.fkg_empresa_dmvalcofins_emis ( en_empresa_id => vn_empresa_id );
      --
   elsif fkg_dmindemit_conhectransp ( en_conhectransp_id => est_ctcompdoc_cofinsefd.conhectransp_id  ) = 1 then -- terceiros
      --
      vn_dm_valida_cofins := pk_csf.fkg_empresa_dmvalcofins_terc ( en_empresa_id => vn_empresa_id );
      --
   else
      --
      vn_dm_valida_cofins := 1; -- sim
      --
   end if;
   --
   vn_fase := 5.3;
   --
   if (ev_cod_st between 50 and 56) or
      (ev_cod_st between 60 and 66) then
      if nvl(est_ctcompdoc_cofinsefd.basecalccredpc_id,0) = 0 and -- base de credito n�o informada
         vn_dm_valida_cofins = 1 and  -- valida cofins
         nvl(est_ctcompdoc_cofinsefd.vl_bc_cofins,0) > 0 and
         nvl(est_ctcompdoc_cofinsefd.aliq_cofins,0) > 0 then
         --
         gv_mensagem_log := '"C�digo da Base de C�lculo do Cr�dito" para COFINS n�o informada e existe base e aliquota para o conhecimento.';
         --
         vn_loggenerico_id := null;
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => INFORMACAO
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                              , est_log_generico  => est_log_generico );
         --         
      end if;  
      --
   end if;  
   --
   vn_fase := 6;
   --
   est_ctcompdoc_cofinsefd.basecalccredpc_id := pk_csf_efd_pc.fkg_base_calc_cred_pc_id ( ev_cd => ev_cod_bc_cred_pc );
   --
   vn_fase := 7;
   --
   if nvl(est_ctcompdoc_cofinsefd.basecalccredpc_id,0) <= 0 and ev_cod_bc_cred_pc is not null then
      --
      vn_fase := 7.1;
      --
      gv_mensagem_log := '"C�digo da Base de C�lculo do Cr�dito" inv�lido (' || ev_cod_bc_cred_pc || ') (COFINS).';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 8;
   --
   vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id => en_multorg_id
                                                        , ev_cpf_cnpj   => ev_cpf_cnpj_emit );
   --
   vn_fase := 9;
   --
   est_ctcompdoc_cofinsefd.planoconta_id := pk_csf.fkg_plano_conta_id ( ev_cod_cta    => ev_cod_cta
                                                                      , en_empresa_id => vn_empresa_id );
   --
   vn_fase := 10;
   --
   if nvl(est_ctcompdoc_cofinsefd.planoconta_id,0) <= 0 and ev_cod_cta is not null then
      --
      vn_fase := 10.1;
      --
      gv_mensagem_log := '"C�digo da conta anal�tica cont�bil debitada/creditada" inv�lido (' || ev_cod_cta || ') (COFINS).';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 11;
   --
   if est_ctcompdoc_cofinsefd.dm_ind_nat_frt not in (0,1,2,3,4,5,9) then
      --
      vn_fase := 11.1;
      --
      gv_mensagem_log := '"Indicador da Natureza do Frete Contratado" inv�lido (' || est_ctcompdoc_cofinsefd.dm_ind_nat_frt || ') deve estar entre 0 e 5 ou 9 (COFINS).';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 12;
   --
   if est_ctcompdoc_cofinsefd.dm_ind_nat_frt in (0,1,2,3,4,5,9) then
      vv_descr := pk_csf.fkg_dominio ( ev_dominio => 'CT_COMP_DOC_COFINS.DM_IND_NAT_FRT'
                                     , ev_vl      => est_ctcompdoc_cofinsefd.dm_ind_nat_frt );
      --
      vn_fase := 13;
      --
      if vv_descr is null then
         --
         vn_fase := 13.1;
         --
         gv_mensagem_log := '"Indicador da Natureza do Frete Contratado" inv�lido (' || est_ctcompdoc_cofinsefd.dm_ind_nat_frt || ') (COFINS).';
         --
         vn_loggenerico_id := null;
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => ERRO_DE_VALIDACAO
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                              , est_log_generico  => est_log_generico );
         --
      end if;
   end if;
   --
   vn_fase := 14;
   --
   if nvl(est_ctcompdoc_cofinsefd.vl_item,0) < 0 then
      --
      vn_fase := 14.1;
      --
      gv_mensagem_log := '"Valor total dos itens" n�o pode ser negativo (COFINS).';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 15;
   --
   if nvl(est_ctcompdoc_cofinsefd.vl_bc_cofins,0) < 0 then
      --
      vn_fase := 15.1;
      --
      gv_mensagem_log := '"Valor da base de c�lculo do COFINS" n�o pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 16;
   --
   if nvl(est_ctcompdoc_cofinsefd.aliq_cofins,0) < 0 then
      --
      vn_fase := 16.1;
      --
      gv_mensagem_log := '"Al�quota do COFINS (em percentual)" n�o pode ser negativa.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 17;
   --
   if nvl(est_ctcompdoc_cofinsefd.vl_cofins,0) < 0 then
      --
      vn_fase := 17.1;
      --
      gv_mensagem_log := '"Valor do COFINS" n�o pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_ctcompdoc_cofinsefd.conhectransp_id,0) > 0
      and est_ctcompdoc_cofinsefd.dm_ind_nat_frt in (0,1,2,3,4,5,9)
      and est_ctcompdoc_cofinsefd.vl_item is not null
      and nvl(est_ctcompdoc_cofinsefd.codst_id,0) > 0 then
      --
      vn_fase := 99.1;
      --
      if nvl(gn_tipo_integr,0) = 1 then
         --
         vn_fase := 99.2;
         --
         select ctcompdoccofins_seq.nextval
           into est_ctcompdoc_cofinsefd.id
           from dual;
         --
         vn_fase := 99.3;
         --
         insert into ct_comp_doc_cofins ( id
                                        , conhectransp_id
                                        , dm_ind_nat_frt
                                        , vl_item
                                        , codst_id
                                        , basecalccredpc_id
                                        , vl_bc_cofins
                                        , aliq_cofins
                                        , vl_cofins
                                        , planoconta_id )
                                 values ( est_ctcompdoc_cofinsefd.id
                                        , est_ctcompdoc_cofinsefd.conhectransp_id
                                        , est_ctcompdoc_cofinsefd.dm_ind_nat_frt
                                        , est_ctcompdoc_cofinsefd.vl_item
                                        , est_ctcompdoc_cofinsefd.codst_id
                                        , est_ctcompdoc_cofinsefd.basecalccredpc_id
                                        , est_ctcompdoc_cofinsefd.vl_bc_cofins
                                        , est_ctcompdoc_cofinsefd.aliq_cofins
                                        , est_ctcompdoc_cofinsefd.vl_cofins
                                        , est_ctcompdoc_cofinsefd.planoconta_id );
         --
      else
         --
         vn_fase := 99.4;
         --
         update ct_comp_doc_cofins
            set dm_ind_nat_frt    = est_ctcompdoc_cofinsefd.dm_ind_nat_frt
              , vl_item           = est_ctcompdoc_cofinsefd.vl_item
              , codst_id          = est_ctcompdoc_cofinsefd.codst_id
              , basecalccredpc_id = est_ctcompdoc_cofinsefd.basecalccredpc_id
              , vl_bc_cofins      = est_ctcompdoc_cofinsefd.vl_bc_cofins
              , aliq_cofins       = est_ctcompdoc_cofinsefd.aliq_cofins
              , vl_cofins         = est_ctcompdoc_cofinsefd.vl_cofins
              , planoconta_id     = est_ctcompdoc_cofinsefd.planoconta_id
          where id = est_ctcompdoc_cofinsefd.id;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_d100.pkb_integr_ctcompdoc_cofinsefd fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_mensagem_log
                                           , ev_resumo          => null
                                           , en_tipo_log        => ERRO_DE_SISTEMA
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_ctcompdoc_cofinsefd;
--
--| Procedimento integra os impostos retidos - Campos Flex Field
-------------------------------------------------------------------------------------------------------
procedure pkb_integr_ctimpretefd_ff ( est_log_generico   in out nocopy dbms_sql.number_table
                                    , en_ctimpretefd_id  in            conhec_transp_imp_ret.id%type
                                    , ev_atributo        in            varchar2
                                    , ev_valor           in            varchar2
                                    , en_multorg_id      in            mult_org.id%type )
is
   --
   vn_fase             number := 0;
   vn_loggenerico_id   log_generico_ct.id%type;
   vv_mensagem         varchar2(1000) := null;
   vn_dmtipocampo      ff_obj_util_integr.dm_tipo_campo%type;
   vv_cd_tp_serv_reinf varchar(9) := null;
   vn_dm_ind_cprb      conhec_transp_imp_ret.dm_ind_cprb%type;
   vn_tiposervreinf_id tipo_serv_reinf.id%type;
   vv_descr             dominio.descr%type;
   --
begin
   --
   vn_fase := 1;
   --
   gv_mensagem_log := null;
   --
   if trim(ev_atributo) is null then
      --
      vn_fase := 2;
      --
      gv_mensagem_log := 'Complemento dos Impostos Retidos do Conhecimento de Transporte: "ATRIBUTO" deve ser informado.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => erro_de_validacao
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                           , est_log_generico => est_log_generico );
      --
   end if;
   --
   vn_fase := 3;
   --
   if trim(ev_valor) is null then
      --
      vn_fase := 4;
      --
      gv_mensagem_log := 'Complemento dos Impostos Retidos do Conhecimento de Transporte: "VALOR" referente ao atributo deve ser informado.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => erro_de_validacao
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 5;
   --
   vv_mensagem := pk_csf.fkg_ff_verif_campos( ev_obj_name => 'VW_CSF_CT_IMP_RET_EFD_FF'
                                            , ev_atributo => trim(ev_atributo)
                                            , ev_valor    => trim(ev_valor) );
   --
   vn_fase := 6;
   --
   if vv_mensagem is not null then
      --
      vn_fase := 7;
      --
      gv_mensagem_log := vv_mensagem;
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => erro_de_validacao
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   else
      --
      vn_fase := 8;
      --
      vn_dmtipocampo := pk_csf.fkg_ff_retorna_dmtipocampo( ev_obj_name => 'VW_CSF_CT_IMP_RET_EFD_FF'
                                                         , ev_atributo => trim(ev_atributo) );
      --
      vn_fase := 9;
      --
      -- Tratamento para o atributo => CD_TP_SERV_REINF
      -- ==============================================
      if trim(ev_atributo) = 'CD_TP_SERV_REINF' then
         --
         vn_fase := 10;
         --
         if trim(ev_valor) is not null then
            --
            vn_fase := 11;
            --
            if vn_dmtipocampo = 2 then -- tipo de campo = 0-data, 1-num�rico, 2-caractere
               --
               vn_fase := 12;
               --
               vv_cd_tp_serv_reinf := pk_csf.fkg_ff_ret_vlr_number ( ev_obj_name => 'VW_CSF_CT_IMP_RET_EFD_FF'
                                                                   , ev_atributo => trim(ev_atributo)
                                                                   , ev_valor    => trim(ev_valor) );
               --
               vn_tiposervreinf_id := pk_csf_reinf.fkg_tipo_serv_reinf_id ( ev_cd => (vv_cd_tp_serv_reinf) );
               --
               -- V�lida o c�digo do tipo de servi�o REINF
               if  vn_tiposervreinf_id is null then
                  --
                  vn_fase := 13;
                  --
                  gv_mensagem_log := 'O "C�digo do Tipo de Servi�o REINF" (' || vv_cd_tp_serv_reinf || ') est� inv�lido!';
                  --
                  vn_loggenerico_id := null;
                  --
                  pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                                    , ev_mensagem        => gv_cabec_log
                                                    , ev_resumo          => gv_mensagem_log
                                                    , en_tipo_log        => ERRO_DE_VALIDACAO
                                                    , en_referencia_id   => gn_referencia_id
                                                    , ev_obj_referencia  => gv_obj_referencia );
                  --
                  -- Armazena o "loggenerico_id" na mem�ria
                  pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                                       , est_log_generico  => est_log_generico );
                  --
               end if;
               --
            else
               --
               vn_fase := 14;
               --
               gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR informado n�o confere com o tipo de campo, deveria ser CARACTERE.';
               --
               vn_loggenerico_id := null;
               --
               pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                                 , ev_mensagem       => gv_cabec_log
                                                 , ev_resumo         => gv_mensagem_log
                                                 , en_tipo_log       => erro_de_validacao
                                                 , en_referencia_id  => gn_referencia_id
                                                 , ev_obj_referencia => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na mem�ria
               pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                                    , est_log_generico => est_log_generico );
               --
            end if;
            --
         else
            --
            vn_fase := 15;
            --
            gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR deve ser maior do que zero (0).';
            --
            vn_loggenerico_id := null;
            --
            pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                              , ev_mensagem       => gv_cabec_log
                                              , ev_resumo         => gv_mensagem_log
                                              , en_tipo_log       => erro_de_validacao
                                              , en_referencia_id  => gn_referencia_id
                                              , ev_obj_referencia => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na mem�ria
            pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                                 , est_log_generico => est_log_generico );
            --
         end if;
         --
      --
      -- Tratamento para o atributo => DM_IND_CPRB
      -- =============================================
      elsif trim(ev_atributo) = 'DM_IND_CPRB' then
         --
         --
         vn_fase := 16;
         --
         if trim(ev_valor) is not null then
            --
            vn_fase := 17;
            --
            if vn_dmtipocampo = 1 then -- tipo de campo = 0-data, 1-num�rico, 2-caractere
               --
               vn_fase := 18;
               --
               vn_dm_ind_cprb := pk_csf.fkg_ff_ret_vlr_number ( ev_obj_name => 'VW_CSF_CT_IMP_RET_EFD_FF'
                                                              , ev_atributo => trim(ev_atributo)
                                                              , ev_valor    => trim(ev_valor) );
               --
               if vn_dm_ind_cprb in (0,1) then
                  --
                  vv_descr := pk_csf.fkg_dominio ( ev_dominio => 'CONHEC_TRANSP_IMP_RET.DM_IND_CPRB'
                                                 , ev_vl      => vn_dm_ind_cprb );
                  --
                  vn_fase := 19;
                  --
                  if vv_descr is null then
                     --
                     vn_fase := 19.1;
                     --
                     gv_mensagem_log := '"Indicador da CPRB � SPED EFD-REINF" inv�lido (' || vn_dm_ind_cprb || ').';
                     --
                     vn_loggenerico_id := null;
                     --
                     pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                                       , ev_mensagem        => gv_cabec_log
                                                       , ev_resumo          => gv_mensagem_log
                                                       , en_tipo_log        => ERRO_DE_VALIDACAO
                                                       , en_referencia_id   => gn_referencia_id
                                                       , ev_obj_referencia  => gv_obj_referencia );
                     --
                     -- Armazena o "loggenerico_id" na mem�ria
                     pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                                          , est_log_generico  => est_log_generico );
                     --
                  end if;
                  --
               end if;
               --
            else
               --
               vn_fase := 20;
               --
               gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR informado n�o confere com o tipo de campo, deveria ser NUM�RICO.';
               --
               vn_loggenerico_id := null;
               --
               pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                                 , ev_mensagem       => gv_cabec_log
                                                 , ev_resumo         => gv_mensagem_log
                                                 , en_tipo_log       => erro_de_validacao
                                                 , en_referencia_id  => gn_referencia_id
                                                 , ev_obj_referencia => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na mem�ria
               pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                                    , est_log_generico => est_log_generico );
               --
            end if;
            --
         else
            --
            vn_fase := 21;
            --
            gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR n�o pode ser nulo.';
            --
            vn_loggenerico_id := null;
            --
            pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                              , ev_mensagem       => gv_cabec_log
                                              , ev_resumo         => gv_mensagem_log
                                              , en_tipo_log       => erro_de_validacao
                                              , en_referencia_id  => gn_referencia_id
                                              , ev_obj_referencia => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na mem�ria
            pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico   => vn_loggenerico_id
                                                 , est_log_generico => est_log_generico );
            --
         end if;
         --
      else
         --
         vn_fase := 22;
         --
         gv_mensagem_log := '"Atributo" ('||ev_atributo||') e "VALOR" ('||ev_valor||') relacionados, n�o especificados no processo.';
         --
         vn_loggenerico_id := null;
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => ERRO_DE_VALIDACAO
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                              , est_log_generico  => est_log_generico );
         --
      end if;
      --
   end if; -- Fim da verifica��o vv_mensagem is not null
   --
   vn_fase := 80;
   --
   if   nvl(en_ctimpretefd_id,0)     > 0
    and ev_atributo                  = 'CD_TP_SERV_REINF'
    and nvl(vn_tiposervreinf_id ,-1) > 0
    and gv_mensagem_log              is null then
      --
      vn_fase := 81;
      --
      update conhec_transp_imp_ret
         set tiposervreinf_id =  vn_tiposervreinf_id
       where id               = en_ctimpretefd_id;
      --
   end if;
   --
   vn_fase := 82;
   --
   if   nvl(en_ctimpretefd_id,0)     > 0
    and ev_atributo                  = 'DM_IND_CPRB'
    and nvl(vn_dm_ind_cprb ,-1)      in (0,1)
    and gv_mensagem_log              is null then
      --
      vn_fase := 83;
      --
      update conhec_transp_imp_ret
         set dm_ind_cprb =  vn_dm_ind_cprb
       where id          = en_ctimpretefd_id;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_d100.pkb_integr_ctimpretefd_ff fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_mensagem_log
                                           , ev_resumo          => null
                                           , en_tipo_log        => erro_de_sistema
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_ctimpretefd_ff;
--
-------------------------------------------------------------------------------------------------------
--| Procedimento integra os impostos retidos
-------------------------------------------------------------------------------------------------------
procedure pkb_integr_ctimpretefd ( est_log_generico        in out nocopy  dbms_sql.number_table
                                 , est_ctimpretefd         in out nocopy  conhec_transp_imp_ret%rowtype
                                 , ev_cpf_cnpj_emit        in             varchar2
                                 , ev_cod_imposto          in             tipo_imposto.cd%type
                                 , ev_cd_tipo_ret_imp      in             tipo_ret_imp.cd%type
                                 , ev_cod_receita          in             tipo_ret_imp_receita.cod_receita%type
                                 , en_multorg_id           in             mult_org.id%type )
is
   --
   vn_fase              number := 0;
   vn_loggenerico_id    log_generico_ct.id%TYPE;
   vn_vl_imp_orig       conhec_transp_imp_ret.vl_imp%type;
   vn_conhectransp_orig conhec_transp.id%type;
   --
   vv_cod_mod           mod_fiscal.cod_mod%type;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(est_ctimpretefd.conhectransp_id,0) <= 0 then
      --
      vn_fase := 1.1;
      --
      gv_mensagem_log := 'N�o informado o relacionamento entre os Impostos Retidos e o Conhecimento de Transportes.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 2;
   --
   -- cod_imposto
   if nvl(ev_cod_imposto,0) <= 0 then
      --
      vn_fase := 2.1;
      --
      gv_mensagem_log := '"C�digo do Imposto Retido" n�o pode ser nulo';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 3;
   --
   est_ctimpretefd.tipoimp_id := pk_csf.fkg_Tipo_Imposto_id ( en_cd => ev_cod_imposto );
   --
   vn_fase := 4;
   --
   if nvl(est_ctimpretefd.tipoimp_id,0) <= 0 then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := '"C�digo do Imposto Retido" inv�lido (' || ev_cod_imposto || ').';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 5;
   --
   -- cd_tipo_ret_imp
   if nvl(ev_cd_tipo_ret_imp,0) > 0 then
      --
      vn_fase := 5.1;
      --
      est_ctimpretefd.tiporetimp_id := pk_csf.fkg_tipo_ret_imp ( en_multorg_id  => en_multorg_id
                                                               , en_cd_ret      => ev_cd_tipo_ret_imp
                                                               , en_tipoimp_id  => est_ctimpretefd.tipoimp_id );
      --
      if nvl(est_ctimpretefd.tiporetimp_id,0) <= 0 then
         --
         vn_fase := 5.2;
         --
         gv_mensagem_log := '"C�digo do Documentos de Imposto Retido" inv�lido (' || ev_cd_tipo_ret_imp || ').';
         --
         vn_loggenerico_id := null;
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => ERRO_DE_VALIDACAO
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                              , est_log_generico  => est_log_generico );
         --
      end if;
      --
   end if;
   --
   -- ev_cod_receita
   vn_fase := 6;
   --
   if nvl(ev_cod_receita,0) > 0 then
      --
      vn_fase := 6.1;
      --
      est_ctimpretefd.tiporetimpreceita_id := pk_csf.fkg_tipo_ret_imp_rec ( en_cod_receita   => ev_cod_receita
                                                                          , en_tiporetimp_id => est_ctimpretefd.tiporetimp_id );
      --
      if nvl(est_ctimpretefd.tiporetimpreceita_id,0) <= 0 then
         --
         vn_fase := 6.2;
         --
         gv_mensagem_log := '"C�digo da Receita referente aos Impostos Retidos" inv�lido (' || ev_cod_receita || ').';
         --
         vn_loggenerico_id := null;
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => ERRO_DE_VALIDACAO
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                              , est_log_generico  => est_log_generico );
         --
      end if;
      --
   end if;
   --
   vn_fase := 7;
   --
   -- vl_item
   if nvl(est_ctimpretefd.vl_item,0) <= 0 then
      --
      vn_fase := 7.1;
     --
      gv_mensagem_log := '"Valor do item do Imposto Retido" n�o pode ser negativa ou zero (0).';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 8;
   --
   -- vl_base_calc
   if nvl(est_ctimpretefd.vl_base_calc,0) <= 0 then
      --
      vn_fase := 8.1;
     --
      gv_mensagem_log := '"Valor da Base de C�lculo do Imposto Retido" n�o pode ser negativa ou zero (0).';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 9;
   --
   -- vl_aliq
   if nvl(est_ctimpretefd.vl_aliq,0) <= 0 then
      --
      vn_fase := 9.1;
     --
      gv_mensagem_log := '"Valor da Aliquota do Imposto Retido" n�o pode ser negativa ou zero (0).';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 10;
   --
   -- vl_imp
   if nvl(est_ctimpretefd.vl_imp,0) <= 0 then
      --
      vn_fase := 10.1;
     --
      gv_mensagem_log := '"Valor do Imposto Retido" n�o pode ser negativa ou zero (0).';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 11;
   --
   if est_ctimpretefd.tipoimp_id is not null then
      --
      begin
         -- Verifica se � CTE de convers�o
         select ci.vl_imp
              , conhectransp_id1 -- origem
           into vn_vl_imp_orig
              , vn_conhectransp_orig
           from r_ct_ct               rc
              , conhec_transp_imp_ret ci
          where ci.conhectransp_id  = rc.conhectransp_id1
            and rc.conhectransp_id2 = est_ctimpretefd.conhectransp_id
            and ci.tipoimp_id       = est_ctimpretefd.tipoimp_id;
         --
      exception
         when others then
            vn_vl_imp_orig        := 0;
            vn_conhectransp_orig  := null;
      end;
      --
      if vn_conhectransp_orig is not null
         and to_number(TO_CHAR(nvl(vn_vl_imp_orig,0), '9999999999990D99')) <> to_number(TO_CHAR(nvl(est_ctimpretefd.vl_imp,0), '9999999999990D99')) then
         --
         gv_mensagem_log := 'O CTE � de convers�o e os valores do imposto '||ev_cod_imposto||' est� divergente com o "Valor do Imposto Retido" do CTE de origem. '||
                            'Vlr Imposto ORIG('||nvl(vn_vl_imp_orig,0)||') / Vlr Imposto CTE convertido('||nvl(est_ctimpretefd.vl_imp,0)||').';
         --
         vn_loggenerico_id := null;
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => INFORMACAO
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
      end if;
      --
   end if;
   --
   vn_fase := 12;
   --
   est_ctimpretefd.tiposervreinf_id := null;
   est_ctimpretefd.dm_ind_cprb      := null;
   --
   vn_fase := 12.1;   
   /*Sera valida se esta informa��o estiver carregada. Durante teste de integracao , estes campos n�o estavam carregados.*/   
   if  gt_row_conhec_transp.modfiscal_id is null  or        
       gt_row_conhec_transp.dt_hr_emissao is null or 
       gt_row_conhec_transp.NATOPER_ID is null    then
       ----
       begin
         ---         
         select modfiscal_id,               
                dt_hr_emissao,
                NATOPER_ID,
                empresa_id -- incluido por conta do processo de valida��o (pk_vld_amb_d100)
          into gt_row_conhec_transp.modfiscal_id,               
               gt_row_conhec_transp.dt_hr_emissao,
               gt_row_conhec_transp.NATOPER_ID,
               gt_row_conhec_transp.empresa_id
         from conhec_transp where id =  est_ctimpretefd.conhectransp_id;   
         ---
       exception
         when others then
           gt_row_conhec_transp.modfiscal_id :=null;               
           gt_row_conhec_transp.dt_hr_emissao:=null;   
           gt_row_conhec_transp.NATOPER_ID   :=null;        
       end;    
       ----   
   end if;    
   --   
   vn_fase := 12.2;
   --
   vv_cod_mod := pk_csf.fkg_cod_mod_id(gt_row_conhec_transp.modfiscal_id);
   --
   if vv_cod_mod =  '67' then
     ---
     vn_fase := 12.3;
     ---
     if ev_cod_imposto = 13 then -- INSS
       --- 
       vn_fase := 12.4;
       ---
       begin
         select p.tiposervreinf_id,
                nvl(p.dm_ind_cprb,null)
            into
                est_ctimpretefd.tiposervreinf_id,
                est_ctimpretefd.dm_ind_cprb
          from aliq_tipoimp_ncm_empresa p
          where p.empresa_id     = gt_row_conhec_transp.empresa_id
            and p.tipoimposto_id = est_ctimpretefd.tipoimp_id  -- considerar INSS
            and gt_row_conhec_transp.Dt_Hr_Emissao between p.dt_ini and nvl(p.dt_fin, gt_row_conhec_transp.Dt_Hr_Emissao)
            and p.dm_tipo_param  = 'R' -- REGRA/*evc_dm_tipo_param*/
            and p.natoper_id     = gt_row_conhec_transp.NATOPER_ID
            ;
       exception 
         when others then 
           est_ctimpretefd.tiposervreinf_id := null;
           est_ctimpretefd.dm_ind_cprb      := null;
       end;
       ---       
     end if;     
     ---     
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_ctimpretefd.conhectransp_id,0) > 0
      and est_ctimpretefd.tipoimp_id   is not null
      and est_ctimpretefd.vl_item      is not null
      and est_ctimpretefd.vl_base_calc is not null
      and est_ctimpretefd.vl_aliq      is not null
      and est_ctimpretefd.vl_imp       is not null then
      --
      vn_fase := 99.1;
      --
      if nvl(gn_tipo_integr,0) = 1 then
         --
         vn_fase := 99.2;
         --
         select conhectranspimpret_seq.nextval
           into est_ctimpretefd.id
           from dual;
         --
         vn_fase := 99.3;
         --
         insert into conhec_transp_imp_ret ( id
                                           , conhectransp_id
                                           , tipoimp_id
                                           , tiporetimpreceita_id
                                           , tiporetimp_id
                                           , vl_item
                                           , vl_base_calc
                                           , vl_aliq
                                           , vl_imp
                                           , tiposervreinf_id
                                           , dm_ind_cprb
                                           )
                                    values ( est_ctimpretefd.id
                                           , est_ctimpretefd.conhectransp_id
                                           , est_ctimpretefd.tipoimp_id
                                           , est_ctimpretefd.tiporetimpreceita_id
                                           , est_ctimpretefd.tiporetimp_id
                                           , est_ctimpretefd.vl_item
                                           , est_ctimpretefd.vl_base_calc
                                           , est_ctimpretefd.vl_aliq
                                           , est_ctimpretefd.vl_imp
                                           , est_ctimpretefd.tiposervreinf_id 
                                           , est_ctimpretefd.dm_ind_cprb
                                           );
         --
      else
         --
         vn_fase := 99.4;
         --
         update conhec_transp_imp_ret
            set tipoimp_id            = est_ctimpretefd.tipoimp_id
              , tiporetimpreceita_id  = est_ctimpretefd.tiporetimpreceita_id
              , tiporetimp_id         = est_ctimpretefd.tiporetimp_id
              , vl_item               = est_ctimpretefd.vl_item
              , vl_base_calc          = est_ctimpretefd.vl_base_calc
              , vl_aliq               = est_ctimpretefd.vl_aliq
              , vl_imp                = est_ctimpretefd.vl_imp
              , tiposervreinf_id      = est_ctimpretefd.tiposervreinf_id
              , dm_ind_cprb           = est_ctimpretefd.dm_ind_cprb
          where id = est_ctimpretefd.id;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_d100.pkb_integr_ctimpretefd fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_mensagem_log
                                           , ev_resumo          => null
                                           , en_tipo_log        => ERRO_DE_SISTEMA
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_ctimpretefd;
--
-------------------------------------------------------------------------------------------------------
--| Procedimento integra o processo referenciado
-------------------------------------------------------------------------------------------------------
procedure pkb_integr_ctprocrefefd ( est_log_generico in out nocopy dbms_sql.number_table
                                  , est_ctprocrefefd in out nocopy ct_proc_ref%rowtype
                                  , en_cd_orig_proc  in            orig_proc.cd%type )
is
   --
   vn_fase           number := 0;
   vn_loggenerico_id log_generico_ct.id%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(est_ctprocrefefd.conhectransp_id,0) <= 0 then
      --
      vn_fase := 1.1;
      --
      gv_mensagem_log := 'N�o informado o relacionamento entre o Resumo de Impostos e o Conhecimento de Transportes.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 2;
   --
   if nvl(en_cd_orig_proc,0) not in (1,3,9) then
      --
      vn_fase := 2.1;
      --
      gv_mensagem_log := '"C�digo da Origem do Processo" inv�lido (' || en_cd_orig_proc || ') deve ser 1, 3 ou 9.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 3;
   -- V�lida a informa��o da origem do processo
   est_ctprocrefefd.origproc_id := pk_csf.fkg_orig_proc_id ( en_cd => en_cd_orig_proc );
   --
   vn_fase := 4;
   -- V�lida a informa��o da origem do processo
   if nvl(est_ctprocrefefd.origproc_id,0) = 0 then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := '"C�digo da Origem do Processo" inv�lido (' || en_cd_orig_proc || ').';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_ctprocrefefd.conhectransp_id,0) > 0
      and est_ctprocrefefd.num_proc is not null
      and nvl(est_ctprocrefefd.origproc_id,0) > 0 then
      --
      vn_fase := 99.1;
      --
      if nvl(gn_tipo_integr,0) = 1 then
         --
         vn_fase := 99.2;
         --
         select ctprocref_seq.nextval
           into est_ctprocrefefd.id
           from dual;
         --
         vn_fase := 99.3;
         --
         insert into ct_proc_ref ( id
                                 , conhectransp_id
                                 , num_proc
                                 , origproc_id )
                          values ( est_ctprocrefefd.id
                                 , est_ctprocrefefd.conhectransp_id
                                 , est_ctprocrefefd.num_proc
                                 , est_ctprocrefefd.origproc_id );
      else
         --
         vn_fase := 99.4;
         --
         update ct_proc_ref
            set num_proc    = est_ctprocrefefd.num_proc
              , origproc_id = est_ctprocrefefd.origproc_id
          where id = est_ctprocrefefd.id;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_d100.pkb_integr_ctprocrefefd fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_mensagem_log
                                           , ev_resumo          => null
                                           , en_tipo_log        => ERRO_DE_SISTEMA
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_ctprocrefefd;
-------------------------------------------------------------------------------------------------------
--| Procedimento integra a informa��o fiscal do CT
-------------------------------------------------------------------------------------------------------
procedure pkb_integr_ctinfor_fiscal ( est_log_generico      in out nocopy  dbms_sql.number_table
                                    , est_ctinfor_fiscal    in out nocopy  ctinfor_fiscal%rowtype
                                    , ev_cod_obs            in             varchar2
                                    , en_multorg_id         in             mult_org.id%type )
is
   --
   vn_fase           number := 0;
   vn_loggenerico_id log_generico_ct.id%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(est_ctinfor_fiscal.conhectransp_id,0) <= 0 then
      --
      vn_fase := 1.1;
      --
     gv_mensagem_log := 'N�o informado o relacionamento entre a Informa��o Fiscal e o Conhecimento de Transportes.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_mensagem_log
                                        , ev_resumo          => null
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 2;
   --
   est_ctinfor_fiscal.obslanctofiscal_id := pk_csf.fkg_id_obs_lancto_fiscal ( en_multorg_id => en_multorg_id
                                                                            , ev_cod_obs    => ev_cod_obs );
   --
   if nvl(est_ctinfor_fiscal.obslanctofiscal_id,0) <= 0 then
      --
      vn_fase := 2.1;
      --
     gv_mensagem_log := 'N�o informado o c�digo da observa��o do lan�amento fiscal ou o c�digo est� inv�lido (' || ev_cod_obs || ')';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_mensagem_log
                                        , ev_resumo          => null
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_ctinfor_fiscal.conhectransp_id,0) > 0
      and nvl(est_ctinfor_fiscal.obslanctofiscal_id,0) > 0
      then
      --
      vn_fase := 99.1;
      --
      if nvl(gn_tipo_integr,0) = 1 then
         --
         vn_fase := 99.2;
         --
         select ctinforfiscal_seq.nextval
           into est_ctinfor_fiscal.id
           from dual;
         --
         insert into ctinfor_fiscal ( id
                                    , conhectransp_id
                                    , obslanctofiscal_id
                                    , txt_compl
                                    )
                             values
                                    ( est_ctinfor_fiscal.id  -- id
                                    , est_ctinfor_fiscal.conhectransp_id -- conhectransp_id
                                    , est_ctinfor_fiscal.obslanctofiscal_id -- obslanctofiscal_id
                                    , est_ctinfor_fiscal.txt_compl -- txt_compl
                                    );
         --
      else
         --
         update ctinfor_fiscal set obslanctofiscal_id = est_ctinfor_fiscal.obslanctofiscal_id
                                 , txt_compl          = est_ctinfor_fiscal.txt_compl
                             where id                 = est_ctinfor_fiscal.id;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_d100.pkb_integr_ctinfor_fiscal fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_mensagem_log
                                           , ev_resumo          => null
                                           , en_tipo_log        => ERRO_DE_SISTEMA
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_ctinfor_fiscal;
-------------------------------------------------------------------------------------------------------
--| Procedimento integra os ajustes e informac�es de valores provenientes de documento fiscal
-------------------------------------------------------------------------------------------------------
procedure pkb_integr_ct_inf_prov ( est_log_generico      in out nocopy  dbms_sql.number_table
                                 , est_ct_inf_prov       in out nocopy  ct_inf_prov%rowtype
                                 , ev_cod_aj             in             varchar2
                                 )
is
   --
   vn_fase           number := 0;
   vn_loggenerico_id log_generico_ct.id%TYPE;
   vd_dt_emiss       conhec_transp.dt_hr_emissao%type;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(est_ct_inf_prov.ctinforfiscal_id,0) <= 0 then
      --
      vn_fase := 1.1;
      --
     gv_mensagem_log := 'N�o informado o relacionamento entre a Informa��o Fiscal e a Informa��o proveniente do documento fiscal.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_mensagem_log
                                        , ev_resumo          => null
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 2;
   --
   begin
      select ct.dt_hr_emissao
        into vd_dt_emiss
        from ctinfor_fiscal cf
           , conhec_transp  ct
       where cf.id = est_ct_inf_prov.ctinforfiscal_id
         and ct.id = cf.conhectransp_id;
   exception
      when others then
         vd_dt_emiss := null;
   end;
   --
   vn_fase := 2.2;
   --
   est_ct_inf_prov.codocorajicms_id := pk_csf_efd.fkg_cod_ocor_aj_icms_id ( ev_cod_aj => ev_cod_aj
                                                                          , ed_dt_ini => vd_dt_emiss
                                                                          , ed_dt_fin => vd_dt_emiss );
   --
   vn_fase := 2.3;
   --
   if nvl(est_ct_inf_prov.codocorajicms_id,0) <= 0 then
      --
      vn_fase := 2.4;
      --
      gv_mensagem_log := 'N�o informado o c�digo do ajuste ou o c�digo est� inv�lido (' || ev_cod_aj || ')';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_mensagem_log
                                        , ev_resumo          => null
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 3;
   --
   if nvl(est_ct_inf_prov.vl_bc_icms,0) < 0 then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := 'O valor da base de c�lculo do ICMS (' || est_ct_inf_prov.vl_bc_icms || ') n�o pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_mensagem_log
                                        , ev_resumo          => null
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 4;
   --
   if nvl(est_ct_inf_prov.aliq_icms,0) < 0 then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := 'O valor da aliquota do ICMS (' || est_ct_inf_prov.aliq_icms || ') n�o pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_mensagem_log
                                        , ev_resumo          => null
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 5;
   --
   if nvl(est_ct_inf_prov.vl_icms,0) < 0 then
      --
      vn_fase := 5.1;
      --
      gv_mensagem_log := 'O valor do ICMS (' || est_ct_inf_prov.vl_icms || ') n�o pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_mensagem_log
                                        , ev_resumo          => null
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 6;
   --
   if nvl(est_ct_inf_prov.vl_outros,0) < 0 then
      --
      vn_fase := 6.1;
      --
      gv_mensagem_log := 'Outros valores (' || est_ct_inf_prov.vl_outros || ') n�o podem ser negativos.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_mensagem_log
                                        , ev_resumo          => null
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_ct_inf_prov.ctinforfiscal_id,0) > 0
      and nvl(est_ct_inf_prov.codocorajicms_id ,0) > 0
      then
      --
      vn_fase := 99.1;
      --
      if nvl(gn_tipo_integr,0) = 1 then
         --
         vn_fase := 99.2;
         --
         select ctinfprov_seq.nextval
           into est_ct_inf_prov.id
           from dual;
         --
         insert into ct_inf_prov ( id
                                 , ctinforfiscal_id
                                 , codocorajicms_id
                                 , descr_compl_aj
                                 , vl_bc_icms
                                 , aliq_icms
                                 , vl_icms
                                 , vl_outros
                                 )
                          values
                                 ( est_ct_inf_prov.id  -- id
                                 , est_ct_inf_prov.ctinforfiscal_id -- ctinforfiscal_id
                                 , est_ct_inf_prov.codocorajicms_id -- codocorajicms_id
                                 , est_ct_inf_prov.descr_compl_aj   -- descr_compl_aj
                                 , est_ct_inf_prov.vl_bc_icms -- vl_bc_icms
                                 , est_ct_inf_prov.aliq_icms -- aliq_icms
                                 , est_ct_inf_prov.vl_icms -- vl_icms
                                 , est_ct_inf_prov.vl_outros -- vl_outros
                                 );
         --
      else
         --
         update ct_inf_prov set descr_compl_aj = est_ct_inf_prov.descr_compl_aj
                              , vl_bc_icms     = est_ct_inf_prov.vl_bc_icms
                              , aliq_icms      = est_ct_inf_prov.aliq_icms
                              , vl_icms        = est_ct_inf_prov.vl_icms
                              , vl_outros      = est_ct_inf_prov.vl_outros
                          where id             = est_ct_inf_prov.id;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_d100.pkb_integr_ct_inf_prov fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_mensagem_log
                                           , ev_resumo          => null
                                           , en_tipo_log        => ERRO_DE_SISTEMA
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_ct_inf_prov;
-------------------------------------------------------------------------------------------------------
--| Procedimento v�lida informa��o relativa aos impostos
-------------------------------------------------------------------------------------------------------
procedure pkb_valida_conhec_transp_imp ( est_log_generico   in out nocopy  dbms_sql.number_table
                                       , en_conhectransp_id in             Conhec_Transp.Id%TYPE )

is
   --
   vn_fase            number := 0;
   vn_qtde            number := 0;
   vn_loggenerico_id  log_generico_ct.id%TYPE;
   --
begin

   vn_fase := 1;
   --
   if nvl(en_conhectransp_id,0) > 0 then
      --
      vn_fase := 2;
      -- Busca qtde de registros na tabela imposto.
      -- Ps.: Em conhec. transp, independente se � emiss�o pr�pria ou terceiro,
      -- s� se informa imposto de icms nessa tabela.
      Begin
         select count(a.id)
           into vn_qtde
           from conhec_transp_imp a,
                tipo_imposto b
          where a.conhectransp_id = en_conhectransp_id
            and b.cd              = 1 --ICMS
            and a.tipoimp_id      = b.id ;
      exception
         when others then
            vn_qtde := 0;
      end;
      --
      vn_fase := 3;
      --
      if nvl(vn_qtde, 0) <= 0 then
         --
         vn_fase := 3.1;
         --
         gv_mensagem_log := ' As informa��es sobre o ICMS s�o obrigat�rias.';
         --
         vn_loggenerico_id := null;
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => ERRO_DE_VALIDACAO
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                              , est_log_generico  => est_log_generico );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_valida_conhec_transp_imp fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => ERRO_DE_SISTEMA
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                              , est_log_generico  => est_log_generico );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_valida_conhec_transp_imp;
-------------------------------------------------------------------------------------------------------
--| Procedimento v�lida informa��o dos Valores da Presta��o de Servico
--| Por enquanto, s� ir� validar a qtde de registros na tabela para o id do cte
--| informado no par�metro.
-------------------------------------------------------------------------------------------------------
procedure pkb_valida_ct_vlprest ( est_log_generico     in out nocopy  dbms_sql.number_table
                                , en_conhectransp_id   in             Conhec_Transp.Id%TYPE )

is
   --
   vn_fase            number := 0;
   vn_qtde            number := 0;
   vn_loggenerico_id  log_generico_ct.id%TYPE;
   --
begin

   vn_fase := 1;
   --
   if nvl(en_conhectransp_id,0) > 0 then
      --
      vn_fase := 2;
      -- Busca inform. na Tabela de Vlrs da Presta��o de Servi�o
      Begin
         select count(a.id)
           into vn_qtde
           from conhec_transp_vlprest a
          where a.conhectransp_id = en_conhectransp_id;
      exception
         when others then
            vn_qtde := 0;
      end;
      --
      vn_fase := 3;
      --
      if nvl(vn_qtde, 0) <= 0 then
         --
         vn_fase := 3.1;
         --
         gv_mensagem_log := ' As informa��es sobre os Valores da Presta��o de Servi�o s�o obrigat�rias.';
         --
         vn_loggenerico_id := null;
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => ERRO_DE_VALIDACAO
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                              , est_log_generico  => est_log_generico );
         --
      elsif nvl(vn_qtde, 0) > 1 then
         --
         vn_fase := 3.2;
         --
         gv_mensagem_log := ' Existe mais de um registro para as informa��es sobre os Valores da Presta��o de Servi�o.';
         --
         vn_loggenerico_id := null;
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => ERRO_DE_VALIDACAO
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                              , est_log_generico  => est_log_generico );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_valida_ct_vlprest fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => ERRO_DE_SISTEMA
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                              , est_log_generico  => est_log_generico );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_valida_ct_vlprest;
-------------------------------------------------------------------------------------------------------
--| Procedimento v�lida informa��o do Registro Analitico do Conhecimento de Transporte
-------------------------------------------------------------------------------------------------------
procedure pkb_valida_ct_d190 ( est_log_generico     in out nocopy  dbms_sql.number_table
                             , en_conhectransp_id   in             Conhec_Transp.Id%TYPE )

is
   --
   vn_fase            number := 0;
   vn_qtde            number := 0;
   vn_vl_base_calc    number := 0;
   vn_vl_imp_trib     number := 0;
   vn_loggenerico_id  log_generico_ct.id%TYPE;
   --
   cursor c_ct_tot_d190 is
   select sum(nvl(anal.vl_bc_icms, 0)) vl_bc_icms,
          sum(nvl(anal.vl_icms, 0))    vl_icms
     from ct_reg_anal anal
    where anal.conhectransp_id = en_conhectransp_id;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_conhectransp_id,0) > 0 then
      --
      vn_fase := 2;
      -- Busca se h� registros na tabela analitica
      Begin
         select count(a.id)
           into vn_qtde
           from ct_reg_anal a
          where a.conhectransp_id = en_conhectransp_id;
      exception
         when others then
            vn_qtde := 0;
      end;
      --
      vn_fase := 3;
      --
      if nvl(vn_qtde, 0) <= 0 then
         --
         vn_fase := 3.1;
         --
         gv_mensagem_log := 'As informa��es sobre o Anal�tico dos Conhec. Transp. s�o obrigat�rias.';
         --
         vn_loggenerico_id := null;
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => ERRO_DE_VALIDACAO
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                              , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 4;
      -- Informa��es analiticas do conhecimento de transporte
      for rec in c_ct_tot_d190 loop
         exit when c_ct_tot_d190%notfound or (c_ct_tot_d190%notfound) is null;
         --
         vn_fase := 4.1;
         -- Busca valores do icms na tabela imposto.
         Begin
            select sum(nvl(imp.vl_base_calc, 0)) vl_base_calc,
                   sum(nvl(imp.vl_imp_trib, 0))  vl_imp_trib
              Into vn_vl_base_calc,
                   vn_vl_imp_trib
              from conhec_transp_imp imp,
                   tipo_imposto ti
             where imp.conhectransp_id = en_conhectransp_id
               and ti.cd               = 1 -- ICMS
               and imp.tipoimp_id      = ti.id;
         exception
            when others then
               vn_vl_base_calc := 0;
               vn_vl_imp_trib  := 0;
         end;
         --
         vn_fase := 5;
         -- Valida��o: A Base de C�lculo de ICMS do D100 � diferente da Base de C�lculo do ICMS do D190
         if nvl(rec.vl_bc_icms, 0) <> nvl(vn_vl_base_calc, 0)  then
            --
            vn_fase := 5.1;
            --
            gv_mensagem_log := 'A "Base de ICMS do Conhec. Transp." (' || vn_vl_base_calc || ') est� divergente da' ||
                               ' "Base de ICMS no Anal�tico de Impostos" (' || rec.vl_bc_icms || ')';
            --
            vn_loggenerico_id := null;
            --
            pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                              , ev_mensagem        => gv_cabec_log
                                              , ev_resumo          => gv_mensagem_log
                                              , en_tipo_log        => ERRO_DE_VALIDACAO
                                              , en_referencia_id   => gn_referencia_id
                                              , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na mem�ria
            pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                                 , est_log_generico  => est_log_generico );
            --
         end if;
         --
         vn_fase := 6;
         -- Valida��o: O Vlr. de ICMS do D100 � diferente do Vlr. do ICMS do D190
         if nvl(rec.vl_icms, 0) <> nvl(vn_vl_imp_trib, 0)  then
            --
            vn_fase := 6.1;
            --
            gv_mensagem_log := 'O "Valor do ICMS no Conhec. Transp." (' || vn_vl_imp_trib || ') est� divergente do' ||
                               ' "Valor do ICMS no Anal�tico de Impostos" (' || rec.vl_icms || ')';
            --
            vn_loggenerico_id := null;
            --
            pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                              , ev_mensagem        => gv_cabec_log
                                              , ev_resumo          => gv_mensagem_log
                                              , en_tipo_log        => ERRO_DE_VALIDACAO
                                              , en_referencia_id   => gn_referencia_id
                                              , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na mem�ria
            pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                                 , est_log_generico  => est_log_generico );
            --
         end if;
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_valida_ct_d190 fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => ERRO_DE_SISTEMA
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                              , est_log_generico  => est_log_generico );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_valida_ct_d190;
-------------------------------------------------------------------------------------------------------
--| Procedimento valida informa��o da duplicidade do PIS para o conhecimento de transporte.
--| Dever� existir um registro por: dm_ind_nat_frt, cst_pis, cod_bc_cred_pc, aliq_pis e cod_cta.
-------------------------------------------------------------------------------------------------------
procedure pkb_valida_ct_d101 ( est_log_generico     in out nocopy  dbms_sql.number_table
                             , en_conhectransp_id   in             conhec_transp.id%type )
is
   --
   vn_fase            number := 0;
   vn_dm_ind_nat_frt  number := 0;
   vn_qtde            number := 0;
   vn_loggenerico_id  log_generico_ct.id%type;
   vn_vl_bc_cofins    number;
   vb_existe_compl    boolean := false;
   vn_dm_valida_pis   number(1);
   vn_dm_ind_emit     number(1);
   vn_empresa_id       empresa.id%type;
   --
   cursor c_qtde_pis is
   select cc.dm_ind_nat_frt
        , count(*) qtde
     from ct_comp_doc_pis cc
    where cc.conhectransp_id = en_conhectransp_id
    group by cc.dm_ind_nat_frt
   having count(*) > 1;
   --
   cursor c_soma_cst is
   select cst.cod_st
        , sum(op.vl_bc_pis) vl_bc_pis
     from ct_comp_doc_pis op
        , cod_st cst
    where op.conhectransp_id = en_conhectransp_id
      and cst.id             = op.codst_id
    group by cst.cod_st;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_conhectransp_id,0) > 0 then
      --
      vn_fase := 2;
      -- Recupera quantidade de registros por "chave".
      open c_qtde_pis;
      fetch c_qtde_pis into vn_dm_ind_nat_frt
                          , vn_qtde;
      close c_qtde_pis;
      --
      vn_fase := 3;
      -- Recupera o ID da empresa do conhecimento de transporte e o tipo de emitente.
      begin
         select empresa_id
              , dm_ind_emit
           into vn_empresa_id
              , vn_dm_ind_emit
           from conhec_transp
          where id = en_conhectransp_id;
      exception
         when others then
            vn_empresa_id  := 0;
            vn_dm_ind_emit := 1;
      end;
      --
      vn_fase := 4;
      --
      if nvl(vn_qtde,0) > 1 then
         --
         vn_fase := 4.1;
         --
         gv_mensagem_log := 'N�o podem existir mais de um registro para complemento da opera��o de PIS com o mesmo Indicador da Natureza do Frete Contratado.';
         --
         vn_loggenerico_id := null;
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => erro_de_validacao
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                              , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 5;
      --
      if vn_dm_ind_emit = 1 then -- terceiro
         --
         vn_dm_valida_pis := pk_csf.fkg_empresa_dmvalpis_terc ( en_empresa_id => vn_empresa_id );
      else
         --
         vn_dm_valida_pis := pk_csf.fkg_empresa_dmvalpis_emis ( en_empresa_id => vn_empresa_id );
         --
      end if;
      --
      vn_fase := 6;
      -- verifica se os dados de COFINS s�o iguais aos de PIS
      for rec in c_soma_cst loop
         exit when c_soma_cst%notfound or (c_soma_cst%notfound) is null;
         --
         vn_fase := 6.1;
         --
         vb_existe_compl := true;
         --
         begin
            --
            select sum(oc.vl_bc_cofins) vl_bc_cofins
              into vn_vl_bc_cofins
              from ct_comp_doc_cofins oc
                 , cod_st cst
             where oc.conhectransp_id = en_conhectransp_id
               and cst.id             = oc.codst_id
               and cst.cod_st         = rec.cod_st;
            --
         exception
            when others then
               vn_vl_bc_cofins := null;
         end;
         --
         vn_fase := 6.2;
         --
         if vn_vl_bc_cofins is null then
            --
            gv_mensagem_log := 'N�o informado o imposto de COFINS com o mesmo CST ('||rec.cod_st||') para o imposto PIS.';
            --
            vn_loggenerico_id := null;
            --
            pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                              , ev_mensagem        => gv_cabec_log
                                              , ev_resumo          => gv_mensagem_log
                                              , en_tipo_log        => erro_de_validacao
                                              , en_referencia_id   => gn_referencia_id
                                              , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na mem�ria
            pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                                 , est_log_generico  => est_log_generico );
            --
         else
            --
            vn_fase := 6.3;
            --
            if nvl(vn_vl_bc_cofins,0) <> nvl(rec.vl_bc_pis,0) then
               --
               gv_mensagem_log := 'Valor da Base do COFINS (' || nvl(vn_vl_bc_cofins,0) || ') est� diferente do Valor da Base do PIS ( ' || nvl(rec.vl_bc_pis,0) || ' ).';
               --
               vn_loggenerico_id := null;
               --
               pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                                 , ev_mensagem        => gv_cabec_log
                                                 , ev_resumo          => gv_mensagem_log
                                                 , en_tipo_log        => erro_de_validacao
                                                 , en_referencia_id   => gn_referencia_id
                                                 , ev_obj_referencia  => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na mem�ria
               pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                                    , est_log_generico  => est_log_generico );
               --
            end if;
            --
         end if;
         --
      end loop;
      --
      vn_fase := 7;
      --
      if vb_existe_compl = false
         and vn_dm_valida_pis = 1
         then
         --
         vn_fase := 7.1;
         --
         gv_mensagem_log := 'N�o foi encontrado o "Valor do Complemento do PIS" para o Conhecimento de transporte.';
         --
         vn_loggenerico_id := null;
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => erro_de_validacao
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                              , est_log_generico  => est_log_generico );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_valida_ct_d101 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%type;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => erro_de_sistema
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                              , est_log_generico  => est_log_generico );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_valida_ct_d101;
-------------------------------------------------------------------------------------------------------
--| Procedimento valida informa��o da duplicidade do COFINS para o conhecimento de transporte.
--| Dever� existir um registro por: dm_ind_nat_frt, cst_cofins, cod_bc_cred_pc, aliq_cofins e cod_cta.
-------------------------------------------------------------------------------------------------------
procedure pkb_valida_ct_d105 ( est_log_generico     in out nocopy  dbms_sql.number_table
                             , en_conhectransp_id   in             conhec_transp.id%type )
is
   --
   vn_fase             number := 0;
   vn_qtde             number := 0;
   vn_dm_ind_nat_frt   number := 0;
   vn_loggenerico_id   log_generico_ct.id%type;
   vn_vl_bc_pis        number;
   vb_existe_compl     boolean := false;
   vn_dm_valida_cofins number(1);
   vn_dm_ind_emit      number(1);
   vn_empresa_id       empresa.id%type;
   --
   cursor c_qtde_cofins is
   select cc.dm_ind_nat_frt
        , count(*) qtde
     from ct_comp_doc_cofins cc
    where cc.conhectransp_id = en_conhectransp_id
    group by cc.dm_ind_nat_frt
   having count(*) > 1;
   --
   cursor c_soma_cst is
   select cst.cod_st
        , sum(oc.vl_bc_cofins) vl_bc_cofins
     from ct_comp_doc_cofins oc
        , cod_st cst
    where oc.conhectransp_id = en_conhectransp_id
      and cst.id             = oc.codst_id
    group by cst.cod_st;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_conhectransp_id,0) > 0 then
      --
      vn_fase := 2;
      -- Recupera quantidade de registros por "chave".
      open c_qtde_cofins;
      fetch c_qtde_cofins into vn_dm_ind_nat_frt
                             , vn_qtde;
      close c_qtde_cofins;
      --
      vn_fase := 3;
      -- Recupera o ID da empresa do conhecimento de transporte e o tipo de emitente.
      begin
         select empresa_id
              , dm_ind_emit
           into vn_empresa_id
              , vn_dm_ind_emit
           from conhec_transp
          where id = en_conhectransp_id;
      exception
         when others then
            vn_empresa_id  := 0;
            vn_dm_ind_emit := 1;
      end;
      --
      vn_fase := 4;
      --
      if nvl(vn_qtde,0) > 1 then
         --
         vn_fase := 4.1;
         --
         gv_mensagem_log := 'N�o podem existir mais de um registro para complemento da opera��o de COFINS com o mesmo Indicador da Natureza do Frete Contratado.';
         --
         vn_loggenerico_id := null;
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => erro_de_validacao
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                              , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 5;
      --
      if vn_dm_ind_emit = 1 then -- terceiro
         --
         vn_dm_valida_cofins := pk_csf.fkg_empresa_dmvalcofins_terc ( en_empresa_id => vn_empresa_id );
      else
         --
         vn_dm_valida_cofins := pk_csf.fkg_empresa_dmvalcofins_emis ( en_empresa_id => vn_empresa_id );
         --
      end if;
      --
      vn_fase := 6;
      -- verifica se os dados de COFINS s�o iguais aos de PIS
      for rec in c_soma_cst loop
         exit when c_soma_cst%notfound or (c_soma_cst%notfound) is null;
         --
         vn_fase := 6.1;
         --
         vb_existe_compl := true;
         --
         begin
            --
            select sum(op.vl_bc_pis) vl_bc_pis
              into vn_vl_bc_pis
              from ct_comp_doc_pis op
                 , cod_st cst
             where op.conhectransp_id = en_conhectransp_id
               and cst.id             = op.codst_id
               and cst.cod_st         = rec.cod_st;
            --
         exception
            when others then
               vn_vl_bc_pis := null;
         end;
         --
         vn_fase := 6.2;
         --
         if vn_vl_bc_pis is null then
            --
            gv_mensagem_log := 'N�o informado o imposto de PIS com o mesmo CST ('||rec.cod_st||') da COFINS.';
            --
            vn_loggenerico_id := null;
            --
            pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                              , ev_mensagem        => gv_cabec_log
                                              , ev_resumo          => gv_mensagem_log
                                              , en_tipo_log        => erro_de_validacao
                                              , en_referencia_id   => gn_referencia_id
                                              , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na mem�ria
            pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                                 , est_log_generico  => est_log_generico );
            --
         else
            --
            vn_fase := 6.3;
            --
            if nvl(vn_vl_bc_pis,0) <> nvl(rec.vl_bc_cofins,0) then
               --
               gv_mensagem_log := 'Valor da Base do PIS (' || nvl(vn_vl_bc_pis,0) || ') est� diferente do Valor da Base da COFINS ( ' || nvl(rec.vl_bc_cofins,0) || ' ).';
               --
               vn_loggenerico_id := null;
               --
               pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                                 , ev_mensagem        => gv_cabec_log
                                                 , ev_resumo          => gv_mensagem_log
                                                 , en_tipo_log        => erro_de_validacao
                                                 , en_referencia_id   => gn_referencia_id
                                                 , ev_obj_referencia  => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na mem�ria
               pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                                    , est_log_generico  => est_log_generico );
               --
            end if;
            --
         end if;
         --
      end loop;
      --
      vn_fase := 7;
      --
      if vb_existe_compl = false
         and vn_dm_valida_cofins = 1
         then
         --
         vn_fase := 7.1;
         --
         gv_mensagem_log := 'N�o foi encontrado o "Valor do Complemento do COFINS" para o Conhecimento de transporte.';
         --
         vn_loggenerico_id := null;
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => erro_de_validacao
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                              , est_log_generico  => est_log_generico );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_valida_ct_d105 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%type;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => erro_de_sistema
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                              , est_log_generico  => est_log_generico );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_valida_ct_d105;
-------------------------------------------------------------------------
-- Valida D100 campo 11 (DT_EMISS) --
-------------------------------------------------------------------------
procedure pkb_valida_ct_d100 ( est_log_generico     in out nocopy  dbms_sql.number_table
                             , en_conhectransp_id   in             conhec_transp.id%type )
is
   --
   vn_fase            number := 0;
   vd_dt_hr_emissao   CONHEC_TRANSP.DT_HR_EMISSAO%type;
   vv_cod_mod         MOD_FISCAL.cod_mod%type;
   vn_loggenerico_id  log_generico_ct.id%type;
   --
   cursor c_conhec_transp is
   select ct.DT_HR_EMISSAO, md.cod_mod
     from CONHEC_TRANSP ct, MOD_FISCAL md
    where 1 = 1
      and ct.id = en_conhectransp_id
      and ct.modfiscal_id = md.id;
   --
  
begin
   --
   vn_fase := 1;
   --
   if nvl(en_conhectransp_id,0) > 0 then
      --
      vn_fase := 2;
      -- Recupera quantidade de registros por "chave".
      open c_conhec_transp;
      fetch c_conhec_transp into vd_dt_hr_emissao
                               , vv_cod_mod;
      close c_conhec_transp;
      --
      vn_fase := 4;
      --
      if (to_char(nvl(vd_dt_hr_emissao,sysdate),'dd/mm/rrrr') >= '01/01/2019' and vv_cod_mod in ('07','09','10','11','26','27')) then
         --
         vn_fase := 4.1;
         --
         gv_mensagem_log := 'O modelo selecionado n�o est� mais vigente na data de emiss�o informada.';
         --
         vn_loggenerico_id := null;
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => erro_de_validacao
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                              , est_log_generico  => est_log_generico );
         --
      end if;
      --
      end if;
      --
      vn_fase := 5;
      --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_valida_ct_d100 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%type;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => erro_de_sistema
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                              , est_log_generico  => est_log_generico );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_valida_ct_d100;
-------------------------------------------------------------------------
-- Valida CFOP por Participante de CTe - Validar CFOP por Participante --
-------------------------------------------------------------------------
PROCEDURE PKB_VALIDA_CFOP_POR_PART ( EST_LOG_GENERICO    IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                                   , EN_CONHECTRANSP_ID  IN            CONHEC_TRANSP.ID%TYPE
                                   )
IS
   --
   vn_fase                    number := 0;
   vn_loggenerico_id          log_generico_ct.id%type;
   vn_dm_ind_oper             conhec_transp.dm_ind_oper%type;
   vv_uf_emit                 estado.sigla_estado%type;
   vv_uf_dest                 estado.sigla_estado%type;
   vn_dummy                   number := null;
   --
   -------------------------------------------------------------------------------------------------------
   -- Fun��o que retorna se o cfop tem grupo no registro anal�tico
   -------------------------------------------------------------------------------------------------------
   FUNCTION FKG_TEM_GRUPO_CFOP ( EN_CONHECTRANSP_ID IN CONHEC_TRANSP.ID%TYPE
                               , EN_GRUPO_CFOP      IN NUMBER
                               )
            RETURN NUMBER IS
      --
      vn_ret number := 0;
      --
   BEGIN
      --
      begin
         --
         select distinct 1
           into vn_ret
           from ct_reg_anal ra
              , cfop c
          where ra.conhectransp_id = en_conhectransp_id
            and c.id               = ra.cfop_id
            and to_number(substr(c.cd, 1, 1)) <> en_grupo_cfop;
         --
      exception
         when others then
            vn_ret := 0;
      end;
      --
      return vn_ret;
      --
   EXCEPTION
      when others then
         return 0;
   END FKG_TEM_GRUPO_CFOP;
   --
BEGIN
   --
   vn_fase := 1;
   --
   if nvl(en_conhectransp_id,0) > 0 then
      --
      begin
           select ct.dm_ind_oper
                , ct.sigla_uf_ini
                , ct.sigla_uf_fim
            into  vn_dm_ind_oper,
                  vv_uf_emit, 
                  vv_uf_dest
            from conhec_transp ct              
          where ct.id  =  en_conhectransp_id;
          EXCEPTION
      when others then
         null;
      END;  
     --       
     if    vv_uf_emit = 'XX' or vv_uf_dest = 'XX'  then 
      --
      vn_fase := 2;
      -- recupera dados da nota e emitente
      begin
         --
         select ct.dm_ind_oper
              , est.sigla_estado
           into vn_dm_ind_oper
              , vv_uf_emit
           from conhec_transp ct
              , empresa       e
              , pessoa        p
              , cidade        cid
              , estado        est
          where ct.id  = en_conhectransp_id
            and e.id   = ct.empresa_id
            and p.id   = e.pessoa_id
            and cid.id = p.cidade_id
            and est.id = cid.estado_id;
         --
      exception
         when others then
            vn_dm_ind_oper             := null;
            vv_uf_emit                 := null;
      end;
      --
      vn_fase := 3;
      --
      -- recupera dados do local de entrega da mercadoria
      begin
         --
         select est.sigla_estado
           into vv_uf_dest
           from conhec_transp ct
              , pessoa        p
              , cidade        cid
              , estado        est
          where ct.id  = en_conhectransp_id
            and p.id   = ct.pessoa_id
            and cid.id = p.cidade_id
            and est.id = cid.estado_id;
          --
      exception
         when others then
            vv_uf_dest := null;
      end;
      --
      end if;
      --
      vn_fase := 5;
      --
      if vn_dm_ind_oper in (0,1)
         and vv_uf_emit is not null
         and vv_uf_dest is not null then
         --
         vn_fase := 6;
         -- Verifica se a nota fiscal foi emitida dentro do estado
         if vv_uf_emit = vv_uf_dest then
            --
            vn_fase := 7;
            -- Se for entrada informar grupo 1 sen�o grupo 5
            vn_dummy := fkg_tem_grupo_cfop ( en_conhectransp_id => en_conhectransp_id
                                           , en_grupo_cfop      => case when vn_dm_ind_oper = 0 then 1 else 5 end
                                           );
            --
         elsif vv_uf_emit <> vv_uf_dest and vv_uf_dest <> 'EX' then
            --
            vn_fase := 8;
            -- Se for entrada informar grupo 2 sen�o grupo 6
            vn_dummy := fkg_tem_grupo_cfop ( en_conhectransp_id => en_conhectransp_id
                                           , en_grupo_cfop      => case when vn_dm_ind_oper = 0 then 2 else 6 end
                                           );
            --
         elsif vv_uf_dest = 'EX' then
            --
            vn_fase := 9;
            -- Se for entrada informar grupo 3 sen�o grupo 7
            vn_dummy := fkg_tem_grupo_cfop ( en_conhectransp_id => en_conhectransp_id
                                           , en_grupo_cfop      => case when vn_dm_ind_oper = 0 then 3 else 7 end
                                           );
            --
         end if;
         --
         vn_fase := 9;
         --
         if nvl(vn_dummy,0) > 0 then
            --
            vn_fase := 10;
            --
            gv_mensagem_log := 'CFOP informado no registro anal�tico est� divergente para o participante do Conhecimento de Transporte. Emitente = '||
                               vv_uf_emit||' e Destinat�rio = '||vv_uf_dest||'. Dentro do estado e Opera��o/Aquisi��o ser� permitido CFOP de in�cio 1. '||
                               'Dentro do estado com Opera��o/Presta��o ser� permitido CFOP de in�cio 5. Dentro do pa�s e Opera��o/Aquisi��o ser� permitido '||
                               'CFOP de in�cio 2. Dentro do pa�s com Opera��o/Presta��o ser� permitido CFOP de in�cio 6. Fora do pa�s com Opera��o/Aquisi��o '||
                               'ser� permitido CFOP de in�cio 3. Fora do pa�s com Opera��o/Presta��o ser� permitido CFOP de in�cio 7.';
            --
            vn_loggenerico_id := null;
            --
            pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                              , ev_mensagem       => gv_cabec_log
                                              , ev_resumo         => gv_mensagem_log
                                              , en_tipo_log       => ERRO_DE_VALIDACAO
                                              , en_referencia_id  => gn_referencia_id
                                              , ev_obj_referencia => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na mem�ria
            -- pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
            --                                      , est_log_generico  => est_log_generico );
            --
         end if;
         --
      end if;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      rollback;
      --
      gv_mensagem_log := 'Erro na pkb_valida_cfop_por_part fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%type;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => ERRO_DE_SISTEMA
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                              , est_log_generico  => est_log_generico );
         --
      exception
         when others then
            null;
      end;
      --
END PKB_VALIDA_CFOP_POR_PART;
-------------------------------------------------------------------------------------------------------
-- Procedure que consiste os dados do Conhecimento de Transporte
-------------------------------------------------------------------------------------------------------
procedure pkb_consiste_cte(est_log_generico   in out nocopy dbms_sql.number_table,
                           en_conhectransp_id in Conhec_Transp.Id%TYPE) is
  --
  vn_fase           number := 0;
  vn_loggenerico_id log_generico_ct.id%TYPE;
  vv_desc_tipo_emit dominio.descr%type;
  --
begin
  --
  -- Observa��o: As informa��es do PIS e COFINS, para conhec. de transp., s� s�o informados uma �nica vez
  -- nas tabelas ct_comp_doc_pis e ct_comp_doc_cofins. N�o h� tabela de totais com informa��es de PIS e COFINS.
  -- As demais valida��es j� s�o realizadas na pr�pria procedure e inser��o.
  --
  vn_fase := 1;
  --| Procedimento v�lida informa��o dos Valores da Presta��o de Servico
  pkb_valida_ct_vlprest(est_log_generico   => est_log_generico,
                        en_conhectransp_id => en_conhectransp_id);
  --
  vn_fase := 2;
  --| Procedimento v�lida informa��o relativa aos impostos
  pkb_valida_conhec_transp_imp(est_log_generico   => est_log_generico,
                               en_conhectransp_id => en_conhectransp_id);
  --
  vn_fase := 3;
  -- V�lida informa��o do analitico do conhecimento de transporte
  pkb_valida_ct_d190(est_log_generico   => est_log_generico,
                     en_conhectransp_id => en_conhectransp_id);
  vn_fase := 4;
  -- V�lida informa��o dos valores de PIS do conhecimento de transporte
  pkb_valida_ct_d101(est_log_generico   => est_log_generico,
                     en_conhectransp_id => en_conhectransp_id);
  --
  vn_fase := 5;
  -- V�lida informa��o dos valores de COFINS do conhecimento de transporte
  pkb_valida_ct_d105(est_log_generico   => est_log_generico,
                     en_conhectransp_id => en_conhectransp_id);
  --
  vn_fase := 6;
  -- V�lida informa��o dos valores de PIS do conhecimento de transporte
  pkb_valida_ct_d100(est_log_generico   => est_log_generico,
                     en_conhectransp_id => en_conhectransp_id);
  --
  vn_fase := 7;
  --
  pkb_valida_cfop_por_part(est_log_generico   => est_log_generico,
                           en_conhectransp_id => en_conhectransp_id);
  --
  vn_fase := 8;
  --
  if gv_obj_referencia = 'CONHEC_TRANSP' then
    --
    if nvl(gt_row_conhec_transp.dm_ind_emit, 1) = 0 then
    
      -- Recupera a descri��o (Emiss�o pr�pria)
      vv_desc_tipo_emit := pk_csf.fkg_dominio(ev_dominio => 'CONHEC_TRANSP.DM_IND_EMIT',
                                              ev_vl      => upper(0));
    
      -- Se n�o cont�m erro de valida��o, Grava o Log de Conhecimento de Transporte Integrado - Terceiros
      gv_mensagem_log := 'Conhecimento de Transporte Integrado - ' || vv_desc_tipo_emit;
      --
      if nvl(est_log_generico.count, 0) = 0 then
        --
        gv_mensagem_log := gv_mensagem_log || ' e validado.';
        --
      end if;
      --
      vn_fase := 99.2;
      --
      pk_csf_api_ct.pkb_log_generico_ct(sn_loggenerico_id => vn_loggenerico_id,
                                        ev_mensagem       => gv_cabec_log,
                                        ev_resumo         => gv_mensagem_log,
                                        en_tipo_log       => conhec_transp_integrado,
                                        en_referencia_id  => gn_referencia_id,
                                        ev_obj_referencia => gv_obj_referencia);
      --
    elsif nvl(gt_row_conhec_transp.dm_ind_emit, 1) = 1 then
    
      -- Recupera a descri��o (Terceiros)
      vv_desc_tipo_emit := pk_csf.fkg_dominio(ev_dominio => 'CONHEC_TRANSP.DM_IND_EMIT',
                                              ev_vl      => upper(1));
    
      -- Se n�o cont�m erro de valida��o, Grava o Log de Conhecimento de Transporte Integrado - Emiss�o pr�pria
      gv_mensagem_log := 'Conhecimento de Transporte Integrado - ' || vv_desc_tipo_emit;
      --
      if nvl(est_log_generico.count, 0) = 0 then
        --
        gv_mensagem_log := gv_mensagem_log || ' e validado.';
        --
      end if;
      --
      vn_fase := 99.3;
      --
      pk_csf_api_ct.pkb_log_generico_ct(sn_loggenerico_id => vn_loggenerico_id,
                                        ev_mensagem       => gv_cabec_log,
                                        ev_resumo         => gv_mensagem_log,
                                        en_tipo_log       => conhec_transp_integrado,
                                        en_referencia_id  => gn_referencia_id,
                                        ev_obj_referencia => gv_obj_referencia);
      --
    end if;
    --
  end if;
  --
exception
  when others then
    --
    rollback;
    --
    gv_mensagem_log := 'Erro na pkb_consiste_cte fase(' || vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_ct.id%TYPE;
    begin
      --
      pk_csf_api_ct.pkb_log_generico_ct(sn_loggenerico_id => vn_loggenerico_id,
                                        ev_mensagem       => gv_cabec_log,
                                        ev_resumo         => gv_mensagem_log,
                                        en_tipo_log       => ERRO_DE_SISTEMA,
                                        en_referencia_id  => gn_referencia_id,
                                        ev_obj_referencia => gv_obj_referencia);
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct(en_loggenerico   => vn_loggenerico_id,
                                           est_log_generico => est_log_generico);
      --
    exception
      when others then
        null;
    end;
    --
end pkb_consiste_cte;
-------------------------------------------------------------------------------------------------------------------------------------
-- Fun��o para validar os conhecimentos de transporte D100 - utilizada nas rotinas de valida��es da GIA, Sped Fiscal e Contribui��es
-------------------------------------------------------------------------------------------------------------------------------------
FUNCTION FKG_VALIDA_CTE ( EN_EMPRESA_ID      IN  EMPRESA.ID%TYPE
                        , ED_DT_INI          IN  DATE
                        , ED_DT_FIN          IN  DATE
                        , EV_OBJ_REFERENCIA  IN  log_generico_ct.OBJ_REFERENCIA%TYPE
                        , EN_REFERENCIA_ID   IN  log_generico_ct.REFERENCIA_ID%TYPE )
         RETURN BOOLEAN IS
   --
   vn_fase          number;
   vt_log_generico  dbms_sql.number_table;
   --
   cursor c_conhec is
      select ct.id conhectransp_id
           , ct.empresa_id
           , ct.dm_ind_emit
        from conhec_transp ct
       where ct.empresa_id      = en_empresa_id
         and ct.dm_st_proc      = 4 -- Autorizada
         and ct.dm_arm_cte_terc = 0
         and ct.dm_ind_emit     = 1 -- 0-emiss�o pr�pria, 1-terceiros
         and nvl(ct.dt_sai_ent, ct.dt_hr_emissao) between ed_dt_ini and ed_dt_fin
    order by ct.id;
   --
BEGIN
   --
   vn_fase := 1;
   --
   pkb_seta_tipo_integr ( en_tipo_integr => 0 ); -- 0-Valida e registra Log, 1-Valida, registra Log e insere a informa��o
   --
   pkb_seta_obj_ref ( ev_objeto => ev_obj_referencia );
   --
   gn_referencia_id := en_referencia_id;
   --
   vn_fase := 2;
   --
   for rec in c_conhec
   loop
      --
      exit when c_conhec%notfound or (c_conhec%notfound) is null;
      --
      vn_fase := 3;
      --
      pkb_consiste_cte ( est_log_generico   => vt_log_generico
                       , en_conhectransp_id => rec.conhectransp_id );
      --
   end loop;
   --
   vn_fase := 4;
   --
   if nvl(vt_log_generico.count,0) > 0 then
      return false;
   else
      return true;
   end if;
   --
EXCEPTION
   when others then
      raise_application_error(-20101, 'Problemas em pk_csf_api_d100.fkg_valida_cte (fase = '||vn_fase||' empresa_id = '||en_empresa_id||' per�odo de '||
                                      to_char(ed_dt_ini,'dd/mm/yyyy')||' at� '||to_char(ed_dt_fin,'dd/mm/yyyy')||' objeto = '||ev_obj_referencia||
                                      ' referencia_id = '||en_referencia_id||'). Erro = '||sqlerrm);
END FKG_VALIDA_CTE;
-------------------------------------------------------------------------------------------------------
-- Procedimento inclus�o da ocorr�ncia de altera��es nos dados do conhecimento de transporte
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_INCLUI_LOG_CONHEC_TRANSP( EN_CONHECTRANSP_ID IN CONHEC_TRANSP.ID%TYPE
                                      , EV_RESUMO          IN LOG_CONHEC_TRANSP.RESUMO%TYPE
                                      , EV_MENSAGEM        IN LOG_CONHEC_TRANSP.MENSAGEM%TYPE
                                      , EN_USUARIO_ID      IN NEO_USUARIO.ID%TYPE
                                      , EV_MAQUINA         IN VARCHAR2 ) IS
   --
   pragma   autonomous_transaction;
   --
BEGIN
   --
   insert into log_conhec_transp( id
                                , conhectransp_id
                                , dt_hr_log
                                , resumo
                                , mensagem
                                , usuario_id
                                , maquina )
                          values( logconhectransp_seq.nextval
                                , en_conhectransp_id
                                , sysdate
                                , ev_resumo
                                , ev_mensagem
                                , en_usuario_id
                                , ev_maquina );
   --
   commit;
   --
EXCEPTION
   when others then
      raise_application_error (-20101, 'Problemas ao incluir log/altera��o - pkb_inclui_log_conhec_transp (conhectransp_id = '||en_conhectransp_id||
                                       '). Erro = '||sqlerrm);
END PKB_INCLUI_LOG_CONHEC_TRANSP;

-------------------------------------------------------------------------------------------------------
--| Procedimento Valida o Conhecimento de Transporte conforme ID
-------------------------------------------------------------------------------------------------------
procedure pkb_validar ( en_conhectransp_id in conhec_transp.id%type
                      )
is
   --
   vn_fase             number := 0;
   vt_log_generico     dbms_sql.number_table;
   vn_loggenerico_id   number;
   vv_cod_mod          mod_fiscal.cod_mod%type;
   vt_conhec_transp    conhec_transp%rowtype;
   vn_qtde_erro_chave  number := 0;
   vn_valida           number(1);
   vn_dm_forma_emiss   conhec_transp.dm_forma_emiss%type;
   --
begin
   --
   vn_fase := 1;
   --
   gn_referencia_id := en_conhectransp_id;
   gv_obj_referencia := 'CONHEC_TRANSP';
   --
   vn_fase := 1.1;
   --
   if nvl(en_conhectransp_id,0) > 0 then
      --
      vn_fase := 2;
      --
      vt_log_generico.delete;
      --
      vn_fase := 2.1;
      --
      gv_cabec_log := '';
      --
      -- monta dados do CTE
      begin
         --
         select ct.*
           into vt_conhec_transp
           from conhec_transp ct
          where ct.id = en_conhectransp_id;
         --
         vv_cod_mod := pk_csf.fkg_cod_mod_id(vt_conhec_transp.modfiscal_id);
         --
      exception
         when others then
            vt_conhec_transp := null;
      end;
      --
      gv_cabec_log := gv_cabec_log || 'N�mero: ' || vt_conhec_transp.nro_ct;
      gv_cabec_log := gv_cabec_log || chr(10) || 'S�rie: ' || vt_conhec_transp.serie;
      gv_cabec_log := gv_cabec_log || chr(10) || 'Participante: ' || pk_csf.fkg_nome_pessoa_id ( en_pessoa_id => vt_conhec_transp.pessoa_id );
      --
      vn_fase := 2.1;
      --
      -- Valida��o / Gera��o de Chave de acesso ---------------------------------------------------------------------------------
      if trim(vv_cod_mod) in ('57', '67') then
         --
         vn_fase := 2.11;
         --
         -- Se n�o informado a chave de acesso na integra��o, gera ela
         if vt_conhec_transp.nro_chave_cte is null then
            --
            vn_fase := 2.111;
            --
            pk_csf_api_ct.pkb_integr_CTChave_Refer(est_log_generico   => vt_log_generico,
                                                   en_empresa_id      => vt_conhec_transp.empresa_id,
                                                   en_conhectransp_id => vt_conhec_transp.id,
                                                   ed_dt_hr_emissao   => vt_conhec_transp.dt_hr_emissao,
                                                   ev_cod_mod         => vv_cod_mod,
                                                   en_serie           => vt_conhec_transp.serie,
                                                   en_nro_ct          => vt_conhec_transp.nro_ct,
                                                   en_dm_forma_emiss  => vt_conhec_transp.dm_forma_emiss,
                                                   esn_cCT_cte        => vt_conhec_transp.cct_cte,
                                                   sn_dig_verif_chave => vt_conhec_transp.dig_verif_chave,
                                                   sv_nro_chave_cte   => vt_conhec_transp.nro_chave_cte);
            --
            vn_fase := 2.112;
            --
            -- Atualiza o n�mero da chave gerado no conhecimento de Transporte
            update conhec_transp ct
               set ct.nro_chave_cte = vt_conhec_transp.nro_chave_cte
            where ct.id = vt_conhec_transp.id;
            --
         else -- Se informado o numero da chave na integra��o, valida se ela est� correta ---------------------------
            --
            vn_fase := 2.121;
            --
            -- Recupera forma de emissao da chave do conhecimento
            vn_dm_forma_emiss := trim( substr(vt_conhec_transp.nro_chave_cte, 35, 1) );
            --
            vn_fase := 2.122;
            --
            -- Verifica se o campo � validado para o tipo de conhecimento de transporte
            vn_valida := pk_csf_ct.fkg_ret_valid_integr ( en_conhectransp_id => null
                                                        , en_dm_ind_emit     => vt_conhec_transp.dm_ind_emit
                                                        , en_dm_legado       => null --vt_conhec_transp.dm_legado
                                                        , en_dm_forma_emiss  => vn_dm_forma_emiss 
                                                        , ev_campo           => 'NRO_CHAVE_CTE' );
                                                        
            --
            if nvl(vn_valida,0) in (0,1) then
               --
               pk_csf_api_ct.pkb_valida_chave_acesso(est_log_generico   => vt_log_generico,
                                                     ev_nro_chave_cte   => vt_conhec_transp.nro_chave_cte,
                                                     en_empresa_id      => vt_conhec_transp.empresa_id,
                                                     en_pessoa_id       => vt_conhec_transp.pessoa_id,
                                                     en_dm_ind_emit     => vt_conhec_transp.dm_ind_emit,
                                                     ed_dt_hr_emissao   => trunc(vt_conhec_transp.dt_hr_emissao),
                                                     ev_cod_mod         => vv_cod_mod,
                                                     en_serie           => vt_conhec_transp.serie,
                                                     en_nro_ct          => vt_conhec_transp.nro_ct,
                                                     en_dm_forma_emiss  => vt_conhec_transp.dm_forma_emiss,
                                                     sn_cCT_cte         => vt_conhec_transp.cct_cte,
                                                     sn_dig_verif_chave => vt_conhec_transp.dig_verif_chave,
                                                     sn_qtde_erro       => vn_qtde_erro_chave);
              --
              if nvl(vn_qtde_erro_chave,0) > 0 then
                 --
                 gv_mensagem_log := 'A "Chave do CT-e" est� inv�lida (' || trim(vt_conhec_transp.nro_chave_cte) || ').'||
                                    'Erro Retornado: '|| pk_csf_api_ct.gv_mensagem_log;
                 --
                 vn_loggenerico_id := null;
                 --
                 pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                                   , ev_mensagem        => gv_cabec_log
                                                   , ev_resumo          => gv_mensagem_log
                                                   , en_tipo_log        => ERRO_DE_VALIDACAO
                                                   , en_referencia_id   => gn_referencia_id
                                                   , ev_obj_referencia  => gv_obj_referencia
                                                   );
                 --
                 -- Armazena o "loggenerico_id" na mem�ria
                 pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                                      , est_log_generico  => vt_log_generico
                                                      );
               --
               end if;
               --
            end if;
            --
         end if;
         --
      end if;
      --
      vn_fase := 2.2;
      --
      -----------------------------
      -- Processos que consistem a informa��o do Conhecimento de Transporte
      -----------------------------
      pkb_consiste_cte ( est_log_generico   => vt_log_generico
                       , en_conhectransp_id => en_conhectransp_id
                       );
      --
      vn_fase := 2.3;
      --
      if nvl(vt_log_generico.count,0) > 0 and
       pk_csf_api_ct.fkg_ver_erro_log_generico_ct( en_conhectransp_id ) = 1 then  -- Verifica se existe log de erro no processo
         --
         update conhec_transp set dm_st_proc = 10
          where id = en_conhectransp_id;
        --
      else
        --
        update conhec_transp set dm_st_proc = 4
         where dm_ind_emit = 1
           and id = en_conhectransp_id;
        --
      end if;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      --
      rollback;
      --
      gv_mensagem_log := 'Erro na pkb_validar fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => ERRO_DE_SISTEMA
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia
                                           );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_validar;

------------------------------------------------------------------------------------------------------------------

-- Procedimento valida o mult org de acordo com o COD e o HASH das tabelas Flex-Field

procedure pkb_val_atrib_multorg ( est_log_generico   in out nocopy  dbms_sql.number_table
                                , ev_obj_name        in             VARCHAR2
                                , ev_atributo        in             VARCHAR2
                                , ev_valor           in             VARCHAR2
                                , sv_cod_mult_org    out            VARCHAR2
                                , sv_hash_mult_org   out            VARCHAR2
                                , ev_obj_referencia  in             log_generico_ct.obj_referencia%type
                                , en_referencia_id   in             log_generico_ct.referencia_id%type
                                )


is
   --
   vn_fase              number := 0;
   vn_loggenericoct_id  log_generico_ct.id%type;
   vv_mensagem          varchar2(1000) := null;
   vn_dmtipocampo       ff_obj_util_integr.dm_tipo_campo%type;
   vv_hash_mult_org     mult_org.hash%type;
   vv_cod_mult_org      mult_org.cd%type;
  --
begin
 --
   vn_fase := 1;
   --
   gv_mensagem_log := null;
   --
   gn_referencia_id   := en_referencia_id;
   gv_obj_referencia  := ev_obj_referencia;
   --
   vn_fase := 2;
   --
   if trim(ev_valor) is null then
      --
      vn_fase := 3;
      --
      gv_mensagem_log := 'C�digo ou HASH da Mult-Organiza��o (objeto: '|| ev_obj_name ||'): "VALOR" referente ao atributo deve ser informado.';
      --
      vn_loggenericoct_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct( sn_loggenerico_id  => vn_loggenericoct_id
                                       , ev_mensagem        => gv_mensagem_log
                                       , ev_resumo          => gv_cabec_log
                                       , en_tipo_log        => INFORMACAO
                                       , en_referencia_id   => gn_referencia_id
                                       , ev_obj_referencia  => gv_obj_referencia );
      --
   end if;
   --
   vn_fase := 4;
   --
   vv_mensagem := pk_csf.fkg_ff_verif_campos( ev_obj_name => ev_obj_name
                                            , ev_atributo => trim(ev_atributo)
                                            , ev_valor    => trim(ev_valor) );
   --
   vn_fase := 5;
   --
   if vv_mensagem is not null then
      --
      vn_fase := 6;
      --
      gv_mensagem_log := vv_mensagem;
      --
      vn_loggenericoct_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct( sn_loggenerico_id  => vn_loggenericoct_id
                                       , ev_mensagem        => gv_mensagem_log
                                       , ev_resumo          => gv_cabec_log
                                       , en_tipo_log        => INFORMACAO
                                       , en_referencia_id   => gn_referencia_id
                                       , ev_obj_referencia  => gv_obj_referencia );
      --
   else
       --
      vn_fase := 7;
      --
      vn_dmtipocampo := pk_csf.fkg_ff_retorna_dmtipocampo( ev_obj_name => ev_obj_name
                                                         , ev_atributo => trim(ev_atributo) );
      --
      vn_fase := 8;
      --
      if trim(ev_valor) is not null then
         --
         vn_fase := 9;
         --
         if vn_dmtipocampo = 2 then -- tipo de campo = 0-data, 1-num�rico, 2-caractere
            --
            vn_fase := 10;
            --
            if trim(ev_atributo) = 'COD_MULT_ORG' then
                --
                vn_fase := 11;
                --
                begin
                   vv_cod_mult_org := pk_csf.fkg_ff_ret_vlr_caracter( ev_obj_name => ev_obj_name
                                                                    , ev_atributo => trim(ev_atributo)
                                                                    , ev_valor    => trim(ev_valor) );
                exception
                   when others then
                      vv_cod_mult_org := null;
                end;
                --
            elsif trim(ev_atributo) = 'HASH_MULT_ORG' then
               --
                vn_fase := 12;
                --
                begin
                   vv_hash_mult_org := pk_csf.fkg_ff_ret_vlr_caracter( ev_obj_name => ev_obj_name
                                                                     , ev_atributo => trim(ev_atributo)
                                                                     , ev_valor    => trim(ev_valor) );
                exception
                   when others then
                      vv_hash_mult_org := null;
                end;
                --
            end if;
            --
         else
            --
            vn_fase := 13;
            --
            gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR informado n�o confere com o tipo de campo, deveria ser CARACTERE.';
            --
            vn_loggenericoct_id := null;
            --
            pk_csf_api_ct.pkb_log_generico_ct( sn_loggenerico_id => vn_loggenericoct_id
                                             , ev_mensagem       => gv_mensagem_log
                                             , ev_resumo         => gv_cabec_log
                                             , en_tipo_log       => INFORMACAO
                                             , en_referencia_id  => gn_referencia_id
                                             , ev_obj_referencia => gv_obj_referencia );
            --
         end if;
         --
      end if;
      --
   end if;
   --
   vn_fase := 14;
   --
   sv_cod_mult_org := vv_cod_mult_org;
   --
   sv_hash_mult_org := vv_hash_mult_org;
--
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_val_atrib_multorg fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericoct_id  log_generico.id%type;
      begin
         pk_csf_api_ct.pkb_log_generico_ct( sn_loggenerico_id  => vn_loggenericoct_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_cabec_log
                                          , en_tipo_log        => erro_de_validacao
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia );
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct( en_loggenerico    => vn_loggenericoct_id
                                             , est_log_generico  => est_log_generico );
      exception
         when others then
            null;
      end;
end pkb_val_atrib_multorg;

-------------------------------------------------------------------------------------------------------

procedure pkb_ret_multorg_id( est_log_generico       in out nocopy  dbms_sql.number_table
                            , ev_cod_mult_org        in             mult_org.cd%type
                            , ev_hash_mult_org       in             mult_org.hash%type
                            , sn_multorg_id          in out nocopy  mult_org.id%type
                            , ev_obj_referencia      in             log_generico_ct.obj_referencia%type
                            , en_referencia_id       in             log_generico_ct.referencia_id%type)
is
   vn_fase               number := 0;
   vv_multorg_hash       mult_org.hash%type;
   vn_multorg_id         mult_org.id%type;
   vn_loggenericoct_id  Log_Generico_ct.id%type;
   vn_dm_obrig_integr    mult_org.dm_obrig_integr%type;

begin
   --
   vn_fase := 1;
   --
   gn_referencia_id   := en_referencia_id;
   gv_obj_referencia  := ev_obj_referencia;
   --
   begin
      --
      select mo.hash, mo.id, mo.dm_obrig_integr
        into vv_multorg_hash, vn_multorg_id, vn_dm_obrig_integr
        from mult_org mo
       where mo.cd = ev_cod_mult_org;
      --
      vn_fase := 2;
      --
   exception
      when no_data_found then
         --
         vn_fase := 3;
         --
         vv_multorg_hash := null;
         --
         vn_multorg_id := 0;
         --
      when others then
         --
         vn_fase := 4;
         --
         vv_multorg_hash := null;
         --
         vn_multorg_id := 0;
         --
         gv_mensagem_log := 'Problema ao tentar buscar o Mult Org. Fase: '||vn_fase;
         gv_cabec_log :=  'Codigo do MultOrg: |' || ev_cod_mult_org || '| Hash do MultOrg: |'||ev_hash_mult_org||'|';
         --
         vn_loggenericoct_id := null;
         --
         pk_csf_api_ct.pkb_log_generico_ct( sn_loggenerico_id  => vn_loggenericoct_id
                                          , ev_mensagem           => gv_mensagem_log
                                          , ev_resumo             => gv_cabec_log
                                          , en_tipo_log           => ERRO_DE_VALIDACAO
                                          , en_referencia_id      => gn_referencia_id
                                          , ev_obj_referencia     => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct( en_loggenerico    => vn_loggenericoct_id
                                             , est_log_generico  => est_log_generico );
   --
   end;
   --
   vn_fase := 5;
   --
   if nvl(vn_multorg_id, 0) = 0 then

      gv_mensagem_log := 'O Mult Org de codigo: |' || ev_cod_mult_org || '| n�o existe.';
      --
      vn_loggenericoct_id := null;
      --
      vn_fase := 5.1;
      --
      if vn_dm_obrig_integr = 0 then -- N�o validar o multorg.
         --
         vn_fase := 5.2;
         --
         pk_csf_api_ct.pkb_log_generico_ct( sn_loggenerico_id  => vn_loggenericoct_id
                                          , ev_mensagem           => gv_mensagem_log
                                          , ev_resumo             => gv_mensagem_log
                                          , en_tipo_log           => INFORMACAO
                                          , en_referencia_id      => gn_referencia_id
                                          , ev_obj_referencia     => gv_obj_referencia
                                          );
         --
      elsif vn_dm_obrig_integr = 1 then -- Validar o multorg.
         --
         vn_fase := 5.3;
         --
         pk_csf_api_ct.pkb_log_generico_ct( sn_loggenerico_id  => vn_loggenericoct_id
                                          , ev_mensagem           => gv_mensagem_log
                                          , ev_resumo             => gv_mensagem_log
                                          , en_tipo_log           => ERRO_DE_VALIDACAO
                                          , en_referencia_id      => gn_referencia_id
                                          , ev_obj_referencia     => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct( en_loggenerico    => vn_loggenericoct_id
                                             , est_log_generico  => est_log_generico );
         --
      end if;
      --
   elsif vv_multorg_hash != ev_hash_mult_org then
      --
      vn_fase := 6;
      --
      gv_mensagem_log := 'O valor do Hash ('|| ev_hash_mult_org ||') do Mult Org:'|| ev_cod_mult_org ||'esta incorreto.';
      --
      vn_loggenericoct_id := null;
      --
      if vn_dm_obrig_integr = 0 then -- N�o validar o multorg.
         --
         vn_fase := 5.2;
         --
         pk_csf_api_ct.pkb_log_generico_ct( sn_loggenerico_id  => vn_loggenericoct_id
                                          , ev_mensagem           => gv_mensagem_log
                                          , ev_resumo             => gv_mensagem_log
                                          , en_tipo_log           => INFORMACAO
                                          , en_referencia_id      => gn_referencia_id
                                          , ev_obj_referencia     => gv_obj_referencia
                                          );
         --
      elsif vn_dm_obrig_integr = 1 then -- Validar o multorg.
         --
         vn_fase := 5.3;
         --
         pk_csf_api_ct.pkb_log_generico_ct( sn_loggenerico_id  => vn_loggenericoct_id
                                          , ev_mensagem           => gv_mensagem_log
                                          , ev_resumo             => gv_mensagem_log
                                          , en_tipo_log           => ERRO_DE_VALIDACAO
                                          , en_referencia_id      => gn_referencia_id
                                          , ev_obj_referencia     => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct( en_loggenerico    => vn_loggenericoct_id
                                             , est_log_generico  => est_log_generico );
         --
      end if;
      --
   end if;
   --
   vn_fase := 7;
   --
   sn_multorg_id := vn_multorg_id;
   --
exception
   when others then
      raise_application_error (-20101, 'Problemas ao validar Mult Org - pk_csf_api_ct.pkb_ret_multorg_id. Fase: '||vn_fase||' Erro = '||sqlerrm);
end pkb_ret_multorg_id;
-------------------------------------------------------------------------------------------------------

-- Procedimento Integra as Informa��es relativas ao diferencial de aliquota
procedure pkb_integr_ct_dif_aliq ( est_log_generico           in out nocopy dbms_sql.number_table
                                 , est_row_ct_dif_aliq        in out nocopy ct_dif_aliq%rowtype
                                 , en_conhectransp_id         in            Conhec_Transp.id%TYPE )
is
   --
   vn_fase           number := 0;
   vn_loggenerico_id log_generico_ct.id%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf_ct.fkg_cte_nao_integrar ( en_conhectransp_id => en_conhectransp_id ) then
      --
      goto sair_integr;
      --
   end if;
   --
   vn_fase := 1.1;
   --
   if nvl(est_row_ct_dif_aliq.conhectransp_id,0) = 0 and
      nvl(est_log_generico.count,0) = 0              then
      --
      vn_fase := 1.2;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'N�o informado o Conhec. Transp. para o diferencial de aliquota';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_SISTEMA
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 2;
   --
   if nvl(est_row_ct_dif_aliq.aliq_interna,0) <= 0 then
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Difal - Aliquota interna da empresa que est� dando entrada no conhecimento n�o pode se zero ou negativa. Informe uma aliquota maior que zero.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_SISTEMA
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 3; 
   --   
   if nvl(est_row_ct_dif_aliq.aliq_ie,0) <= 0 then
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Difal - Aliquota interestadual utilizada na emiss�o do documento n�o pode se zero ou negativa. Informe uma aliquota maior que zero.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_SISTEMA
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;   
   --
   vn_fase := 4; 
   --   
   if nvl(est_row_ct_dif_aliq.bc_dif_aliq,0) <= 0 then
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Difal - Base de calculo a ser considerada para calculo do Difal n�o pode se zero ou negativa. Informe uma base de calculo maior que zero.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_SISTEMA
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;   
   --
   vn_fase := 5; 
   --   
   if nvl(est_row_ct_dif_aliq.vl_dif_aliq,0) <= 0 then
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Difal - Valor do diferencial de aliquota n�o pode se zero ou negativa. Informe uma valor de diferencial maior que zero.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_SISTEMA
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;   
   --  
   vn_fase := 6; 
   --   
   if nvl(est_row_ct_dif_aliq.bc_fcp,0) < 0 then
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Difal - Base de calculo de Fundo de Combate a Pobreza n�o pode ser negativa, caso o mesmo seja exigido na opera��o. Informe uma base de FCP maior ou igual a zero.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_SISTEMA
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;   
   -- 
   vn_fase := 7; 
   --   
   if nvl(est_row_ct_dif_aliq.aliq_fcp,0) < 0 then
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Difal - Aliquota do Fundo de Combate a Pobreza n�o pode ser negativa, caso o mesmo seja exigido na opera��o. Informe uma aliquota de FCP maior ou igual a zero.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_SISTEMA
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;   
   -- 
   vn_fase := 8; 
   --   
   if nvl(est_row_ct_dif_aliq.vl_fcp,0) < 0 then
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Difal - Valor do Fundo de Combate a Pobreza n�o pode ser negativo, caso o mesmo seja exigido na opera��o. Informe um valor de FCP maior ou igual a zero.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_SISTEMA
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if; 
   -- 
   vn_fase := 9;
   --   
   if nvl(est_row_ct_dif_aliq.dm_tipo, -1) not in (0, 1, 2, 3, 4, 5) then
      --
      vn_fase := 15.7;
      --
      gv_mensagem_log := 'Difal - A forma de gera��o do registro est� invalida. O valores possiv�is s�o de 0 (zero) a 5 (cinco). (' || est_row_ct_dif_aliq.dm_tipo || ').';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_cabec_log
                                        , ev_resumo          => gv_mensagem_log
                                        , en_tipo_log        => ERRO_DE_VALIDACAO
                                        , en_referencia_id   => gn_referencia_id
                                        , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                           , est_log_generico  => est_log_generico );
      --
   end if;   
   --   
   vn_fase := 99;
   --
   -- Se n�o foi encontrado erro e o Tipo de Integra��o � 1 (V�lida e insere)
   -- ent�o realiza a condi��o de inserir o imposto
   if nvl(est_log_generico.count,0) > 0 and
      pk_csf_api_ct.fkg_ver_erro_log_generico_ct( en_conhec_transp_id => est_row_ct_dif_aliq.conhectransp_id ) = 1  then
      --
      vn_fase := 99.1;
      --
      update conhec_transp set dm_st_proc = 10
       where id = est_row_ct_dif_aliq.conhectransp_id;

      --
   end if;
   --
   vn_fase := 99.2;
   --
   if nvl(est_row_ct_dif_aliq.conhectransp_id, 0) > 0 and
      nvl(est_row_ct_dif_aliq.aliq_interna,0) > 0 and
      nvl(est_row_ct_dif_aliq.aliq_ie,0) > 0 and
      nvl(est_row_ct_dif_aliq.bc_dif_aliq,0) > 0 and
      nvl(est_row_ct_dif_aliq.vl_dif_aliq,0) > 0 and
      nvl(est_row_ct_dif_aliq.dm_tipo, -1) in (0, 1, 2, 3, 4, 5) then	  
      --
      vn_fase := 99.4;
      --
      if nvl(gn_tipo_integr,0) = 1 then
         --
         vn_fase := 99.5;
         --
         select ctdifaliq_seq.nextval
           into est_row_ct_dif_aliq.id
           from dual;
         --
         vn_fase := 99.6;
         --
         insert into ct_dif_aliq ( id
                                 , conhectransp_id
                                 , aliq_interna
                                 , aliq_ie
                                 , bc_dif_aliq
                                 , vl_dif_aliq
                                 , bc_fcp
                                 , aliq_fcp
                                 , vl_fcp
                                 , dm_tipo
                                 )
                         values ( est_row_ct_dif_aliq.id
                                , est_row_ct_dif_aliq.conhectransp_id
                                , est_row_ct_dif_aliq.aliq_interna
                                , est_row_ct_dif_aliq.aliq_ie
                                , est_row_ct_dif_aliq.bc_dif_aliq
                                , est_row_ct_dif_aliq.vl_dif_aliq
                                , est_row_ct_dif_aliq.bc_fcp
                                , est_row_ct_dif_aliq.aliq_fcp								
                                , est_row_ct_dif_aliq.vl_fcp
                                , est_row_ct_dif_aliq.dm_tipo
                                );
         --
      else
         --
         vn_fase := 99.7;
         --
         update ct_dif_aliq set aliq_interna = est_row_ct_dif_aliq.aliq_interna
                              , aliq_ie      = est_row_ct_dif_aliq.aliq_ie
                              , bc_dif_aliq  = est_row_ct_dif_aliq.bc_dif_aliq
                              , vl_dif_aliq  = est_row_ct_dif_aliq.vl_dif_aliq
                              , bc_fcp       = est_row_ct_dif_aliq.bc_fcp
                              , aliq_fcp     = est_row_ct_dif_aliq.aliq_fcp
                              , vl_fcp       = est_row_ct_dif_aliq.vl_fcp
                              , dm_tipo      = est_row_ct_dif_aliq.dm_tipo
          where id = est_row_ct_dif_aliq.id;
         --
      end if;
      --
   end if;
   --
   <<sair_integr>>
   null;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_integr_ct_dif_aliq fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => ERRO_DE_SISTEMA
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_csf_api_ct.pkb_gt_log_generico_ct ( en_loggenerico    => vn_loggenerico_id
                                              , est_log_generico  => est_log_generico );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_ct_dif_aliq;
-------------------------------------------------------------------------------------------------------
--
end pk_csf_api_d100;
/
