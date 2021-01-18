create or replace package body csf_own.pk_apur_icms is

-------------------------------------------------------------------------------------------------------
--| Corpo do pacote de procedimentos de Gera��o da Apura��o de ICMS
-------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------
--
-- Procedimento para simplificar a chamda do log_generico
--
procedure pkb_grava_log_generico (en_referencia_id in log_generico_apur_iss.referencia_id%type
                                , en_tipo_log      in log_generico_apur_iss.csftipolog_id%type)
is
begin
   --       
   pk_log_generico.pkb_log_generico (sn_loggenerico_id => gn_loggenerico_id,
                                     ev_mensagem       => gv_resumo_log || gv_mensagem_log,
                                     ev_resumo         => gv_mensagem_log,
                                     en_tipo_log       => en_tipo_log,
                                     en_referencia_id  => en_referencia_id,
                                     ev_obj_referencia => gv_obj_referencia,
                                     en_empresa_id     => gn_empresa_id,
                                     en_dm_impressa    => 0);
   
   --
   if en_tipo_log in(ERRO_DE_VALIDACAO, ERRO_DE_SISTEMA) then
      gn_erro := gn_erro + 1;
   end if;   
   --
end pkb_grava_log_generico;
--

-- Fun��o retorna o saldo anterior
function fkg_saldo_credor_ant
         return apuracao_icms.vl_saldo_credor_ant%type
is
   --
   vn_vl_saldo_credor_ant apuracao_icms.vl_saldo_credor_ant%type := 0;
   --
begin
   --
   select vl_saldo_credor_transp
     into vn_vl_saldo_credor_ant
     from apuracao_icms
    where empresa_id                   = gt_row_apuracao_icms.empresa_id
      and to_char(dt_inicio, 'rrrrmm') = to_char(add_months(gt_row_apuracao_icms.dt_inicio, -1), 'rrrrmm')
      and dm_tipo                      = gt_row_apuracao_icms.dm_tipo
      and dm_situacao                  = 3; -- Processada
   --
   return nvl(vn_vl_saldo_credor_ant,0);
   --
exception
   when others then
      return 0;
end fkg_saldo_credor_ant;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna a Soma do ICMS para os registros C190, C590 e D590.
function fkg_som_vl_icms_c190_c590_d590
         return nfregist_analit.vl_icms%type
is
   --
   vn_vl_icms   nfregist_analit.vl_icms%type := 0;
   vn_vl_icms1  nfregist_analit.vl_icms%type := 0;
   vn_vl_icms2  nfregist_analit.vl_icms%type := 0;
   vn_vl_fcp_1  imp_itemnf.vl_fcp%type := 0;
   vn_vl_fcp_2  imp_itemnf.vl_fcp%type := 0;
   --
begin
   -- Recuperar os valores de ICMS do Registro Anal�tico
   select sum(nvl(r.vl_icms,0))
     into vn_vl_icms1
     from nota_fiscal      nf
        , sit_docto        sd
        , mod_fiscal       mf
        , nfregist_analit  r
        , cfop             c
    where nf.empresa_id      = gt_row_apuracao_icms.empresa_id
      and nf.dm_st_proc      = 4
      and nf.dm_arm_nfe_terc = 0 -- N�o � nota de armazenamento fiscal
      and nf.dm_ind_oper     = 1 -- Sa�da
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (nf.dm_ind_emit = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
      and sd.id              = nf.sitdocto_id
      and sd.cd             in ('00', '06', '08')
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and r.notafiscal_id    = nf.id
      and c.id               = r.cfop_id
      and c.cd          not in (5602, 5605, 5929, 6602, 6929);
   --
   select sum(nvl(r.vl_icms,0))
     into vn_vl_icms2
     from nota_fiscal      nf
        , sit_docto        sd
        , mod_fiscal       mf
        , nfregist_analit  r
        , cfop             c
    where nf.empresa_id      = gt_row_apuracao_icms.empresa_id
      and nf.dm_st_proc      = 4
      and nf.dm_arm_nfe_terc = 0 -- N�o � nota de armazenamento fiscal
      and nf.dm_ind_oper     = 0 -- Entrada
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (nf.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (nf.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
      and sd.id              = nf.sitdocto_id
      and sd.cd             in ('00', '06', '08')
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and r.notafiscal_id    = nf.id
      and c.id               = r.cfop_id
      and c.cd              in (1605);
   --
   if gt_row_apuracao_icms.dt_inicio >= to_date('01/08/2018','dd/mm/rrrr') then
      -- Recuperar os valores de FCP do Imposto ICMS do Item da Nota Fiscal
      select sum(nvl(ii.vl_fcp,0))
        into vn_vl_fcp_1
        from nota_fiscal      nf
           , sit_docto        sd
           , mod_fiscal       mf
           , item_nota_fiscal it
           , imp_itemnf       ii
           , tipo_imposto     ti
       where nf.empresa_id      = gt_row_apuracao_icms.empresa_id
         and nf.dm_st_proc      = 4
         and nf.dm_arm_nfe_terc = 0 -- N�o � nota de armazenamento fiscal
         and nf.dm_ind_oper     = 1 -- Sa�da
         and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
               or
              (nf.dm_ind_emit = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
         and sd.id              = nf.sitdocto_id
         and sd.cd             in ('00', '06', '08')
         and mf.id              = nf.modfiscal_id
         and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
         and it.notafiscal_id   = nf.id
         and it.cfop          not in (5602, 5605, 5929, 6602, 6929)
         and ii.itemnf_id       = it.id
         and ii.dm_tipo         = 0 -- imposto
         and ti.id              = ii.tipoimp_id
         and ti.cd              = 1; -- ICMS
      --
      select sum(nvl(ii.vl_fcp,0))
        into vn_vl_fcp_2
        from nota_fiscal      nf
           , sit_docto        sd
           , mod_fiscal       mf
           , item_nota_fiscal it
           , imp_itemnf       ii
           , tipo_imposto     ti
       where nf.empresa_id      = gt_row_apuracao_icms.empresa_id
         and nf.dm_st_proc      = 4
         and nf.dm_arm_nfe_terc = 0 -- N�o � nota de armazenamento fiscal
         and nf.dm_ind_oper     = 0 -- Entrada
         and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
               or
              (nf.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
               or
              (nf.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
         and sd.id              = nf.sitdocto_id
         and sd.cd             in ('00', '06', '08')
         and mf.id              = nf.modfiscal_id
         and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
         and it.notafiscal_id   = nf.id
         and it.cfop           in (1605)
         and ii.itemnf_id       = it.id
         and ii.dm_tipo         = 0 -- imposto
         and ti.id              = ii.tipoimp_id
         and ti.cd              = 1; -- ICMS
      --
   else
      --
      vn_vl_fcp_1 := 0;
      vn_vl_fcp_2 := 0;
      --
   end if;
   --
   vn_vl_icms := nvl(vn_vl_icms1,0) + nvl(vn_vl_icms2,0) + nvl(vn_vl_fcp_1,0) + nvl(vn_vl_fcp_2,0);
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_som_vl_icms_c190_c590_d590:' || sqlerrm);
end fkg_som_vl_icms_c190_c590_d590;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna a Soma do ICMS para os registro C320
function fkg_soma_vl_icms_c320
         return reg_an_res_dia_nf_venda_cons.vl_icms%type
is
   --
   vn_vl_icms reg_an_res_dia_nf_venda_cons.vl_icms%type := 0;
   --
begin
   --
   select sum(r.vl_icms) vl_icms
     into vn_vl_icms
     from res_dia_nf_venda_cons         nf
        , reg_an_res_dia_nf_venda_cons  r
        , cfop                          c
    where nf.empresa_id          = gt_row_apuracao_icms.empresa_id
      and trunc(nf.dt_doc) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)
      and r.resdianfvendacons_id = nf.id
      and c.id                   = r.cfop_id
      and c.cd              not in (5605);
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_vl_icms_c320:' || sqlerrm);
end fkg_soma_vl_icms_c320;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna a Soma do ICMS para os registro C390
function fkg_soma_vl_icms_c390
         return reg_anal_nf_venda_cons.vl_icms%type
is
   --
   vn_vl_icms reg_anal_nf_venda_cons.vl_icms%type := 0;
   --
begin
   --
   select sum(r.vl_icms) vl_icms
     into vn_vl_icms
     from nf_venda_cons           nf
        , reg_anal_nf_venda_cons  r
        , cfop                    c
    where nf.empresa_id          = gt_row_apuracao_icms.empresa_id
      and trunc(nf.dt_doc) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)
      and r.nfvendacons_id       = nf.id
      and c.id                   = r.cfop_id
      and c.cd              not in (5605);
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_vl_icms_c390:' || sqlerrm);
end fkg_soma_vl_icms_c390;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna a Soma do ICMS para os registro C490 e D390
function fkg_soma_vl_icms_c490_d390
         return reg_anal_nf_venda_cons.vl_icms%type
is
   --
   vn_vl_icms reg_anal_nf_venda_cons.vl_icms%type := 0;
   --
begin
   --
   select sum(r.vl_icms) vl_icms
     into vn_vl_icms
     from equip_ecf             e
        , reducao_z_ecf         z
        , reg_anal_mov_dia_ecf  r
        , cfop                  c
    where e.empresa_id          = gt_row_apuracao_icms.empresa_id
      and z.equipecf_id         = e.id
      and z.dm_st_proc          = 1 -- Validada
      and trunc(z.dt_doc) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)
      and r.reducaozecf_id      = z.id
      and c.id                  = r.cfop_id
      and c.cd             not in (5605);
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_vl_icms_c490_d390:' || sqlerrm);
end fkg_soma_vl_icms_c490_d390;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna a Soma do ICMS para os registro C690
function fkg_soma_vl_icms_c690
         return reg_anal_cons_nota_fiscal.vl_icms%type
is
   --
   vn_vl_icms reg_anal_cons_nota_fiscal.vl_icms%type := 0;
   --
begin
   --
   select sum(r.vl_icms) vl_icms
     into vn_vl_icms
     from cons_nota_fiscal           nf
        , reg_anal_cons_nota_fiscal  r
        , cfop                       c
    where nf.empresa_id          = gt_row_apuracao_icms.empresa_id
      and trunc(nf.dt_doc) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)
      and r.consnotafiscal_id    = nf.id
      and c.id                   = r.cfop_id
      and c.cd              not in (5605);
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_vl_icms_c690:' || sqlerrm);
end fkg_soma_vl_icms_c690;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna a Soma do ICMS para os registro C790
function fkg_soma_vl_icms_c790
         return reg_anal_cons_nf_via_unica.vl_icms%type
is
   --
   vn_vl_icms reg_anal_cons_nf_via_unica.vl_icms%type := 0;
   --
begin
   --
   select sum(r.vl_icms) vl_icms
     into vn_vl_icms
     from cons_nf_via_unica nf
        , reg_anal_cons_nf_via_unica r
        , cfop                       c
    where nf.empresa_id           = gt_row_apuracao_icms.empresa_id
      and ( trunc(nf.dt_doc_ini) >= trunc(gt_row_apuracao_icms.dt_inicio)
            and
            trunc(nf.dt_doc_fin) <= trunc(gt_row_apuracao_icms.dt_fim) )
      and r.consnfviaunica_id     = nf.id
      and c.id                    = r.cfop_id
      and c.cd               not in (5605);
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_vl_icms_c790:' || sqlerrm);
end fkg_soma_vl_icms_c790;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna a Soma do ICMS para o registro C800
function fkg_soma_vl_icms_c800
         return cupom_fiscal_total.vl_tot_icms%type
is
   --
   vn_vl_icms cupom_fiscal_total.vl_tot_icms%type := 0;
   --
begin
   --
   select nvl(sum(nvl(ct.vl_tot_icms,0)),0)
     into vn_vl_icms
     from cupom_fiscal       cf
        , mod_fiscal         mf
        , sit_docto          sd
        , cupom_fiscal_total ct
    where cf.empresa_id        = gt_row_apuracao_icms.empresa_id
      and trunc(cf.dt_emissao) between gt_row_apuracao_icms.dt_inicio and gt_row_apuracao_icms.dt_fim
      and cf.dm_st_proc        = 4 -- 4-Autorizado
      and mf.id                = cf.modfiscal_id
      and mf.cod_mod           = '59' -- Cupom Fiscal Eletr�nico
      and sd.id                = cf.sitdocto_id
      and sd.cd               in ('00', '01', '02', '03') -- 00-Documento regular, 01-Documento regular extempor�neo, 02-Documento cancelado, 03-Documento cancelado extempor�neo
      and ct.cupomfiscal_id    = cf.id;
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_vl_icms_c800:' || sqlerrm);
end fkg_soma_vl_icms_c800;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna a Soma do ICMS para os registro D190
function fkg_soma_vl_icms_d190
         return ct_reg_anal.vl_icms%type
is
   --
   vn_vl_icms   ct_reg_anal.vl_icms%type := 0;
   vn_vl_icms1  ct_reg_anal.vl_icms%type := 0;
   vn_vl_icms2  ct_reg_anal.vl_icms%type := 0;
   --
begin
   --
           select sum(nvl(r.vl_icms,0))
             into vn_vl_icms1
             from conhec_transp    ct
                , sit_docto        sd
                , ct_reg_anal      r
                , cfop             c
            where ct.empresa_id      = gt_row_apuracao_icms.empresa_id
              and ct.dm_st_proc      = 4 -- Autorizado
              and ct.dm_arm_cte_terc = 0
              and ct.dm_ind_oper     = 1 -- sa�da
              and ((ct.dm_ind_emit = 1 and trunc(nvl(ct.dt_sai_ent,ct.dt_hr_emissao)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
                    or
                   (ct.dm_ind_emit = 0 and ct.dm_ind_oper = 1 and trunc(ct.dt_hr_emissao) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
              and sd.id              = ct.sitdocto_id
              and sd.cd             in ('00', '06', '08')
              and r.conhectransp_id  = ct.id
              and c.id               = r.cfop_id
              and c.cd          not in (5605);

           select sum(nvl(r.vl_icms,0))
             into vn_vl_icms2
             from conhec_transp    ct
                , sit_docto        sd
                , ct_reg_anal      r
                , cfop             c
            where ct.empresa_id      = gt_row_apuracao_icms.empresa_id
              and ct.dm_st_proc      = 4 -- Autorizado
              and ct.dm_arm_cte_terc = 0
              and ct.dm_ind_oper     = 0 -- Entrada
              and ((ct.dm_ind_emit = 1 and trunc(nvl(ct.dt_sai_ent,ct.dt_hr_emissao)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
                    or
                   (ct.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(ct.dt_hr_emissao) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
                    or
                   (ct.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(ct.dt_sai_ent,ct.dt_hr_emissao)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
              and sd.id              = ct.sitdocto_id
              and sd.cd             in ('00', '06', '08')
              and r.conhectransp_id  = ct.id
              and c.id               = r.cfop_id
              and c.cd              in (1605);
   --
   vn_vl_icms := nvl(vn_vl_icms1,0) + nvl(vn_vl_icms2,0);
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_vl_icms_d190:' || sqlerrm);
end fkg_soma_vl_icms_d190;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna a Soma do ICMS para os registro D300
function fkg_soma_vl_icms_d300
         return reg_anal_bilhete.vl_icms%type
is
   --
   vn_vl_icms reg_anal_bilhete.vl_icms%type := 0;
   --
begin
   --
   select sum(nf.vl_icms) vl_icms
     into vn_vl_icms
     from reg_anal_bilhete nf
    where nf.empresa_id          = gt_row_apuracao_icms.empresa_id
      and trunc(nf.dt_doc) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim);
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_vl_icms_d300:' || sqlerrm);
end fkg_soma_vl_icms_d300;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna a Soma do ICMS para os registro D410
function fkg_soma_vl_icms_d410
         return res_mov_dia_doc_infor.vl_icms%type
is
   --
   vn_vl_icms res_mov_dia_doc_infor.vl_icms%type := 0;
   --
begin
   --
   select sum(r.vl_icms) vl_icms
     into vn_vl_icms
     from res_mov_dia            nf
        , res_mov_dia_doc_infor  r
        , cfop                   c
    where nf.empresa_id          = gt_row_apuracao_icms.empresa_id
      and trunc(nf.dt_doc) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)
      and r.resmovdia_id         = nf.id
      and c.id                   = r.cfop_id
      and c.cd              not in (5605);
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_vl_icms_d410:' || sqlerrm);
end fkg_soma_vl_icms_d410;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna a Soma do ICMS para os registro D690
function fkg_soma_vl_icms_d690
         return reg_an_cons_prest_serv.vl_icms%type
is
   --
   vn_vl_icms reg_an_cons_prest_serv.vl_icms%type := 0;
   --
begin
   --
   select sum(r.vl_icms) vl_icms
     into vn_vl_icms
     from cons_prest_serv         nf
        , reg_an_cons_prest_serv  r
        , cfop                    c
    where nf.empresa_id          = gt_row_apuracao_icms.empresa_id
      and trunc(nf.dt_doc) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)
      and r.consprestserv_id     = nf.id
      and c.id                   = r.cfop_id
      and c.cd              not in (5605);
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_vl_icms_d690:' || sqlerrm);
end fkg_soma_vl_icms_d690;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna a Soma do ICMS para os registro D696
function fkg_soma_vl_icms_d696
         return reg_an_cons_nf_prest_serv.vl_icms%type
is
   --
   vn_vl_icms reg_an_cons_nf_prest_serv.vl_icms%type := 0;
   --
begin
   --
   select sum(r.vl_icms) vl_icms
     into vn_vl_icms
     from cons_nf_prest_serv         nf
        , reg_an_cons_nf_prest_serv  r
        , cfop                       c
    where nf.empresa_id          = gt_row_apuracao_icms.empresa_id
      and ( trunc(nf.dt_doc_ini) >= trunc(gt_row_apuracao_icms.dt_inicio) and trunc(nf.dt_doc_ini) <= trunc(gt_row_apuracao_icms.dt_fim) )
      and r.consnfprestserv_id   = nf.id
      and c.id                   = r.cfop_id
      and c.cd              not in (5605);
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_vl_icms_d696:' || sqlerrm);
end fkg_soma_vl_icms_d696;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna o Vlr Total dos ajustes a d�bito decorrentes do documento fiscal
function fkg_soma_aj_debito
         return inf_prov_docto_fiscal.vl_icms%type
is
   --
   vn_vl_icms   inf_prov_docto_fiscal.vl_icms%type := 0;
   vn_vl_icms1  inf_prov_docto_fiscal.vl_icms%type := 0;
   vn_vl_icms2  inf_prov_docto_fiscal.vl_icms%type := 0;
   --
begin
   --
           select sum(nvl(ipdf.vl_icms,0)) vl_icms
             into vn_vl_icms1
             from nota_fiscal            nf
                , sit_docto              sd
                , mod_fiscal             mf
                , nfinfor_fiscal         nfi
                , inf_prov_docto_fiscal  ipdf
                , cod_ocor_aj_icms       cod
            where nf.empresa_id        = gt_row_apuracao_icms.empresa_id
              and nf.dm_st_proc        = 4
              and nf.dm_arm_nfe_terc   = 0 -- N�o � nota de armazenamento fiscal
              and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
                    or
                   (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
                    or
                   (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
                    or
                   (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
              and sd.id                = nf.sitdocto_id
              and sd.cd           not in ('01', '07') -- extempor�neos
              and mf.id                = nf.modfiscal_id
              and mf.cod_mod          in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
              and nfi.notafiscal_id    = nf.id
              and ipdf.nfinforfisc_id  = nfi.id
              and cod.id               = ipdf.codocorajicms_id
              and cod.dm_reflexo_apur in (3, 4, 5) -- reflexo na apura��o do icms: 3-D-D�bito por Sa�da, 4-D-Outros D�bitos, 5-D-Estorno de Cr�dito
              and cod.dm_tipo_apur    in (0, 3, 4, 5); -- tipo de apura��o: 0-Opera��o Pr�pria, 3-Apura��o 1, 4-Apura��o 2, 5-Apura��o 3

           select sum(nvl(ci.vl_icms,0)) vl_icms
             into vn_vl_icms2
             from conhec_transp    ct
                , sit_docto        sd
                , ct_reg_anal      cr
                , ctinfor_fiscal   cf
                , ct_inf_prov      ci
                , cod_ocor_aj_icms co
            where ct.empresa_id       = gt_row_apuracao_icms.empresa_id
              and ct.dm_st_proc       = 4 -- Autorizado
              and ct.dm_arm_cte_terc  = 0
              and ((ct.dm_ind_emit = 1 and trunc(nvl(ct.dt_sai_ent,ct.dt_hr_emissao)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
                    or
                   (ct.dm_ind_emit = 0 and ct.dm_ind_oper = 1 and trunc(ct.dt_hr_emissao) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
                    or
                   (ct.dm_ind_emit = 0 and ct.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(ct.dt_hr_emissao) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
                    or
                   (ct.dm_ind_emit = 0 and ct.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(ct.dt_sai_ent,ct.dt_hr_emissao)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
              and sd.id               = ct.sitdocto_id
              and sd.cd          not in ('01', '07') -- extempor�neos
              and cr.conhectransp_id  = ct.id
              and cf.conhectransp_id  = ct.id
              and ci.ctinforfiscal_id = cf.id
              and co.id               = ci.codocorajicms_id
              and co.dm_reflexo_apur in (3, 4, 5) -- reflexo na apura��o do icms: 3-D-D�bito por Sa�da, 4-D-Outros D�bitos, 5-D-Estorno de Cr�dito
              and co.dm_tipo_apur    in (0, 3, 4, 5); -- tipo de apura��o: 0-Opera��o Pr�pria, 3-Apura��o 1, 4-Apura��o 2, 5-Apura��o 3
   --
   vn_vl_icms := nvl(vn_vl_icms1,0) + nvl(vn_vl_icms2,0);
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_aj_debito:' || sqlerrm);
end fkg_soma_aj_debito;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna o Vlr Total dos Lan�amentos de Ajustes a d�bito
function fkg_soma_tot_aj_debitos
         return ajust_apuracao_icms.vl_aj_apur%type
is
   --
   vn_vl_aj_apur ajust_apuracao_icms.vl_aj_apur%type := 0;
   --
begin
   --
   select nvl(sum(aai.vl_aj_apur),0) vl_aj_apur
     into vn_vl_aj_apur
     from ajust_apuracao_icms aai
        , cod_aj_saldo_apur_icms  cod
    where aai.apuracaoicms_id = gt_row_apuracao_icms.id
      and cod.id              = aai.codajsaldoapuricms_id
      and cod.dm_apur        in (0) -- icms
      and cod.dm_util        in (0); -- utiliza��o: 0-Outros D�bitos
   --
   return vn_vl_aj_apur;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_tot_aj_debitos:' || sqlerrm);
end fkg_soma_tot_aj_debitos;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna a soma dos Lan�amentos de estornos de cr�dito
function fkg_soma_estornos_cred
         return ajust_apuracao_icms.vl_aj_apur%type
is
   --
   vn_vl_aj_apur ajust_apuracao_icms.vl_aj_apur%type := 0;
   --
begin
   --
   select nvl(sum(aai.vl_aj_apur),0) vl_aj_apur
     into vn_vl_aj_apur
     from ajust_apuracao_icms aai
        , cod_aj_saldo_apur_icms  cod
    where aai.apuracaoicms_id = gt_row_apuracao_icms.id
      and cod.id              = aai.codajsaldoapuricms_id
      and cod.dm_apur        in (0) -- icms
      and cod.dm_util        in (1); -- utiliza��o: 1-Estorno de cr�dito
   --
   return vn_vl_aj_apur;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_estornos_cred:' || sqlerrm);
end fkg_soma_estornos_cred;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna o Total de Cr�dito do ICMS para os registros C190, C590 e D590.
function fkg_tot_cred_c190_c590_d590 return nfregist_analit.vl_icms%type
is
   --
   vn_loggenerico_id  Log_Generico.id%TYPE;
   vn_vl_icms         nfregist_analit.vl_icms%type  := 0;
   vn_vl_fcp          nota_fiscal_total.vl_fcp%type := 0;
   --
   cursor c_inf is
   select nf.nro_nf
        , nf.serie
        , sum(r.vl_icms) vl_icms
        , sum(r.vl_fcp_icms) vl_fcp_icms 
     from nota_fiscal      nf
        , sit_docto        sd
        , mod_fiscal       mf
        , nfregist_analit  r
        , cfop             c
    where nf.empresa_id      = gt_row_apuracao_icms.empresa_id
      and nf.dm_st_proc      = 4 -- Autorizada
      and nf.dm_arm_nfe_terc = 0 -- N�o � nota de armazenamento fiscal
      and nf.dm_ind_oper     = 0 -- Entrada
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (nf.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (nf.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
      and sd.id              = nf.sitdocto_id
      and sd.cd             in ('00', '06', '08')
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and r.notafiscal_id    = nf.id
      and c.id               = r.cfop_id
      and c.cd               not in (3551, 3556)
      and not exists ( select 1   -- Retorna se o documento � de Antecipa��o de credito de ICMS
                         from nota_fiscal           nfi
                            , nota_fiscal_total     nt
                            , mod_fiscal            mf
                            , sit_docto             sd
                            , item_nota_fiscal      it
                            , cfop                  cf
                            , imp_itemnf            ii
                            , tipo_imposto          ti
                            , nfinfor_fiscal        ni
                            , inf_prov_docto_fiscal ip
                        where nfi.id                   = nf.id
                          and mf.id                    = nfi.modfiscal_id
                          and mf.cod_mod               = '55'
                          and sd.id                    = nfi.sitdocto_id
                          and sd.cd                    = '08' -- Documento Fiscal emitido com base em Regime Especial ou Norma Espec�fica
                          and nt.notafiscal_id         = nfi.id
                          and nvl(nt.vl_total_nf,0)    = 0
                          and it.notafiscal_id         = nfi.id
                          and nvl(it.vl_item_bruto,0)  = 0
                          and cf.id                    = it.cfop_id
                          and cf.cd                   in (1949, 2949, 3949)
                          and ii.itemnf_id             = it.id
                          and ii.dm_tipo               = 0 -- 0-Imposto / 1-reten��o
                          and nvl(ii.vl_base_calc,0)   > 0 -- Valor da base de credito de ICMS maior que zero
                          and nvl(ii.vl_imp_trib,0)    > 0 -- Valor de tributa��o de ICMS maior que zero
                          and ti.id                    = ii.tipoimp_id
                          and ti.cd                    = 1 -- ICMS
                          and ni.notafiscal_id         = nf.id
                          and ip.nfinforfisc_id        = ni.id )
      having sum(nvl(r.vl_icms,0)) = 0 and sum(nvl(r.vl_fcp_icms,0)) > 0
      group by nf.nro_nf, nf.serie;
   --
begin
   --
   select sum(r.vl_icms) vl_icms
     into vn_vl_icms
     from nota_fiscal      nf
        , sit_docto        sd
        , mod_fiscal       mf
        , nfregist_analit  r
        , cfop             c
    where nf.empresa_id      = gt_row_apuracao_icms.empresa_id
      and nf.dm_st_proc      = 4 -- Autorizada
      and nf.dm_arm_nfe_terc = 0 -- N�o � nota de armazenamento fiscal
      and nf.dm_ind_oper     = 0 -- Entrada
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (nf.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (nf.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
      and sd.id              = nf.sitdocto_id
      and sd.cd             in ('00', '06', '08')
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and r.notafiscal_id    = nf.id
      and c.id               = r.cfop_id
      and c.cd               not in (3551, 3556)
      and not exists ( select 1   -- Retorna se o documento � de Antecipa��o de credito de ICMS
                         from nota_fiscal           nfi
                            , nota_fiscal_total     nt
                            , mod_fiscal            mf
                            , sit_docto             sd  
                            , item_nota_fiscal      it
                            , cfop                  cf			  
                            , imp_itemnf            ii
                            , tipo_imposto          ti
                            , nfinfor_fiscal        ni
                            , inf_prov_docto_fiscal ip							
                        where nfi.id                   = nf.id 
                          and mf.id                    = nfi.modfiscal_id
                          and mf.cod_mod               = '55' 
                          and sd.id                    = nfi.sitdocto_id
                          and sd.cd                    = '08' -- Documento Fiscal emitido com base em Regime Especial ou Norma Espec�fica
                          and nt.notafiscal_id         = nfi.id
                          and nvl(nt.vl_total_nf,0)    = 0   
                          and it.notafiscal_id         = nfi.id
                          and nvl(it.vl_item_bruto,0)  = 0   
                          and cf.id                    = it.cfop_id
                          and cf.cd                   in (1949, 2949, 3949)  			
                          and ii.itemnf_id             = it.id
                          and ii.dm_tipo               = 0 -- 0-Imposto / 1-reten��o			
                          and nvl(ii.vl_base_calc,0)   > 0 -- Valor da base de credito de ICMS maior que zero
                          and nvl(ii.vl_imp_trib,0)    > 0 -- Valor de tributa��o de ICMS maior que zero
                          and ti.id                    = ii.tipoimp_id   
                          and ti.cd                    = 1 -- ICMS	
                          and ni.notafiscal_id         = nf.id
                          and ip.nfinforfisc_id        = ni.id							  
                     );
   --
   if gt_row_apuracao_icms.dt_inicio >= to_date('01/08/2018','dd/mm/rrrr') then
      -- Recuperar os valores de FCP do Total da Nota Fiscal
      select sum(nvl(nt.vl_fcp,0))
        into vn_vl_fcp
        from nota_fiscal       nf
           , sit_docto         sd
           , mod_fiscal        mf
           , nota_fiscal_total nt
       where nf.empresa_id      = gt_row_apuracao_icms.empresa_id
         and nf.dm_st_proc      = 4 -- Autorizada
         and nf.dm_arm_nfe_terc = 0 -- N�o � nota de armazenamento fiscal
         and nf.dm_ind_oper     = 0 -- Entrada
         and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
               or
              (nf.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
               or
              (nf.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
         and sd.id              = nf.sitdocto_id
         and sd.cd              in ('00', '06', '08')
         and mf.id              = nf.modfiscal_id
         and mf.cod_mod         in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
         and nt.notafiscal_id   = nf.id;
      --
   else
      --
      vn_vl_fcp := 0;
      --
   end if;
   --
   -- Verifica se existe nota fiscal com valor de FCP sem valor de ICMS para gerar log de informacao
   for rec in c_inf loop
      exit when c_inf%notfound or (c_inf%notfound);
      --
      gv_resumo_log := 'A Nota Fiscal N�mero '||rec.nro_nf|| ' e S�rie '||rec.serie ||' n�o possui valor de ICMS e foi gerado '||
                       'valor de '|| rec.vl_fcp_icms ||' para FCP. Verifique!';
      --
      pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                       , ev_mensagem        => gv_mensagem_log
                                       , ev_resumo          => gv_resumo_log
                                       , en_tipo_log        => INFO_APUR_IMPOSTO
                                       , en_referencia_id   => gn_referencia_id
                                       , ev_obj_referencia  => gv_obj_referencia );
      --
   end loop;
   --
   return (nvl(vn_vl_icms,0) + nvl(vn_vl_fcp,0));
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_tot_cred_c190_c590_d590:' || sqlerrm);
end fkg_tot_cred_c190_c590_d590;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna o Total de Cr�dito do ICMS para os registros C190, C590 e D590 de CFOP 5605
function fkg_totcredc190_c590_d590_5605
         return nfregist_analit.vl_icms%type
is
   --
   vn_vl_icms nfregist_analit.vl_icms%type := 0;
   vn_vl_fcp  imp_itemnf.vl_fcp%type := 0;
   --
begin
   --
   select sum(r.vl_icms) vl_icms
     into vn_vl_icms
     from nota_fiscal      nf
        , sit_docto        sd
        , nfregist_analit  r
        , cfop             c
    where nf.empresa_id      = gt_row_apuracao_icms.empresa_id
      and nf.dm_st_proc      = 4
      and nf.dm_arm_nfe_terc = 0 -- N�o � nota de armazenamento fiscal
      and nf.dm_ind_oper     = 0 -- Entrada
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (nf.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (nf.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
      and sd.id              = nf.sitdocto_id
      and sd.cd             in ('00', '06', '08')
      and r.notafiscal_id    = nf.id
      and c.id               = r.cfop_id
      and c.cd              in (5605);
   --
   if gt_row_apuracao_icms.dt_inicio >= to_date('01/08/2018','dd/mm/rrrr') then
      -- Recuperar os valores de FCP do Imposto ICMS do Item da Nota Fiscal
      select sum(nvl(ii.vl_fcp,0))
        into vn_vl_fcp
        from nota_fiscal      nf
           , sit_docto        sd
           , item_nota_fiscal it
           , imp_itemnf       ii
           , tipo_imposto     ti
       where nf.empresa_id      = gt_row_apuracao_icms.empresa_id
         and nf.dm_st_proc      = 4
         and nf.dm_arm_nfe_terc = 0 -- N�o � nota de armazenamento fiscal
         and nf.dm_ind_oper     = 0 -- Entrada
         and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
               or
              (nf.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
               or
              (nf.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
         and sd.id              = nf.sitdocto_id
         and sd.cd             in ('00', '06', '08')
         and it.notafiscal_id   = nf.id
         and it.cfop           in (5605)
         and ii.itemnf_id       = it.id
         and ii.dm_tipo         = 0 -- imposto
         and ti.id              = ii.tipoimp_id
         and ti.cd              = 1; -- ICMS
   else
      --
      vn_vl_fcp := 0;
      --
   end if;
   --
   return (vn_vl_icms + vn_vl_fcp);
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_totcredc190_c590_d590_5605:' || sqlerrm);
end fkg_totcredc190_c590_d590_5605;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna o Total de Cr�dito do ICMS para os registros D190
function fkg_tot_cred_d190
         return ct_reg_anal.vl_icms%type
is
   --
   vn_vl_icms ct_reg_anal.vl_icms%type := 0;
   --
begin
   --
   select sum(r.vl_icms) vl_icms
     into vn_vl_icms
     from conhec_transp    ct
        , sit_docto        sd
        , ct_reg_anal      r
        , cfop             c
    where ct.empresa_id      = gt_row_apuracao_icms.empresa_id
      and ct.dm_st_proc      = 4 -- Autorizado
      and ct.dm_arm_cte_terc = 0
      and ct.dm_ind_oper     = 0 -- Entrada
      and ((ct.dm_ind_emit = 1 and trunc(nvl(ct.dt_sai_ent,ct.dt_hr_emissao)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (ct.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(ct.dt_hr_emissao) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (ct.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(ct.dt_sai_ent,ct.dt_hr_emissao)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
      and sd.id              = ct.sitdocto_id
      and sd.cd              in ('00', '06', '08')
      and r.conhectransp_id  = ct.id
      and c.id               = r.cfop_id
      and c.cd               not in (1605, 3551, 3556);
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_tot_cred_d190:' || sqlerrm);
end fkg_tot_cred_d190;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna o Total de Cr�dito do ICMS para os registros D190 de CFOP 5605
function fkg_tot_cred_d190_5605
         return ct_reg_anal.vl_icms%type
is
   --
   vn_vl_icms ct_reg_anal.vl_icms%type := 0;
   --
begin
   --
   select sum(r.vl_icms) vl_icms
     into vn_vl_icms
     from conhec_transp    ct
        , sit_docto        sd
        , ct_reg_anal      r
        , cfop             c
    where ct.empresa_id      = gt_row_apuracao_icms.empresa_id
      and ct.dm_st_proc      = 4 -- Autorizado
      and ct.dm_arm_cte_terc = 0
      and ct.dm_ind_oper     = 0 -- Entrada
      and ((ct.dm_ind_emit = 1 and trunc(nvl(ct.dt_sai_ent,ct.dt_hr_emissao)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (ct.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(ct.dt_hr_emissao) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (ct.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(ct.dt_sai_ent,ct.dt_hr_emissao)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
      and sd.id              = ct.sitdocto_id
      and sd.cd             in ('00', '06', '08')
      and r.conhectransp_id  = ct.id
      and c.id               = r.cfop_id
      and c.cd              in (5605);
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_tot_cred_d190_5605:' || sqlerrm);
end fkg_tot_cred_d190_5605;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna o Vlr. Total dos Ajustes de cr�ditos decorrentes do documento fiscal
function fkg_soma_aj_credito
         return inf_prov_docto_fiscal.vl_icms%type
is
   --
   vn_vl_icms   inf_prov_docto_fiscal.vl_icms%type := 0;
   vn_vl_icms1  inf_prov_docto_fiscal.vl_icms%type := 0;
   vn_vl_icms2  inf_prov_docto_fiscal.vl_icms%type := 0;
   --
begin
   --
           select sum(nvl(ipdf.vl_icms,0)) vl_icms
             into vn_vl_icms1
             from nota_fiscal            nf
                , sit_docto              sd
                , mod_fiscal             mf
                , nfinfor_fiscal         nfi
                , inf_prov_docto_fiscal  ipdf
                , cod_ocor_aj_icms       cod
            where nf.empresa_id        = gt_row_apuracao_icms.empresa_id
              and nf.dm_st_proc        = 4
              and nf.dm_arm_nfe_terc   = 0 -- N�o � nota de armazenamento fiscal
              and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
                    or
                   (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
                    or
                   (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
                    or
                   (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
              and sd.id                = nf.sitdocto_id
              and sd.cd           not in ('01', '07') -- extempor�neos
              and mf.id                = nf.modfiscal_id
              and mf.cod_mod          in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
              and nfi.notafiscal_id    = nf.id
              and ipdf.nfinforfisc_id  = nfi.id
              and cod.id               = ipdf.codocorajicms_id
              and cod.dm_reflexo_apur in (0, 1, 2) -- reflexo na apura��o do icms: 0-C-Cr�dito por Entrada, 1-C-Outros Cr�ditos, 2-C-Estorno de D�bito
              and cod.dm_tipo_apur    in (0, 3, 4, 5); -- tipo de apura��o: 0-Opera��o Pr�pria, 3-Apura��o 1, 4-Apura��o 2, 5-Apura��o 3

           select sum(nvl(ci.vl_icms,0)) vl_icms
             into vn_vl_icms2
             from conhec_transp    ct
                , sit_docto        sd
                , ct_reg_anal      cr
                , ctinfor_fiscal   cf
                , ct_inf_prov      ci
                , cod_ocor_aj_icms co
            where ct.empresa_id       = gt_row_apuracao_icms.empresa_id
              and ct.dm_st_proc       = 4 -- Autorizado
              and ct.dm_arm_cte_terc  = 0
              and ((ct.dm_ind_emit = 1 and trunc(nvl(ct.dt_sai_ent,ct.dt_hr_emissao)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
                    or
                   (ct.dm_ind_emit = 0 and ct.dm_ind_oper = 1 and trunc(ct.dt_hr_emissao) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
                    or
                   (ct.dm_ind_emit = 0 and ct.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(ct.dt_hr_emissao) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
                    or
                   (ct.dm_ind_emit = 0 and ct.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(ct.dt_sai_ent,ct.dt_hr_emissao)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
              and sd.id               = ct.sitdocto_id
              and sd.cd          not in ('01', '07') -- extempor�neos
              and cr.conhectransp_id  = ct.id
              and cf.conhectransp_id  = ct.id
              and ci.ctinforfiscal_id = cf.id
              and co.id               = ci.codocorajicms_id
              and co.dm_reflexo_apur in (0, 1, 2) -- reflexo na apura��o do icms: 0-C-Cr�dito por Entrada, 1-C-Outros Cr�ditos, 2-C-Estorno de D�bito
              and co.dm_tipo_apur    in (0, 3, 4, 5); -- tipo de apura��o: 0-Opera��o Pr�pria, 3-Apura��o 1, 4-Apura��o 2, 5-Apura��o 3
   --
   vn_vl_icms := nvl(vn_vl_icms1,0) + nvl(vn_vl_icms2,0);
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_aj_credito:' || sqlerrm);
end fkg_soma_aj_credito;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna a soma dos Lan�amentos de Ajustes a Cr�dito
function fkg_soma_tot_aj_credito
         return ajust_apuracao_icms.vl_aj_apur%type
is
   --
   vn_vl_aj_apur ajust_apuracao_icms.vl_aj_apur%type := 0;
   --
begin
   --
   select nvl(sum(aai.vl_aj_apur),0) vl_aj_apur
     into vn_vl_aj_apur
     from ajust_apuracao_icms aai
        , cod_aj_saldo_apur_icms  cod
    where aai.apuracaoicms_id = gt_row_apuracao_icms.id
      and cod.id              = aai.codajsaldoapuricms_id
      and cod.dm_apur        in (0) -- icms
      and cod.dm_util        in (2); -- utiliza��o: 2-Outros Cr�ditos
   --
   return vn_vl_aj_apur;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_tot_aj_credito:' || sqlerrm);
end fkg_soma_tot_aj_credito;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna a soma dos Lan�amentos de Estorno de D�bitos
function fkg_soma_estorno_deb
         return ajust_apuracao_icms.vl_aj_apur%type
is
   --
   vn_vl_aj_apur ajust_apuracao_icms.vl_aj_apur%type := 0;
   --
begin
   --
   select nvl(sum(aai.vl_aj_apur),0) vl_aj_apur
     into vn_vl_aj_apur
     from ajust_apuracao_icms aai
        , cod_aj_saldo_apur_icms  cod
    where aai.apuracaoicms_id = gt_row_apuracao_icms.id
      and cod.id              = aai.codajsaldoapuricms_id
      and cod.dm_apur        in (0) -- icms
      and cod.dm_util        in (3); -- utiliza��o: 3-Estorno de d�bito
   --
   return vn_vl_aj_apur;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_estorno_deb:' || sqlerrm);
end fkg_soma_estorno_deb;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna a Total de Dedu��o do Registro C197
function fkg_soma_tot_ded_c197
         return inf_prov_docto_fiscal.vl_icms%type
is
   --
   vn_vl_icms inf_prov_docto_fiscal.vl_icms%type := 0;
   --
begin
   --
   select nvl(sum(ipdf.vl_icms),0) vl_icms
     into vn_vl_icms
     from nota_fiscal            nf
        , sit_docto              sd
        , mod_fiscal             mf
        , nfinfor_fiscal         nfi
        , inf_prov_docto_fiscal  ipdf
        , cod_ocor_aj_icms       cod
    where nf.empresa_id        = gt_row_apuracao_icms.empresa_id
      and nf.dm_st_proc        = 4
      and nf.dm_arm_nfe_terc   = 0 -- N�o � nota de armazenamento fiscal
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
      and sd.id                = nf.sitdocto_id
      and sd.cd           not in ('01', '07') -- extempor�neos
      and mf.id                = nf.modfiscal_id
      and mf.cod_mod          in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and nfi.notafiscal_id    = nf.id
      and ipdf.nfinforfisc_id  = nfi.id
      and cod.id               = ipdf.codocorajicms_id
      and cod.dm_reflexo_apur in (6) -- reflexo na apura��o do icms := 6-Dedu��o
      and cod.dm_tipo_apur    in (0); -- tipo de apura��o: 0-Opera��es Pr�prias
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_tot_ded_c197:' || sqlerrm);
end fkg_soma_tot_ded_c197;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna a Total de Dedu��o do Registro E111
function fkg_soma_tot_ded_e111
         return ajust_apuracao_icms.vl_aj_apur%type
is
   --
   vn_vl_aj_apur ajust_apuracao_icms.vl_aj_apur%type := 0;
   --
begin
   --
   select nvl(sum(aai.vl_aj_apur),0) vl_aj_apur
     into vn_vl_aj_apur
     from ajust_apuracao_icms aai
        , cod_aj_saldo_apur_icms  cod
    where aai.apuracaoicms_id = gt_row_apuracao_icms.id
      and cod.id              = aai.codajsaldoapuricms_id
      and cod.dm_apur        in (0) -- icms
      and cod.dm_util        in (4); -- utiliza��o: 4-Dedu��es
   --
   return vn_vl_aj_apur;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_tot_ded_e111:' || sqlerrm);
end fkg_soma_tot_ded_e111;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna de Valor de ICMS extempor�neo nos documentos fiscais
-- Onde as nfe de sa�da n�o est� entre o cfop 5605 e as nf de entrada est�o no cfop 1605
function fkg_soma_cred_ext_op_c
         return nfregist_analit.vl_icms%type
is
   --
   vn_vl_icms   nfregist_analit.vl_icms%type := 0;
   vn_vl_icms1  nfregist_analit.vl_icms%type := 0;
   vn_vl_icms2  nfregist_analit.vl_icms%type := 0;
   vn_vl_fcp_1  imp_itemnf.vl_fcp%type := 0;
   vn_vl_fcp_2  imp_itemnf.vl_fcp%type := 0;
   --
begin
   --
   select sum(nvl(r.vl_icms,0))
     into vn_vl_icms1
     from nota_fiscal      nf
        , sit_docto        sd
        , mod_fiscal       mf
        , nfregist_analit  r
        , cfop             c
    where nf.empresa_id      = gt_row_apuracao_icms.empresa_id
      and nf.dm_st_proc      = 4
      and nf.dm_arm_nfe_terc = 0 -- N�o � nota de armazenamento fiscal
      and nf.dm_ind_oper     = 1 -- Sa�da
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (nf.dm_ind_emit = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
      and sd.id              = nf.sitdocto_id
      and sd.cd             in ('01', '07') -- extempor�neo
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and r.notafiscal_id    = nf.id
      and c.id               = r.cfop_id
      and c.cd          not in (5602, 5605, 5929, 6602, 6929);

   select sum(nvl(r.vl_icms,0)) vl_icms
     into vn_vl_icms2
     from nota_fiscal      nf
        , sit_docto        sd
        , mod_fiscal       mf
        , nfregist_analit  r
        , cfop             c
    where nf.empresa_id      = gt_row_apuracao_icms.empresa_id
      and nf.dm_st_proc      = 4
      and nf.dm_arm_nfe_terc = 0 -- N�o � nota de armazenamento fiscal
      and nf.dm_ind_oper     = 0 -- Entrada
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (nf.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (nf.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
      and sd.id              = nf.sitdocto_id
      and sd.cd             in ('01', '07') -- extempor�neo
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and r.notafiscal_id    = nf.id
      and c.id               = r.cfop_id
      and c.cd              in (1605);
   --
   if gt_row_apuracao_icms.dt_inicio >= to_date('01/08/2018','dd/mm/rrrr') then
      -- Recuperar os valores de FCP do Imposto ICMS do Item da Nota Fiscal
      select sum(nvl(ii.vl_fcp,0))
        into vn_vl_fcp_1
        from nota_fiscal      nf
           , sit_docto        sd
           , mod_fiscal       mf
           , item_nota_fiscal it
           , imp_itemnf       ii
           , tipo_imposto     ti
       where nf.empresa_id      = gt_row_apuracao_icms.empresa_id
         and nf.dm_st_proc      = 4
         and nf.dm_arm_nfe_terc = 0 -- N�o � nota de armazenamento fiscal
         and nf.dm_ind_oper     = 1 -- Sa�da
         and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
               or
              (nf.dm_ind_emit = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
         and sd.id              = nf.sitdocto_id
         and sd.cd             in ('01', '07') -- extempor�neo
         and mf.id              = nf.modfiscal_id
         and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
         and it.notafiscal_id   = nf.id
         and it.cfop        not in (5602, 5605, 5929, 6602, 6929)
         and ii.itemnf_id       = it.id
         and ii.dm_tipo         = 0 -- imposto
         and ti.id              = ii.tipoimp_id
         and ti.cd              = 1; -- ICMS
      --
      select sum(nvl(ii.vl_fcp,0))
        into vn_vl_fcp_2
        from nota_fiscal      nf
           , sit_docto        sd
           , mod_fiscal       mf
           , item_nota_fiscal it
           , imp_itemnf       ii
           , tipo_imposto     ti
       where nf.empresa_id      = gt_row_apuracao_icms.empresa_id
         and nf.dm_st_proc      = 4
         and nf.dm_arm_nfe_terc = 0 -- N�o � nota de armazenamento fiscal
         and nf.dm_ind_oper     = 0 -- Entrada
         and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
               or
              (nf.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
               or
              (nf.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
         and sd.id              = nf.sitdocto_id
         and sd.cd             in ('01', '07') -- extempor�neo
         and mf.id              = nf.modfiscal_id
         and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
         and it.notafiscal_id   = nf.id
         and it.cfop           in (1605)
         and ii.itemnf_id       = it.id
         and ii.dm_tipo         = 0 -- imposto
         and ti.id              = ii.tipoimp_id
         and ti.cd              = 1; -- ICMS
      --
   else
      --
      vn_vl_fcp_1 := 0;
      vn_vl_fcp_2 := 0;
      --
   end if;
   --
   vn_vl_icms := nvl(vn_vl_icms1,0) + nvl(vn_vl_icms2,0) + nvl(vn_vl_fcp_1,0) + nvl(vn_vl_fcp_2,0);
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_cred_ext_op_c:' || sqlerrm);
end fkg_soma_cred_ext_op_c;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna de Valor de ICMS extempor�neo nos conhecimentos de transporte
-- onde as opera��es de sa�da n�o est�o no cfop 5605 e as de entrada est�o no cfop 1605
function fkg_soma_cred_ext_op_d
         return ct_reg_anal.vl_icms%type
is
   --
   vn_vl_icms ct_reg_anal.vl_icms%type := 0;
   vn_vl_icms1 ct_reg_anal.vl_icms%type := 0;
   vn_vl_icms2 ct_reg_anal.vl_icms%type := 0;
   --
begin
   --
   select sum(nvl(r.vl_icms,0))
     into vn_vl_icms1
     from conhec_transp    ct
        , sit_docto        sd
        , ct_reg_anal      r
        , cfop             c
    where ct.empresa_id      = gt_row_apuracao_icms.empresa_id
      and ct.dm_st_proc      = 4 -- Autorizado
      and ct.dm_arm_cte_terc = 0
      and ct.dm_ind_oper     = 1 -- sa�da
      and ((ct.dm_ind_emit = 1 and trunc(nvl(ct.dt_sai_ent,ct.dt_hr_emissao)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (ct.dm_ind_emit = 0 and trunc(ct.dt_hr_emissao) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
      and sd.id              = ct.sitdocto_id
      and sd.cd             in ('01', '07') -- extempor�neo
      and r.conhectransp_id  = ct.id
      and c.id               = r.cfop_id
      and c.cd          not in (5602, 5605, 5929, 6602, 6929);

   select sum(nvl(r.vl_icms,0)) vl_icms
     into vn_vl_icms2
     from conhec_transp    ct
        , sit_docto        sd
        , ct_reg_anal      r
        , cfop             c
    where ct.empresa_id      = gt_row_apuracao_icms.empresa_id
      and ct.dm_st_proc      = 4 -- Autorizado
      and ct.dm_arm_cte_terc = 0
      and ct.dm_ind_oper     = 0 -- Entrada
      and ((ct.dm_ind_emit = 1 and trunc(nvl(ct.dt_sai_ent,ct.dt_hr_emissao)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (ct.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(ct.dt_hr_emissao) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (ct.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(ct.dt_sai_ent,ct.dt_hr_emissao)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
      and sd.id              = ct.sitdocto_id
      and sd.cd             in ('01', '07') -- extempor�neo
      and r.conhectransp_id  = ct.id
      and c.id               = r.cfop_id
      and c.cd              in (1605);
   --
   vn_vl_icms := nvl(vn_vl_icms1,0) + nvl(vn_vl_icms2,0);
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_cred_ext_op_d:' || sqlerrm);
end fkg_soma_cred_ext_op_d;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna de Valor de ICMS extempor�neo
-- Onde as nfe de entrada est�o no cfop 5605 e as nf de entrada n�o est�o no cfop 1605
function fkg_tot_deb_ext_ent_c
         return nfregist_analit.vl_icms%type
is
   --
   vn_vl_icms   nfregist_analit.vl_icms%type := 0;
   vn_vl_icms1  nfregist_analit.vl_icms%type := 0;
   vn_vl_icms2  nfregist_analit.vl_icms%type := 0;
   vn_vl_fcp_1  imp_itemnf.vl_fcp%type := 0;
   vn_vl_fcp_2  imp_itemnf.vl_fcp%type := 0;
   --
begin
   --
   select sum(nvl(r.vl_icms,0)) vl_icms
     into vn_vl_icms1
     from nota_fiscal      nf
        , sit_docto        sd
        , mod_fiscal       mf
        , nfregist_analit  r
        , cfop             c
    where nf.empresa_id      = gt_row_apuracao_icms.empresa_id
      and nf.dm_st_proc      = 4
      and nf.dm_arm_nfe_terc = 0 -- N�o � nota de armazenamento fiscal
      and nf.dm_ind_oper     = 1 -- Sa�da
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (nf.dm_ind_emit = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
      and sd.id              = nf.sitdocto_id
      and sd.cd             in ('01', '07') -- extempor�neo
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and r.notafiscal_id    = nf.id
      and c.id               = r.cfop_id
      and c.cd          not in (1605, 5602, 5605, 5929, 6602, 6929);

   select sum(nvl(r.vl_icms,0)) vl_icms
     into vn_vl_icms2
     from nota_fiscal      nf
        , sit_docto        sd
        , nfregist_analit  r
        , cfop             c
    where nf.empresa_id      = gt_row_apuracao_icms.empresa_id
      and nf.dm_st_proc      = 4
      and nf.dm_arm_nfe_terc = 0 -- N�o � nota de armazenamento fiscal
      and nf.dm_ind_oper     = 1 -- Sa�da
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (nf.dm_ind_emit = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
      and sd.id              = nf.sitdocto_id
      and sd.cd             in ('01', '07') -- extempor�neo
      and r.notafiscal_id    = nf.id
      and c.id               = r.cfop_id
      and c.cd              in (5605);
   --
   if gt_row_apuracao_icms.dt_inicio >= to_date('01/08/2018','dd/mm/rrrr') then
      -- Recuperar os valores de FCP do Imposto ICMS do Item da Nota Fiscal
      select sum(nvl(ii.vl_fcp,0))
        into vn_vl_fcp_1
        from nota_fiscal      nf
           , sit_docto        sd
           , mod_fiscal       mf
           , item_nota_fiscal it
           , imp_itemnf       ii
           , tipo_imposto     ti
       where nf.empresa_id      = gt_row_apuracao_icms.empresa_id
         and nf.dm_st_proc      = 4
         and nf.dm_arm_nfe_terc = 0 -- N�o � nota de armazenamento fiscal
         and nf.dm_ind_oper     = 1 -- Sa�da
         and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
               or
              (nf.dm_ind_emit = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
         and sd.id              = nf.sitdocto_id
         and sd.cd             in ('01', '07') -- extempor�neo
         and mf.id              = nf.modfiscal_id
         and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
         and it.notafiscal_id   = nf.id
         and it.cfop          not in (1605, 5602, 5605, 5929, 6602, 6929)
         and ii.itemnf_id       = it.id
         and ii.dm_tipo         = 0 -- imposto
         and ti.id              = ii.tipoimp_id
         and ti.cd              = 1; -- ICMS
      --
      select sum(nvl(ii.vl_fcp,0))
        into vn_vl_fcp_2
        from nota_fiscal      nf
           , sit_docto        sd
           , item_nota_fiscal it
           , imp_itemnf       ii
           , tipo_imposto     ti
       where nf.empresa_id      = gt_row_apuracao_icms.empresa_id
         and nf.dm_st_proc      = 4
         and nf.dm_arm_nfe_terc = 0 -- N�o � nota de armazenamento fiscal
         and nf.dm_ind_oper     = 1 -- Sa�da
         and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
               or
              (nf.dm_ind_emit = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
         and sd.id              = nf.sitdocto_id
         and sd.cd             in ('01', '07') -- extempor�neo
         and it.notafiscal_id   = nf.id
         and it.cfop           in (5605)
         and ii.itemnf_id       = it.id
         and ii.dm_tipo         = 0 -- imposto
         and ti.id              = ii.tipoimp_id
         and ti.cd              = 1; -- ICMS
   else
      --
      vn_vl_fcp_1 := 0;
      vn_vl_fcp_2 := 0;
      --
   end if;
   --
   vn_vl_icms := nvl(vn_vl_icms1,0) + nvl(vn_vl_icms2,0) + nvl(vn_vl_fcp_1,0) + nvl(vn_vl_fcp_2,0);
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_tot_deb_ext_ent_c:' || sqlerrm);
end fkg_tot_deb_ext_ent_c;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna de Valor de ICMS extempor�neo  dos conhecimentos de transporte onde
-- a entrada n�o est� no cfop 1605 e est� no cfop 5605
function fkg_tot_deb_ext_ent_d
         return ct_reg_anal.vl_icms%type
is
   --
   vn_vl_icms   ct_reg_anal.vl_icms%type := 0;
   vn_vl_icms1  ct_reg_anal.vl_icms%type := 0;
   vn_vl_icms2  ct_reg_anal.vl_icms%type := 0;
   --
begin
   --
   select sum(nvl(r.vl_icms,0)) vl_icms
     into vn_vl_icms1
     from conhec_transp    ct
        , sit_docto        sd
        , ct_reg_anal      r
        , cfop             c
    where ct.empresa_id      = gt_row_apuracao_icms.empresa_id
      and ct.dm_st_proc      = 4 -- Autorizado
      and ct.dm_arm_cte_terc = 0
      and ct.dm_ind_oper     = 0 -- Entrada
      and ((ct.dm_ind_emit = 1 and trunc(nvl(ct.dt_sai_ent,ct.dt_hr_emissao)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (ct.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(ct.dt_hr_emissao) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (ct.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(ct.dt_sai_ent,ct.dt_hr_emissao)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
      and sd.id              = ct.sitdocto_id
      and sd.cd             in ('01', '07') -- extempor�neo
      and r.conhectransp_id  = ct.id
      and c.id               = r.cfop_id
      and c.cd          not in (1605,5605);

   select sum(nvl(r.vl_icms,0)) vl_icms
     into vn_vl_icms2
     from conhec_transp    ct
        , sit_docto        sd
        , ct_reg_anal      r
        , cfop             c
    where ct.empresa_id      = gt_row_apuracao_icms.empresa_id
      and ct.dm_st_proc      = 4 -- Autorizado
      and ct.dm_arm_cte_terc = 0
      and ct.dm_ind_oper     = 0 -- Entrada
      and ((ct.dm_ind_emit = 1 and trunc(nvl(ct.dt_sai_ent,ct.dt_hr_emissao)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (ct.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(ct.dt_hr_emissao) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (ct.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(ct.dt_sai_ent,ct.dt_hr_emissao)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
      and sd.id              = ct.sitdocto_id
      and sd.cd             in ('01', '07') -- extempor�neo
      and r.conhectransp_id  = ct.id
      and c.id               = r.cfop_id
      and c.cd              in (5605);
   --
   vn_vl_icms := nvl(vn_vl_icms1,0) + nvl(vn_vl_icms2,0);
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_tot_deb_ext_ent_d:' || sqlerrm);
end fkg_tot_deb_ext_ent_d;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna de Valor de ICMS extempor�neo no c197 e D197
function fkg_soma_dep_esp_c197_d197
         return inf_prov_docto_fiscal.vl_icms%type
is
   --
   vn_vl_icms1 inf_prov_docto_fiscal.vl_icms%type := 0;
   vn_vl_icms2 inf_prov_docto_fiscal.vl_icms%type := 0;
   --
begin
   --
   select nvl(sum(ipdf.vl_icms),0)
     into vn_vl_icms1
     from nota_fiscal            nf
        , sit_docto              sd
        , mod_fiscal             mf
        , nfinfor_fiscal         nfi
        , inf_prov_docto_fiscal  ipdf
        , cod_ocor_aj_icms       cod
    where nf.empresa_id        = gt_row_apuracao_icms.empresa_id
      and nf.dm_st_proc        = 4
      and nf.dm_arm_nfe_terc   = 0 -- N�o � nota de armazenamento fiscal
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
      and sd.id                = nf.sitdocto_id
      and sd.cd           not in ('01', '07') -- extempor�neos
      and mf.id                = nf.modfiscal_id
      and mf.cod_mod          in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and nfi.notafiscal_id    = nf.id
      and ipdf.nfinforfisc_id  = nfi.id
      and cod.id               = ipdf.codocorajicms_id
      and cod.dm_reflexo_apur in (7) -- reflexo na apura��o do icms: 7-D�bitos especiais
      and cod.dm_tipo_apur    in (0, 2); -- tipo de apura��o: 0-Opera��es Pr�prias; 2-outras apura��es
   --
   select sum(nvl(ci.vl_icms,0))
     into vn_vl_icms2
     from conhec_transp    ct
        , sit_docto        sd
        , ct_reg_anal      cr
        , ctinfor_fiscal   cf
        , ct_inf_prov      ci
        , cod_ocor_aj_icms co
    where ct.empresa_id       = gt_row_apuracao_icms.empresa_id
      and ct.dm_st_proc       = 4 -- Autorizado
      and ct.dm_arm_cte_terc  = 0
      and ((ct.dm_ind_emit = 1 and trunc(nvl(ct.dt_sai_ent,ct.dt_hr_emissao)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (ct.dm_ind_emit = 0 and ct.dm_ind_oper = 1 and trunc(ct.dt_hr_emissao) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (ct.dm_ind_emit = 0 and ct.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(ct.dt_hr_emissao) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (ct.dm_ind_emit = 0 and ct.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(ct.dt_sai_ent,ct.dt_hr_emissao)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
      and sd.id               = ct.sitdocto_id
      and sd.cd          not in ('01', '07') -- extempor�neos
      and cr.conhectransp_id  = ct.id
      and cf.conhectransp_id  = ct.id
      and ci.ctinforfiscal_id = cf.id
      and co.id               = ci.codocorajicms_id
      and co.dm_reflexo_apur in (7) -- reflexo na apura��o do icms: 7-D�bitos especiais
      and co.dm_tipo_apur    in (0, 2); -- tipo de apura��o: 0-Opera��es Pr�prias; 2-outras apura��es
   --
   return ( nvl(vn_vl_icms1,0) + nvl(vn_vl_icms2,0) );
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_dep_esp_c197_d197:' || sqlerrm);
end fkg_soma_dep_esp_c197_d197;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna de Valor de ICMS extempor�neo no c197
function fkg_soma_dep_esp_e111
         return ajust_apuracao_icms.vl_aj_apur%type
is
   --
   vn_vl_aj_apur ajust_apuracao_icms.vl_aj_apur%type := 0;
   --
begin
   --
   select nvl(sum(aai.vl_aj_apur),0) vl_aj_apur
     into vn_vl_aj_apur
     from ajust_apuracao_icms aai
        , cod_aj_saldo_apur_icms  cod
    where aai.apuracaoicms_id = gt_row_apuracao_icms.id
      and cod.id              = aai.codajsaldoapuricms_id
      and cod.dm_apur        in (0) -- icms
      and cod.dm_util        in (5); -- utiliza��o: 5-d�bito especial
   --
   return vn_vl_aj_apur;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_dep_esp_e111:' || sqlerrm);
end fkg_soma_dep_esp_e111;

-------------------------------------------------------------------------------------------------------
--| Procedimento limpa os caracteres especiais dos campos de descri��o do Bloco E
procedure pkb_limpa_caracteres_bloco_e ( en_apuracaoicms_id  in apuracao_icms.id%TYPE )
is
   --
   vn_fase number := 0;
   --
begin
   -- Se informou o id da Apura��o de ICMS
   if nvl(en_apuracaoicms_id,0) > 0 then
      --
      vn_fase := 1;
      -- No registro E111
      update ajust_apuracao_icms s
         set s.descr_compl_aj  = trim(pk_csf.fkg_converte(s.descr_compl_aj))
       where s.apuracaoicms_id = en_apuracaoicms_id;
      --
      vn_fase := 2;
      -- No registro E112
      update infor_ajust_apur_icms c
         set c.descr_proc = trim(pk_csf.fkg_converte(c.descr_proc))
           , c.txt_compl  = trim(pk_csf.fkg_converte(c.txt_compl))
       where c.ajustapuracaoicms_id in ( select distinct b.id
                                          from ajust_apuracao_icms a,
                                               infor_ajust_apur_icms b
                                         where a.apuracaoicms_id = en_apuracaoicms_id
                                           and a.id = b.ajustapuracaoicms_id);
      --
      vn_fase := 3;
      -- No registro E115
      update inforadic_apur_icms d
         set d.descr_compl_aj  = trim(pk_csf.fkg_converte(d.descr_compl_aj))
       where d.apuracaoicms_id = en_apuracaoicms_id;
      --
      vn_fase := 4;
      -- No registro E116
      update obrig_rec_apur_icms k
         set k.descr_proc = trim(pk_csf.fkg_converte(k.descr_proc))
           , k.txt_compl  = trim(pk_csf.fkg_converte(k.txt_compl))
       where k.apuracaoicms_id = en_apuracaoicms_id;
      --
      vn_fase := 5;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      --
      gv_resumo_log := 'Erro na pkb_limpa_caracteres_bloco_e fase ( '||vn_fase||' ):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_limpa_caracteres_bloco_e;

-------------------------------------------------------------------------------------------------------
--| Procedure recupera os dados da apura��o de imposto de ICMS
procedure pkb_dados_apuracao_icms ( en_apuracaoicms_id in apuracao_icms.id%type )
is
   --
   vn_fase   number := 0;
   --
   cursor c_apuracao_icms is
   select * from apuracao_icms
    where id = en_apuracaoicms_id;
   --
begin
   --
   vn_fase := 1;
   --
   gt_row_apuracao_icms := null;
   --
   if nvl(en_apuracaoicms_id,0) > 0 then
      --
      vn_fase := 2;
      --
      open c_apuracao_icms;
      fetch c_apuracao_icms into gt_row_apuracao_icms;
      close c_apuracao_icms;
      --
      vn_fase := 3;
      --
      if nvl(gt_row_apuracao_icms.id,0) > 0 then
         --
         vn_fase := 4;
         --
         gn_referencia_id := gt_row_apuracao_icms.id;
         gv_obj_referencia := 'APURACAO_ICMS';
         --
         vn_fase := 5;
         --
         gn_dm_dt_escr_dfepoe := pk_csf.fkg_dmdtescrdfepoe_empresa( en_empresa_id => gt_row_apuracao_icms.empresa_id );
         --
         vn_fase := 6;
         -- Monta mensagem para o log da Apura��o de ICMS
         if nvl(gn_dm_dt_escr_dfepoe,0) = 0 then -- 0-data de emiss�o
            --
            gv_mensagem_log := 'Apura��o de ICMS com Data Inicial '||to_char(gt_row_apuracao_icms.dt_inicio,'dd/mm/rrrr')||
                               ' at� Data Final '||to_char(gt_row_apuracao_icms.dt_fim,'dd/mm/rrrr')||'. Data que ser� considerada para recuperar os '||
                               'documentos fiscais de emiss�o pr�pria com opera��o de entrada: Data de emiss�o.';
            --
         else -- nvl(gn_dm_dt_escr_dfepoe,0) = 1 -- 1-data de entrada/sa�da
            --
            gv_mensagem_log := 'Apura��o de ICMS com Data Inicial '||to_char(gt_row_apuracao_icms.dt_inicio,'dd/mm/rrrr')||
                               ' at� Data Final '||to_char(gt_row_apuracao_icms.dt_fim,'dd/mm/rrrr')||'. Data que ser� considerada para recuperar os '||
                               'documentos fiscais de emiss�o pr�pria com opera��o de entrada: Data da entrada/sa�da.';
            --
         end if;
         --
         vn_fase := 7;
         -- Busca o estado da empresa
         begin
            --
            select cid.estado_id
                 , est.sigla_estado
                 , est.ibge_estado
              into gn_estado_id
                 , gv_sigla_estado
                 , gv_ibge_estado
              from empresa e
                 , pessoa p
                 , cidade cid
                 , estado est
             where e.id    = gt_row_apuracao_icms.empresa_id
               and p.id    = e.pessoa_id
               and cid.id  = p.cidade_id
               and est.id  = cid.estado_id;
            --
         exception
            when others then
               gn_estado_id    := null;
               gv_sigla_estado := null;
               gv_ibge_estado  := null;
         end;
         --
         vn_fase := 8;
         --
         gt_row_param_efd_icms_ipi := pk_csf_efd.fkg_param_efd_icms_ipi ( en_empresa_id => gt_row_apuracao_icms.empresa_id );
         --
      else
         --
         vn_fase := 99;
         gn_referencia_id  := null;
         gv_obj_referencia := null;
         gn_estado_id      := null;
         gv_sigla_estado   := null;
         gv_ibge_estado    := null;
         gt_row_param_efd_icms_ipi := null;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_apur_icms.pkb_dados_apuracao_icms fase( '||vn_fase||' ):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_apuracaoicms_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_dados_apuracao_icms;

-------------------------------------------------------------------------------------------------------
-- Processo para atualizar os valores do registro de apura��o de ICMS - modelo P9
procedure pkb_atualiza_reg_modp9( en_vl_001 in reg_apur_icms_mod9.vl_001%type
                                , en_vl_002 in reg_apur_icms_mod9.vl_002%type
                                , en_vl_003 in reg_apur_icms_mod9.vl_003%type
                                , en_vl_004 in reg_apur_icms_mod9.vl_004%type
                                , en_vl_005 in reg_apur_icms_mod9.vl_005%type
                                , en_vl_006 in reg_apur_icms_mod9.vl_006%type
                                , en_vl_007 in reg_apur_icms_mod9.vl_007%type
                                , en_vl_008 in reg_apur_icms_mod9.vl_008%type
                                , en_vl_009 in reg_apur_icms_mod9.vl_009%type
                                , en_vl_010 in reg_apur_icms_mod9.vl_010%type
                                , en_vl_011 in reg_apur_icms_mod9.vl_011%type
                                , en_vl_012 in reg_apur_icms_mod9.vl_012%type
                                , en_vl_013 in reg_apur_icms_mod9.vl_013%type
                                , en_vl_014 in reg_apur_icms_mod9.vl_014%type
                                , en_vl_015 in reg_apur_icms_mod9.vl_015%type
                                , en_vl_016 in reg_apur_icms_mod9.vl_016%type )
is
begin
   --
   update reg_apur_icms_mod9 ra
      set ra.vl_001 = en_vl_001
        , ra.vl_002 = en_vl_002
        , ra.vl_003 = en_vl_003
        , ra.vl_004 = en_vl_004
        , ra.vl_005 = en_vl_005
        , ra.vl_006 = en_vl_006
        , ra.vl_007 = en_vl_007
        , ra.vl_008 = en_vl_008
        , ra.vl_009 = en_vl_009
        , ra.vl_010 = en_vl_010
        , ra.vl_011 = en_vl_011
        , ra.vl_012 = en_vl_012
        , ra.vl_013 = en_vl_013
        , ra.vl_014 = en_vl_014
        , ra.vl_015 = en_vl_015
        , ra.vl_016 = en_vl_016
    where ra.id = gn_regapuricmsmod9_id;
   --
exception
   when others then
      raise_application_error(-20101, 'Problemas ao atualizar os dados do registro - pkb_atualiza_reg_modp9. Erro: '||sqlerrm);
end pkb_atualiza_reg_modp9;

-------------------------------------------------------------------------------------------------------
-- Processo para incluir os detalhes do registro de apura��o de ICMS - modelo P9
procedure pkb_incluir_reg_modp9_det( en_dm_tipo in reg_apur_icms_mod9_det.dm_tipo%type
                                   , ev_descr   in reg_apur_icms_mod9_det.descr%type
                                   , en_valor   in reg_apur_icms_mod9_det.valor%type )
is
--
-- Valores de dom�nio para dm_tipo:
-- 1-Outros d�bitos
-- 2-Estornos de cr�ditos
-- 3-Outros cr�ditos
-- 4-Estorno de d�bitos
-- 5-Dedu��es
--
begin
   --
   insert into reg_apur_icms_mod9_det ( id
                                      , regapuricmsmod9_id
                                      , dm_tipo
                                      , descr
                                      , valor )
                               values ( regapuricmsmod9det_seq.nextval
                                      , gn_regapuricmsmod9_id
                                      , en_dm_tipo
                                      , ev_descr
                                      , en_valor );
   --
exception
   when others then
      raise_application_error(-20101, 'Problemas ao incluir detalhe - pkb_incluir_reg_modp9_det. Erro: '||sqlerrm);
end pkb_incluir_reg_modp9_det;

-------------------------------------------------------------------------------------------------------
-- Processo para incluir o registro de apura��o de ICMS - modelo P9
procedure pkb_incluir_reg_modp9 is
begin
   --
   insert into reg_apur_icms_mod9 ( id
                                  , apuracaoicms_id
                                  , vl_001
                                  , vl_002
                                  , vl_003
                                  , vl_004
                                  , vl_005
                                  , vl_006
                                  , vl_007
                                  , vl_008
                                  , vl_009
                                  , vl_010
                                  , vl_011
                                  , vl_012
                                  , vl_013
                                  , vl_014
                                  , vl_015
                                  , vl_016 )
                           values ( gn_regapuricmsmod9_id
                                  , gt_row_apuracao_icms.id
                                  , null
                                  , null
                                  , null
                                  , null
                                  , null
                                  , null
                                  , null
                                  , null
                                  , null
                                  , null
                                  , null
                                  , null
                                  , null
                                  , null
                                  , null
                                  , null );
   --
exception
   when others then
      raise_application_error(-20101, 'Problemas ao incluir registro - pkb_incluir_reg_modp9. Erro: '||sqlerrm);
end pkb_incluir_reg_modp9;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna o Total de Cr�dito do ICMS para os registros D190, para apura��o de ICMS - modelo P9.
function fkg_modp9_cred_d190
         return ct_reg_anal.vl_icms%type
is
   --
   vn_vl_icms ct_reg_anal.vl_icms%type := 0;
   --
begin
   --
   select nvl(sum(nvl(cr.vl_icms,0)),0) vl_icms
     into vn_vl_icms
     from conhec_transp    ct
        , sit_docto        sd
        , ct_reg_anal      cr
        , cfop             cf
    where ct.empresa_id      = gt_row_apuracao_icms.empresa_id
      and ct.dm_st_proc      = 4 -- Autorizado
      and ct.dm_arm_cte_terc = 0
      and ct.dm_ind_oper     = 0 -- Entrada
      and ((ct.dm_ind_emit = 1 and trunc(nvl(ct.dt_sai_ent,ct.dt_hr_emissao)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (ct.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(ct.dt_hr_emissao) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (ct.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(ct.dt_sai_ent,ct.dt_hr_emissao)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
      and sd.id              = ct.sitdocto_id
      and sd.cd             in ('00', '06', '08')
      and cr.conhectransp_id = ct.id
      and cf.id              = cr.cfop_id
      and cf.cd        between 1000 and 3999;
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_modp9_cred_d190:' || sqlerrm);
end fkg_modp9_cred_d190;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna o Total de Cr�dito do ICMS para os registros C190, C590 e D590, para apura��o de ICMS - modelo P9.
-------------------------------------------------------------------------------------------------------
function fkg_modp9_cred_c190_c_d_590 
  return nfregist_analit.vl_icms%type is
  --
  vn_vl_icms nfregist_analit.vl_icms%type := 0;
  vn_vl_fcp  imp_itemnf.vl_fcp%type := 0;
  --
begin
  --
  select nvl(sum(nvl(na.vl_icms, 0)), 0) vl_icms
    into vn_vl_icms
    from nota_fiscal     nf,
         sit_docto       sd,
         mod_fiscal      mf,
         nfregist_analit na,
         cfop            cf
   where nf.empresa_id      = gt_row_apuracao_icms.empresa_id
     and nf.dm_st_proc      = 4 -- Autorizada
     and nf.dm_arm_nfe_terc = 0 -- N�o � nota de armazenamento fiscal
     and nf.dm_ind_oper     = 0 -- Entrada
     and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)) 
           or
          (nf.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)) 
           or
          (nf.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
     and sd.id              = nf.sitdocto_id
     and sd.cd              in ('00', '06', '08')
     and mf.id              = nf.modfiscal_id
     and mf.cod_mod         in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
     and na.notafiscal_id   = nf.id
     and cf.id              = na.cfop_id
     and cf.cd between 1000 and 3999
     and not exists (select 1 -- Retorna se o documento � de Antecipa��o de credito de ICMS
                       from nota_fiscal           nfi,
                            nota_fiscal_total     nt,
                            mod_fiscal            mf,
                            sit_docto             sd,
                            item_nota_fiscal      it,
                            cfop                  cf,
                            imp_itemnf            ii,
                            tipo_imposto          ti,
                            nfinfor_fiscal        ni,
                            inf_prov_docto_fiscal ip
                      where nfi.id                   = nf.id
                        and mf.id                    = nfi.modfiscal_id
                        and mf.cod_mod               = '55'
                        and sd.id                    = nfi.sitdocto_id
                        and sd.cd                    = '08' -- Documento Fiscal emitido com base em Regime Especial ou Norma Espec�fica
                        and nt.notafiscal_id         = nfi.id
                        and nvl(nt.vl_total_nf, 0)   = 0
                        and it.notafiscal_id         = nfi.id
                        and nvl(it.vl_item_bruto, 0) = 0
                        and cf.id                    = it.cfop_id
                        and cf.cd                    in (1949, 2949, 3949)
                        and ii.itemnf_id             = it.id
                        and ii.dm_tipo               = 0 -- 0-Imposto / 1-reten��o      
                        and nvl(ii.vl_base_calc, 0)  > 0 -- Valor da base de credito de ICMS maior que zero
                        and nvl(ii.vl_imp_trib, 0)   > 0 -- Valor de tributa��o de ICMS maior que zero
                        and ti.id                    = ii.tipoimp_id
                        and ti.cd                    = 1 -- ICMS
                        and ni.notafiscal_id         = nf.id
                        and ip.nfinforfisc_id        = ni.id);
  --and cf.cd not in (1551, 1556, 1605, 3551, 3949, 3556);
  --
  if gt_row_apuracao_icms.dt_inicio >= to_date('01/08/2018', 'dd/mm/rrrr') then
    --
    -- Recuperar os valores de FCP do Imposto ICMS do Item da Nota Fiscal
    select nvl(sum(nvl(ii.vl_fcp, 0)), 0)
      into vn_vl_fcp
      from nota_fiscal      nf,
           sit_docto        sd,
           mod_fiscal       mf,
           item_nota_fiscal it,
           imp_itemnf       ii,
           tipo_imposto     ti
     where nf.empresa_id      = gt_row_apuracao_icms.empresa_id
       and nf.dm_st_proc      = 4
       and nf.dm_arm_nfe_terc = 0 -- N�o � nota de armazenamento fiscal
       and nf.dm_ind_oper     = 0 -- Entrada
       and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)) 
             or
            (nf.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)) 
             or
            (nf.dm_ind_emit = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
       and sd.id              = nf.sitdocto_id
       and sd.cd              in ('00', '06', '08')
       and mf.id              = nf.modfiscal_id
       and mf.cod_mod         in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
       and it.notafiscal_id   = nf.id
       and it.cfop between 1000 and 3999
       and ii.itemnf_id       = it.id
       and ii.dm_tipo         = 0 -- imposto
       and ti.id              = ii.tipoimp_id
       and ti.cd              = 1; -- ICMS
    --
  else
    --
    vn_vl_fcp := 0;
    --
  end if;
  --
  return(vn_vl_icms + vn_vl_fcp);
  --
exception
  when no_data_found then
    return 0;
  when others then
    raise_application_error(-20101, 'Erro na fkg_modp9_cred_c190_c_d_590:' || sqlerrm);
end fkg_modp9_cred_c190_c_d_590;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna a Soma do ICMS para os registro D696, para apura��o de ICMS - modelo P9.
function fkg_modp9_vlicms_d696
         return reg_an_cons_nf_prest_serv.vl_icms%type
is
   --
   vn_vl_icms reg_an_cons_nf_prest_serv.vl_icms%type := 0;
   --
begin
   --
   select nvl(sum(nvl(r.vl_icms,0)),0) vl_icms
     into vn_vl_icms
     from cons_nf_prest_serv         nf
        , reg_an_cons_nf_prest_serv  r
        , cfop                       c
    where nf.empresa_id          = gt_row_apuracao_icms.empresa_id
      and ( trunc(nf.dt_doc_ini) >= trunc(gt_row_apuracao_icms.dt_inicio) and trunc(nf.dt_doc_ini) <= trunc(gt_row_apuracao_icms.dt_fim) )
      and r.consnfprestserv_id   = nf.id
      and c.id                   = r.cfop_id
      and c.cd             between 5000 and 7999;
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_modp9_vlicms_d696:' || sqlerrm);
end fkg_modp9_vlicms_d696;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna a Soma do ICMS para os registro D690, para apura��o de ICMS - modelo P9.
function fkg_modp9_vlicms_d690
         return reg_an_cons_prest_serv.vl_icms%type
is
   --
   vn_vl_icms reg_an_cons_prest_serv.vl_icms%type := 0;
   --
begin
   --
   select nvl(sum(nvl(r.vl_icms,0)),0) vl_icms
     into vn_vl_icms
     from cons_prest_serv         nf
        , reg_an_cons_prest_serv  r
        , cfop                    c
    where nf.empresa_id          = gt_row_apuracao_icms.empresa_id
      and trunc(nf.dt_doc) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)
      and r.consprestserv_id     = nf.id
      and c.id                   = r.cfop_id
      and c.cd             between 5000 and 7999;
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_modp9_vlicms_d690:' || sqlerrm);
end fkg_modp9_vlicms_d690;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna a Soma do ICMS para os registro D410, para apura��o de ICMS - modelo P9.
function fkg_modp9_vlicms_d410
         return res_mov_dia_doc_infor.vl_icms%type
is
   --
   vn_vl_icms res_mov_dia_doc_infor.vl_icms%type := 0;
   --
begin
   --
   select nvl(sum(nvl(r.vl_icms,0)),0) vl_icms
     into vn_vl_icms
     from res_mov_dia            nf
        , res_mov_dia_doc_infor  r
        , cfop                   c
    where nf.empresa_id          = gt_row_apuracao_icms.empresa_id
      and trunc(nf.dt_doc) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)
      and r.resmovdia_id         = nf.id
      and c.id                   = r.cfop_id
      and c.cd             between 5000 and 7999;
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_modp9_vlicms_d410:' || sqlerrm);
end fkg_modp9_vlicms_d410;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna a Soma do ICMS para os registro D300, para apura��o de ICMS - modelo P9.
function fkg_modp9_vlicms_d300
         return reg_anal_bilhete.vl_icms%type
is
   --
   vn_vl_icms reg_anal_bilhete.vl_icms%type := 0;
   --
begin
   --
   select nvl(sum(nvl(ra.vl_icms,0)),0) vl_icms
     into vn_vl_icms
     from reg_anal_bilhete ra
        , cfop             cf
    where ra.empresa_id          = gt_row_apuracao_icms.empresa_id
      and trunc(ra.dt_doc) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)
      and cf.id                  = ra.cfop_id
      and cf.cd            between 5000 and 7999;
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_modp9_vlicms_d300:' || sqlerrm);
end fkg_modp9_vlicms_d300;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna a Soma do ICMS para os registro D190, para apura��o de ICMS - modelo P9.
function fkg_modp9_vlicms_d190
         return ct_reg_anal.vl_icms%type
is
   --
   vn_vl_icms ct_reg_anal.vl_icms%type := 0;
   --
begin
   --
   select nvl(sum(nvl(r.vl_icms,0)),0) vl_icms
     into vn_vl_icms
     from conhec_transp    ct
        , sit_docto        sd
        , ct_reg_anal      r
        , cfop             c
    where ct.empresa_id      = gt_row_apuracao_icms.empresa_id
      and ct.dm_st_proc      = 4 -- Autorizado
      and ct.dm_arm_cte_terc = 0
      and ct.dm_ind_oper     = 1 -- sa�da
      and ((ct.dm_ind_emit = 1 and trunc(nvl(ct.dt_sai_ent,ct.dt_hr_emissao)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (ct.dm_ind_emit = 0 and trunc(ct.dt_hr_emissao) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
      and sd.id              = ct.sitdocto_id
      and sd.cd             in ('00', '06', '08')
      and r.conhectransp_id  = ct.id
      and c.id               = r.cfop_id
      and c.cd         between 5000 and 7999;
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_modp9_vlicms_d190:' || sqlerrm);
end fkg_modp9_vlicms_d190;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna a Soma do ICMS para os registro C790, para apura��o de ICMS - modelo P9.
function fkg_modp9_vlicms_c790
         return reg_anal_cons_nf_via_unica.vl_icms%type
is
   --
   vn_vl_icms reg_anal_cons_nf_via_unica.vl_icms%type := 0;
   --
begin
   --
   select sum(r.vl_icms) vl_icms
     into vn_vl_icms
     from cons_nf_via_unica nf
        , reg_anal_cons_nf_via_unica r
        , cfop                       c
    where nf.empresa_id           = gt_row_apuracao_icms.empresa_id
      and ( trunc(nf.dt_doc_ini) >= trunc(gt_row_apuracao_icms.dt_inicio)
            and
            trunc(nf.dt_doc_fin) <= trunc(gt_row_apuracao_icms.dt_fim) )
      and r.consnfviaunica_id     = nf.id
      and c.id                    = r.cfop_id
      and c.cd              between 5000 and 7999;
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_modp9_vlicms_c790:' || sqlerrm);
end fkg_modp9_vlicms_c790;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna a Soma do ICMS para os registro C690, para a apura��o de ICMS - modelo P9.
function fkg_modp9_vlicms_c690
         return reg_anal_cons_nota_fiscal.vl_icms%type
is
   --
   vn_vl_icms reg_anal_cons_nota_fiscal.vl_icms%type := 0;
   --
begin
   --
   select sum(r.vl_icms) vl_icms
     into vn_vl_icms
     from cons_nota_fiscal           nf
        , reg_anal_cons_nota_fiscal  r
        , cfop                       c
    where nf.empresa_id          = gt_row_apuracao_icms.empresa_id
      and trunc(nf.dt_doc) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)
      and r.consnotafiscal_id    = nf.id
      and c.id                   = r.cfop_id
      and c.cd             between 5000 and 7999;
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_modp9_vlicms_c690:' || sqlerrm);
end fkg_modp9_vlicms_c690;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna a Soma do ICMS para os registro C490 e D390, para a apura��o de ICMS - modelo P9.
function fkg_modp9_vlicms_c490_d390
         return reg_anal_nf_venda_cons.vl_icms%type
is
   --
   vn_vl_icms reg_anal_nf_venda_cons.vl_icms%type := 0;
   --
begin
   --
   select sum(r.vl_icms) vl_icms
     into vn_vl_icms
     from equip_ecf             e
        , reducao_z_ecf         z
        , reg_anal_mov_dia_ecf  r
        , cfop                  c
    where e.empresa_id          = gt_row_apuracao_icms.empresa_id
      and z.equipecf_id         = e.id
      and z.dm_st_proc          = 1 -- Validada
      and trunc(z.dt_doc) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)
      and r.reducaozecf_id      = z.id
      and c.id                  = r.cfop_id
      and c.cd            between 5000 and 7999;
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_modp9_vlicms_c490_d390:' || sqlerrm);
end fkg_modp9_vlicms_c490_d390;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna a Soma do ICMS para os registro C390, para a apura��o de ICMS - modelo P9.
function fkg_modp9_vlicms_c390
         return reg_anal_nf_venda_cons.vl_icms%type
is
   --
   vn_vl_icms reg_anal_nf_venda_cons.vl_icms%type := 0;
   --
begin
   --
   select sum(r.vl_icms) vl_icms
     into vn_vl_icms
     from nf_venda_cons           nf
        , reg_anal_nf_venda_cons  r
        , cfop                    c
    where nf.empresa_id          = gt_row_apuracao_icms.empresa_id
      and trunc(nf.dt_doc) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)
      and r.nfvendacons_id       = nf.id
      and c.id                   = r.cfop_id
      and c.cd             between 5000 and 7999;
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_modp9_vlicms_c390:' || sqlerrm);
end fkg_modp9_vlicms_c390;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna a Soma do ICMS para os registro C320, para a apura��o de ICMS - modelo P9.
function fkg_modp9_vlicms_c320
         return reg_an_res_dia_nf_venda_cons.vl_icms%type
is
   --
   vn_vl_icms reg_an_res_dia_nf_venda_cons.vl_icms%type := 0;
   --
begin
   --
   select sum(r.vl_icms) vl_icms
     into vn_vl_icms
     from res_dia_nf_venda_cons         nf
        , reg_an_res_dia_nf_venda_cons  r
        , cfop                          c
    where nf.empresa_id          = gt_row_apuracao_icms.empresa_id
      and trunc(nf.dt_doc) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)
      and r.resdianfvendacons_id = nf.id
      and c.id                   = r.cfop_id
      and c.cd             between 5000 and 7999;
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_modp9_vlicms_c320:' || sqlerrm);
end fkg_modp9_vlicms_c320;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna a Soma do ICMS dos registros C190, C590 e D590, para a apura��o de ICMS - modelo P9.
function fkg_modp9_vlicms_c190_c_d_590
         return nfregist_analit.vl_icms%type
is
   --
   vn_vl_icms nfregist_analit.vl_icms%type := 0;
   vn_vl_fcp  imp_itemnf.vl_fcp%type := 0;
   --
begin
   --
   select nvl(sum(nvl(r.vl_icms,0)),0)
     into vn_vl_icms
     from nota_fiscal      nf
        , sit_docto        sd
        , mod_fiscal       mf
        , nfregist_analit  r
        , cfop             c
    where nf.empresa_id      = gt_row_apuracao_icms.empresa_id
      and nf.dm_st_proc      = 4 -- Autorizada
      and nf.dm_arm_nfe_terc = 0 -- N�o � nota de armazenamento fiscal
      and nf.dm_ind_oper     = 1 -- Sa�da
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (nf.dm_ind_emit = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
      and sd.id              = nf.sitdocto_id
      and sd.cd             in ('00', '06', '08')
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and r.notafiscal_id    = nf.id
      and c.id               = r.cfop_id
      and c.cd         between 5000 and 7999
      and c.cd          not in (5602, 5605, 5929, 6602, 6929);
   --
   if gt_row_apuracao_icms.dt_inicio >= to_date('01/08/2018','dd/mm/rrrr') then
      -- Recuperar os valores de FCP do Imposto ICMS do Item da Nota Fiscal
      select sum(nvl(ii.vl_fcp,0))
        into vn_vl_fcp
        from nota_fiscal      nf
           , sit_docto        sd
           , mod_fiscal       mf
           , item_nota_fiscal it
           , imp_itemnf       ii
           , tipo_imposto     ti
       where nf.empresa_id      = gt_row_apuracao_icms.empresa_id
         and nf.dm_st_proc      = 4 -- Autorizada
         and nf.dm_arm_nfe_terc = 0 -- N�o � nota de armazenamento fiscal
         and nf.dm_ind_oper     = 1 -- Sa�da
         and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
               or
              (nf.dm_ind_emit = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
         and sd.id              = nf.sitdocto_id
         and sd.cd             in ('00', '06', '08')
         and mf.id              = nf.modfiscal_id
         and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
         and it.notafiscal_id   = nf.id
         and it.cfop      between 5000 and 7999
         and it.cfop          not in (5602, 5605, 5929, 6602, 6929)
         and ii.itemnf_id       = it.id
         and ii.dm_tipo         = 0 -- imposto
         and ti.id              = ii.tipoimp_id
         and ti.cd              = 1; -- ICMS
      --
   else
      --
      vn_vl_fcp := 0;
      --
   end if;
   --
   return (vn_vl_icms + vn_vl_fcp);
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_modp9_vlicms_c190_c_d_590:' || sqlerrm);
end fkg_modp9_vlicms_c190_c_d_590;

-------------------------------------------------------------------------------------------------------
-- Procedimento para montar os dados do livro de apura��o de ICMS Modelo P9
-------------------------------------------------------------------------------------------------------
procedure pkb_monta_reg_modp9 is
  --
  vn_fase   number := 0;
  vn_vl_001 number := null;
  vn_vl_002 number := null;
  vn_vl_003 number := null;
  vn_vl_004 number := null;
  vn_vl_005 number := null;
  vn_vl_006 number := null;
  vn_vl_007 number := null;
  vn_vl_008 number := null;
  vn_vl_009 number := null;
  vn_vl_010 number := null;
  vn_vl_011 number := null;
  vn_vl_012 number := null;
  vn_vl_013 number := null;
  vn_vl_014 number := null;
  vn_vl_015 number := null;
  vn_vl_016 number := null;
  --
  -- Retornar o Vlr Total dos Lan�amentos de Ajustes a d�bito, para apura��o de ICMS - modelo P9.
  cursor c_tot_aj_debitos is
    select case
             when trim(aai.descr_compl_aj) is null then
              substr('Ajuste: ' || cod.cod_aj_apur || '-' || cod.descr ||
                     decode(aai.descr_compl_aj,
                            null,
                            null,
                            ' Complemento: ' || aai.descr_compl_aj), 1, 255)
             else
              trim(aai.descr_compl_aj)
           end descr_ajuste,
           nvl(aai.vl_aj_apur, 0) vl_aj_apur
      from ajust_apuracao_icms aai, 
           cod_aj_saldo_apur_icms cod
     where aai.apuracaoicms_id    = gt_row_apuracao_icms.id
       and cod.id                 = aai.codajsaldoapuricms_id
       and cod.dm_apur            in (0) -- ICMS
       and cod.dm_util            in (0) -- utiliza��o: 0-Outros D�bitos
       and nvl(aai.vl_aj_apur, 0) > 0;
  --
  -- Retornar o Vlr Total dos ajustes a d�bito decorrentes do documento fiscal, para apura��o de ICMS - modelo P9.
  cursor c_aj_debito is
    select substr('Nota/S�rie: ' || nf.nro_nf || '/' || nf.serie ||
                  ' Emiss�o: ' || to_char(nf.dt_emiss, 'dd/mm/yyyy') ||
                  ' Ajuste: ' || cod.cod_aj || '-' || cod.descr ||
                  decode(ipdf.descr_compl_aj,
                         null,
                         null,
                         ' Complemento: ' || ipdf.descr_compl_aj), 1, 255) descr_ajuste,
           nvl(ipdf.vl_icms, 0) vl_icms
      from nota_fiscal           nf,
           sit_docto             sd,
           mod_fiscal            mf,
           nfinfor_fiscal        nfi,
           inf_prov_docto_fiscal ipdf,
           cod_ocor_aj_icms      cod
     where nf.empresa_id        = gt_row_apuracao_icms.empresa_id
       and nf.dm_st_proc        = 4 -- Autorizada
       and nf.dm_arm_nfe_terc   = 0 -- N�o � nota de armazenamento fiscal
       and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
       and sd.id                = nf.sitdocto_id
       and sd.cd                not in ('01', '07') -- Extempor�neos
       and mf.id                = nf.modfiscal_id
       and mf.cod_mod           in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
       and nfi.notafiscal_id    = nf.id
       and ipdf.nfinforfisc_id  = nfi.id
       and cod.id               = ipdf.codocorajicms_id
       and cod.dm_reflexo_apur  in (3, 4, 5) -- Reflexo na apura��o do ICMS: 3-D-D�bito por Sa�da, 4-D-Outros D�bitos, 5-D-Estorno de Cr�dito
       and cod.dm_tipo_apur     in (0) -- Tipo de Apura��o: 0-Opera��o Pr�pria
       and nvl(ipdf.vl_icms, 0) > 0
    union all
    select substr('Nota/S�rie: ' || ct.nro_ct || '/' || ct.serie ||
                  ' Emiss�o: ' || to_char(ct.dt_hr_emissao, 'dd/mm/yyyy') ||
                  ' Ajuste: ' || co.cod_aj || '-' || co.descr ||
                  decode(ci.descr_compl_aj,
                         null,
                         null,
                         ' Complemento: ' || ci.descr_compl_aj), 1, 255) descr_ajuste,
           nvl(ci.vl_icms, 0) vl_icms
    --into vn_vl_icms2
      from conhec_transp    ct,
           sit_docto        sd,
           ct_reg_anal      cr,
           ctinfor_fiscal   cf,
           ct_inf_prov      ci,
           cod_ocor_aj_icms co
     where ct.empresa_id       = gt_row_apuracao_icms.empresa_id
       and ct.dm_st_proc       = 4 -- Autorizado
       and ct.dm_arm_cte_terc  = 0
       and ((ct.dm_ind_emit = 1 and trunc(nvl(ct.dt_sai_ent, ct.dt_hr_emissao)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)) 
             or
            (ct.dm_ind_emit = 0 and ct.dm_ind_oper = 1 and trunc(ct.dt_hr_emissao) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)) 
             or
            (ct.dm_ind_emit = 0 and ct.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(ct.dt_hr_emissao) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)) 
             or
            (ct.dm_ind_emit = 0 and ct.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(ct.dt_sai_ent, ct.dt_hr_emissao)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
       and sd.id               = ct.sitdocto_id
       and sd.cd               not in ('01', '07') -- Extempor�neos
       and cr.conhectransp_id  = ct.id
       and cf.conhectransp_id  = ct.id
       and ci.ctinforfiscal_id = cf.id
       and co.id               = ci.codocorajicms_id
       and co.dm_reflexo_apur  in (3, 4, 5) -- Reflexo na apura��o do ICMS: 3-D-D�bito por Sa�da, 4-D-Outros D�bitos, 5-D-Estorno de Cr�dito
       and co.dm_tipo_apur     in (0, 3, 4, 5);
  --
  -- Retornar a soma dos Lan�amentos de estornos de cr�dito, para apura��o de ICMS - modelo P9.
  cursor c_estornos_cred is
    select case
             when trim(aai.descr_compl_aj) is null then
              substr('Ajuste: ' || cod.cod_aj_apur || '-' || cod.descr ||
                     decode(aai.descr_compl_aj,
                            null,
                            null,
                            ' Complemento: ' || aai.descr_compl_aj), 1, 255)
             else
              trim(aai.descr_compl_aj)
           end descr_ajuste,
           nvl(aai.vl_aj_apur, 0) vl_aj_apur
      from ajust_apuracao_icms aai, 
           cod_aj_saldo_apur_icms cod
     where aai.apuracaoicms_id = gt_row_apuracao_icms.id
       and cod.id              = aai.codajsaldoapuricms_id
       and cod.dm_apur         in (0) -- ICMS
       and cod.dm_util         in (1); -- Utiliza��o: 1-Estorno de cr�dito
  --
  -- Retorna a soma dos Lan�amentos de Ajustes a Cr�dito, para apura��o de ICMS - modelo P9.
  cursor c_tot_aj_credito is
    select case
             when trim(aai.descr_compl_aj) is null then
              substr('Ajuste: ' || cod.cod_aj_apur || '-' || cod.descr ||
                     decode(aai.descr_compl_aj,
                            null,
                            null,
                            ' Complemento: ' || aai.descr_compl_aj), 1, 255)
             else
              trim(aai.descr_compl_aj)
           end descr_ajuste,
           nvl(aai.vl_aj_apur, 0) vl_aj_apur
      from ajust_apuracao_icms aai, 
           cod_aj_saldo_apur_icms cod
     where aai.apuracaoicms_id    = gt_row_apuracao_icms.id
       and cod.id                 = aai.codajsaldoapuricms_id
       and cod.dm_apur            in (0) -- ICMS
       and cod.dm_util            in (2) -- Utiliza��o: 2-Outros Cr�ditos
       and nvl(aai.vl_aj_apur, 0) > 0;
  --
  -- Retorna o Vlr. Total dos Ajustes de cr�ditos decorrentes do documento fiscal, para apura��o de ICMS - modelo P9.
  cursor c_aj_credito is
    select substr('Nota/S�rie: ' || nf.nro_nf || '/' || nf.serie ||
                  ' Emiss�o: ' || to_char(nf.dt_emiss, 'dd/mm/yyyy') ||
                  ' Ajuste: ' || cod.cod_aj || '-' || cod.descr ||
                  decode(ipdf.descr_compl_aj,
                         null,
                         null,
                         ' Complemento: ' || ipdf.descr_compl_aj), 1, 255) descr_ajuste,
           nvl(ipdf.vl_icms, 0) vl_icms
      from nota_fiscal           nf,
           sit_docto             sd,
           mod_fiscal            mf,
           nfinfor_fiscal        nfi,
           inf_prov_docto_fiscal ipdf,
           cod_ocor_aj_icms      cod
     where nf.empresa_id        = gt_row_apuracao_icms.empresa_id
       and nf.dm_st_proc        = 4
       and nf.dm_arm_nfe_terc   = 0 -- N�o � nota de armazenamento fiscal
       and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
       and sd.id                = nf.sitdocto_id
       and sd.cd                not in ('01', '07') -- Extempor�neos
       and mf.id                = nf.modfiscal_id
       and mf.cod_mod           in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
       and nfi.notafiscal_id    = nf.id
       and ipdf.nfinforfisc_id  = nfi.id
       and cod.id               = ipdf.codocorajicms_id
       and cod.dm_reflexo_apur  in (0, 1, 2) -- Reflexo na Apura��o do ICMS: 0-C-Cr�dito por Entrada, 1-C-Outros Cr�ditos, 2-C-Estorno de D�bito
       and cod.dm_tipo_apur     in (0) -- Tipo de Apura��o: 0-Opera��o Pr�pria
       and nvl(ipdf.vl_icms, 0) > 0
    union all
    select substr('Nota/S�rie: ' || ct.nro_ct || '/' || ct.serie ||
                  ' Emiss�o: ' || to_char(ct.dt_hr_emissao, 'dd/mm/yyyy') ||
                  ' Ajuste: ' || co.cod_aj || '-' || co.descr ||
                  decode(ci.descr_compl_aj,
                         null,
                         null,
                         ' Complemento: ' || ci.descr_compl_aj), 1, 255) descr_ajuste,
           nvl(ci.vl_icms, 0) vl_icms
    --into vn_vl_icms2
      from conhec_transp    ct,
           sit_docto        sd,
           ct_reg_anal      cr,
           ctinfor_fiscal   cf,
           ct_inf_prov      ci,
           cod_ocor_aj_icms co
     where ct.empresa_id       = gt_row_apuracao_icms.empresa_id
       and ct.dm_st_proc       = 4 -- Autorizado
       and ct.dm_arm_cte_terc  = 0
       and ((ct.dm_ind_emit = 1 and trunc(nvl(ct.dt_sai_ent, ct.dt_hr_emissao)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)) 
             or
            (ct.dm_ind_emit = 0 and ct.dm_ind_oper = 1 and trunc(ct.dt_hr_emissao) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)) 
             or
            (ct.dm_ind_emit = 0 and ct.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(ct.dt_hr_emissao) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)) 
             or
            (ct.dm_ind_emit = 0 and ct.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(ct.dt_sai_ent, ct.dt_hr_emissao)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
       and sd.id               = ct.sitdocto_id
       and sd.cd               not in ('01', '07') -- Extempor�neos
       and cr.conhectransp_id  = ct.id
       and cf.conhectransp_id  = ct.id
       and ci.ctinforfiscal_id = cf.id
       and co.id               = ci.codocorajicms_id
       and co.dm_reflexo_apur  in (0, 1, 2) -- Reflexo na Apura��o do ICMS: 0-C-Cr�dito por Entrada, 1-C-Outros Cr�ditos, 2-C-Estorno de D�bito
       and co.dm_tipo_apur     in (0, 3, 4, 5);
  --
  -- Retorna a soma dos Lan�amentos de Estorno de D�bitos, para apura��o de ICMS - modelo P9.
  cursor c_estorno_deb is
    select case
             when trim(aai.descr_compl_aj) is null then
              substr('Ajuste: ' || cod.cod_aj_apur || '-' || cod.descr ||
                     decode(aai.descr_compl_aj,
                            null,
                            null,
                            ' Complemento: ' || aai.descr_compl_aj), 1, 255)
             else
              trim(aai.descr_compl_aj)
           end descr_ajuste,
           nvl(aai.vl_aj_apur, 0) vl_aj_apur
      from ajust_apuracao_icms aai, 
           cod_aj_saldo_apur_icms cod
     where aai.apuracaoicms_id    = gt_row_apuracao_icms.id
       and cod.id                 = aai.codajsaldoapuricms_id
       and cod.dm_apur            in (0) -- ICMS
       and cod.dm_util            in (3) -- Utiliza��o: 3-Estorno de d�bito
       and nvl(aai.vl_aj_apur, 0) > 0;
  --
  -- Retorna a Total de Dedu��o do Registro C197, para apura��o de ICMS - modelo P9.
  cursor c_tot_ded_c197 is
    select substr('Nota/S�rie: ' || nf.nro_nf || '/' || nf.serie ||
                  ' Emiss�o: ' || to_char(nf.dt_emiss, 'dd/mm/yyyy') ||
                  ' Ajuste: ' || cod.cod_aj || '-' || cod.descr ||
                  decode(ipdf.descr_compl_aj,
                         null,
                         null,
                         ' Complemento: ' || ipdf.descr_compl_aj), 1, 255) descr_ajuste,
           nvl(ipdf.vl_icms, 0) vl_icms
      from nota_fiscal           nf,
           sit_docto             sd,
           mod_fiscal            mf,
           nfinfor_fiscal        nfi,
           inf_prov_docto_fiscal ipdf,
           cod_ocor_aj_icms      cod
     where nf.empresa_id        = gt_row_apuracao_icms.empresa_id
       and nf.dm_st_proc        = 4 -- Autorizada
       and nf.dm_arm_nfe_terc   = 0 -- N�o � nota de armazenamento fiscal
       and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
       and sd.id                = nf.sitdocto_id
       and sd.cd                not in ('01', '07') -- Extempor�neos
       and mf.id                = nf.modfiscal_id
       and mf.cod_mod           in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
       and nfi.notafiscal_id    = nf.id
       and ipdf.nfinforfisc_id  = nfi.id
       and cod.id               = ipdf.codocorajicms_id
       and cod.dm_reflexo_apur  in (6) -- Reflexo na Apura��o do ICMS: 6-Dedu��o
       and cod.dm_tipo_apur     in (0) -- Tipo de Apura��o: 0-Opera��es Pr�prias
       and nvl(ipdf.vl_icms, 0) > 0;
  --
  -- retorna a Total de Dedu��o do Registro E111
  cursor c_tot_deb_e111 is
    select substr((cod.COD_AJ_APUR || '-' || cod.descr), 1, 250) descr,
           nvl(sum(aai.vl_aj_apur), 0) vl_aj_apur
      from ajust_apuracao_icms aai, cod_aj_saldo_apur_icms cod
     where aai.apuracaoicms_id = gt_row_apuracao_icms.id
       and cod.id = aai.codajsaldoapuricms_id
       and cod.dm_apur in (0) -- icms
       and cod.dm_util in (4) -- utiliza��o: 4-Dedu��es
     group by substr((cod.COD_AJ_APUR || '-' || cod.descr), 1, 250)
     order by 1;
  --
begin
  --
  vn_fase := 1;
  --
  -- Recuperar a sequence para o registro de apura��o de modelo P9
  begin
    select regapuricmsmod9_seq.nextval
      into gn_regapuricmsmod9_id
      from dual;
  exception
    when others then
      raise_application_error(-20101, 'Problemas ao recuperar sequence para reg_apur_icms_mod9. Erro = ' || sqlerrm);
  end;
  --
  vn_fase := 2;
  --
  pkb_incluir_reg_modp9; -- in�cio dos valores
  --
  vn_fase := 3;
  --
  -- VL_001 => 001-Por sa�das com d�bito do imposto.
  --           Somat�rio do valor de ICMS referente aos CFOPs de 5000 a 7999. Recuperar os dados da coluna VL_TOTAL_DEBITO tabela APURACAO_ICMS.
  vn_vl_001 := nvl(fkg_modp9_vlicms_c190_c_d_590, 0) +
               nvl(fkg_modp9_vlicms_c320, 0) +
               nvl(fkg_modp9_vlicms_c390, 0) +
               nvl(fkg_modp9_vlicms_c490_d390, 0) +
               nvl(fkg_modp9_vlicms_c690, 0) +
               nvl(fkg_modp9_vlicms_c790, 0) +
               nvl(fkg_modp9_vlicms_d190, 0) +
               nvl(fkg_modp9_vlicms_d300, 0) +
               nvl(fkg_modp9_vlicms_d410, 0) +
               nvl(fkg_modp9_vlicms_d690, 0) +
               nvl(fkg_modp9_vlicms_d696, 0) +
               nvl(fkg_soma_vl_icms_c800, 0);
  --
  vn_fase := 4;
  --
  -- VL_002 => 002-Outros d�bitos.
  --          Somat�rio dos valores de ICMS decorrentes da aba "Ajustes/Benef�cios/Incentivos" cuja utiliza��o seja igual a "Outros D�bitos".
  --          Utilizar as condi��es de pesquisa das fun��es "fkg_soma_aj_debito" e "fkg_soma_tot_aj_debitos".
  --          Alimentando a tabela REG_APUR_ICMS_MOD9_DET com o dom�nio "Outros D�bitos".
  vn_vl_002 := 0;
  --
  -- Retornar o Vlr Total dos Lan�amentos de Ajustes a d�bito, para apura��o de ICMS - modelo P9.
  for reg in c_tot_aj_debitos loop 
   exit when c_tot_aj_debitos%notfound or (c_tot_aj_debitos%notfound) is null;
    --
    vn_fase := 5;
    --
    pkb_incluir_reg_modp9_det(en_dm_tipo => 1, -- Outros D�bitos
                              ev_descr   => reg.descr_ajuste,
                              en_valor   => reg.vl_aj_apur);
    --
    vn_fase := 6;
    --
    vn_vl_002 := nvl(vn_vl_002, 0) + nvl(reg.vl_aj_apur, 0);
    --
  end loop;
  --
  vn_fase := 7;
  --
  -- Retornar o Vlr Total dos ajustes a d�bito decorrentes do documento fiscal, para apura��o de ICMS - modelo P9.
  for reg in c_aj_debito loop
    exit when c_aj_debito%notfound or (c_aj_debito%notfound) is null;
    --
    vn_fase := 8;
    --
    pkb_incluir_reg_modp9_det(en_dm_tipo => 1, -- Outros D�bitos
                              ev_descr   => reg.descr_ajuste,
                              en_valor   => reg.vl_icms);
    --
    vn_fase := 9;
    --
    vn_vl_002 := nvl(vn_vl_002, 0) + nvl(reg.vl_icms, 0);
    --
  end loop;
  --
  vn_fase := 10;
  --
  -- VL_003 => 003-Estornos de cr�ditos.
  --           Somat�rio dos valores de ICMS decorrentes da aba "Ajustes/Benef�cios/Incentivos" cuja utiliza��o seja igual a "Estorno de Cr�ditos".
  --           Utilizar as condi��es de pesquisa da fun��o "fkg_soma_estornos_cred", alimentando a tabela REG_APUR_ICMS_MOD9_DET, dom�nio "ESTORNOS DE CR�DITOS".
  vn_vl_003 := 0;
  --
  for reg in c_estornos_cred loop
    exit when c_estornos_cred%notfound or (c_estornos_cred%notfound) is null;
    --
    vn_fase := 11;
    --
    pkb_incluir_reg_modp9_det(en_dm_tipo => 2, -- Estornos de Cr�dito
                              ev_descr   => reg.descr_ajuste,
                              en_valor   => reg.vl_aj_apur);
    --
    vn_fase := 12;
    --
    vn_vl_003 := nvl(vn_vl_003, 0) + nvl(reg.vl_aj_apur, 0);
    --
  end loop;
  --
  vn_fase := 13;
  --
  vn_vl_004 := null;
  --
  -- VL_005 => 005-Totais: Somat�rio dos valores correspondentes aos campos 001, 002 e 003 descritos imediatamente acima deste item.
  vn_vl_005 := nvl(vn_vl_001, 0) + nvl(vn_vl_002, 0) + nvl(vn_vl_003, 0);
  --
  vn_fase := 14;
  --
  -- VL_006 => 006-Por entradas com cr�dito do imposto: Somat�rio do valor de ICMS referente aos CFOPs de 1000 a 3999.
  --           Recuperar os dados da coluna VL_TOTAL_CREDITO tabela APURACAO_ICMS.
  vn_vl_006 := nvl(fkg_modp9_cred_c190_c_d_590, 0) +
               nvl(fkg_modp9_cred_d190, 0);
  --
  vn_fase := 15;
  --
  -- VL_007 => 007-Outros cr�ditos: Somat�rio dos valores de ICMS decorrentes da aba "Ajustes/Benef�cios/Incentivos" com utiliza��o = "Outros Cr�ditos".
  --           Utilizar as condi��es de pesquisa das fun��es "fkg_soma_aj_credito" e "fkg_soma_tot_aj_credito".
  --           Alimentando a tabela REG_APUR_ICMS_MOD9_DET com o dom�nio "OUTROS CR�DITOS".
  vn_vl_007 := 0;
  --
  -- Retorna a soma dos Lan�amentos de Ajustes a Cr�dito, para apura��o de ICMS - modelo P9.
  for reg in c_tot_aj_credito loop
    exit when c_tot_aj_credito%notfound or (c_tot_aj_credito%notfound) is null;
    --
    vn_fase := 16;
    --
    pkb_incluir_reg_modp9_det(en_dm_tipo => 3, -- Outros Cr�ditos
                              ev_descr   => reg.descr_ajuste,
                              en_valor   => reg.vl_aj_apur);
    --
    vn_fase := 17;
    --
    vn_vl_007 := nvl(vn_vl_007, 0) + nvl(reg.vl_aj_apur, 0);
    --
  end loop;
  --
  vn_fase := 18;
  --
  -- Retorna o Vlr. Total dos Ajustes de cr�ditos decorrentes do documento fiscal, para apura��o de ICMS - modelo P9.
  for reg in c_aj_credito loop
    exit when c_aj_credito%notfound or (c_aj_credito%notfound) is null;
    --
    vn_fase := 19;
    --
    pkb_incluir_reg_modp9_det(en_dm_tipo => 3, -- Outros Cr�ditos
                              ev_descr   => reg.descr_ajuste,
                              en_valor   => reg.vl_icms);
    --
    vn_fase := 20;
    --
    vn_vl_007 := nvl(vn_vl_007, 0) + nvl(reg.vl_icms, 0);
    --
  end loop;
  --
  vn_fase := 21;
  --
  -- VL_008 => 008-Estorno de d�bitos: Somat�rio dos valores de ICMS decorrentes da aba "Ajustes/Benef�cios/Incentivos" com utiliza��o = "Estorno de D�bitos".
  --           Utilizar as condi��es de pesquisa das fun��es "fkg_soma_estorno_deb", alimentando a tabela REG_APUR_ICMS_MOD9_DET, dom�nio = "ESTORNO DE D�BITOS".
  vn_vl_008 := 0;
  --
  -- Retorna a soma dos Lan�amentos de Estorno de D�bitos, para apura��o de ICMS - modelo P9.
  for reg in c_estorno_deb loop
    exit when c_estorno_deb%notfound or (c_estorno_deb%notfound) is null;
    --
    vn_fase := 22;
    --
    pkb_incluir_reg_modp9_det(en_dm_tipo => 4, -- Estorno de D�bitos
                              ev_descr   => reg.descr_ajuste,
                              en_valor   => reg.vl_aj_apur);
    --
    vn_fase := 23;
    --
    vn_vl_008 := nvl(vn_vl_008, 0) + nvl(reg.vl_aj_apur, 0);
    --
  end loop;
  --
  vn_fase := 24;
  --
  -- VL_009 => Null
  vn_vl_009 := null;
  --
  -- VL_010 => 010-Subtotal: Somat�rio dos valores correspondentes aos campos 006, 007 e 008 descritos imediatamente acima deste item.
  vn_vl_010 := nvl(vn_vl_006, 0) + nvl(vn_vl_007, 0) + nvl(vn_vl_008, 0);
  --
  vn_fase := 25;
  --
  -- VL_011 => 011-Saldo credor do per�odo anterior: Valor correspondente ao campo "09 Valor total de Saldo Credor do Per�odo Anterior" da aba "Apura��o de ICMS".
  --           Recuperar os dados da coluna VL_SALDO_CREDOR_ANT tabela APURACAO_ICMS.
  vn_vl_011 := nvl(gt_row_apuracao_icms.vl_saldo_credor_ant, 0);
  --
  vn_fase := 26;
  --
  -- VL_012 => 012-Total: Ser� o Valor do Item 010, maior o valor do item 011 descritos acimas. Valor pode ficar negativo.
  vn_vl_012 := nvl(vn_vl_010, 0) + nvl(vn_vl_011, 0);
  --
  vn_fase := 27;
  --
  -- VL_013 => 013-Saldo devedor (d�bito menos cr�dito): Ser� igual ao valor do item 005, menos o valor do item 012 descritos acima. Valor pode ficar negativo.
  vn_vl_013 := nvl(vn_vl_005, 0) - nvl(vn_vl_012, 0);
  --
  if nvl(vn_vl_013, 0) < 0 then
    vn_vl_013 := 0;
  end if;
  --
  vn_fase := 28;
  --
  -- VL_014 => 014-Dedu��es: Recupera valor do campo "11 - Valor total de dedu��es" da aba "Apura��o de ICMS".
  --           Utilizar as condi��es de pesquisa das fun��es "fkg_soma_tot_ded_c197" e "fkg_soma_tot_ded_e111".
  --           Alimentando a tabela REG_APUR_ICMS_MOD9_DET com o dom�nio "DEDU��ES".
  vn_vl_014 := 0;
  --
  for reg in c_tot_ded_c197 loop
    exit when c_tot_ded_c197%notfound or (c_tot_ded_c197%notfound) is null;
    --
    vn_fase := 29;
    --
    pkb_incluir_reg_modp9_det(en_dm_tipo => 5, -- Dedu��es
                              ev_descr   => reg.descr_ajuste,
                              en_valor   => reg.vl_icms);
    --
    vn_fase := 30;
    --
    vn_vl_014 := nvl(vn_vl_014, 0) + nvl(reg.vl_icms, 0);
    --
  end loop;
  --
  vn_fase := 30.1;
  --
  for reg in c_tot_deb_e111 loop
    exit when c_tot_deb_e111%notfound or (c_tot_deb_e111%notfound) is null;
    --
    vn_fase := 30.2;
    --
    pkb_incluir_reg_modp9_det(en_dm_tipo => 5, -- Dedu��es
                              ev_descr   => reg.descr,
                              en_valor   => reg.vl_aj_apur);
    --
    vn_fase := 30.3;
    --
    vn_vl_014 := nvl(vn_vl_014, 0) + nvl(reg.vl_aj_apur, 0);
    --
  end loop;
  --
  vn_fase := 31;
  --
  -- VL_015 => 015-Imposto a recolher: Ser� o resultado do item 013, menos o valor do item 014 descritos acima. Se o resultado for negativo, atribuir zero.
  vn_vl_015 := nvl(vn_vl_013, 0) - nvl(vn_vl_014, 0);
  --
  if nvl(vn_vl_015, 0) <= 0 then
    vn_vl_015 := 0;
  end if;
  --
  vn_fase := 32;
  --
  -- VL_016 => 016-Saldo credor (cr�dito menos d�bito) a transportar para o per�odo seguinte.
  --           Ser� o valor dos Cr�ditos menos o valor dos D�bitos, quando o valor dos cr�ditos for superior ao valor dos d�bitos.
  --           Se o resultado for negativo, atribuir zero.
  if (nvl(vn_vl_006, 0) + nvl(vn_vl_007, 0) + nvl(vn_vl_008, 0) + nvl(vn_vl_011, 0) + nvl(vn_vl_014, 0)) >=
     (nvl(vn_vl_001, 0) + nvl(vn_vl_002, 0) + nvl(vn_vl_003, 0)) then
    --
    vn_vl_016 := (nvl(vn_vl_006, 0) + 
                  nvl(vn_vl_007, 0) + 
                  nvl(vn_vl_008, 0) +
                  nvl(vn_vl_011, 0) + 
                  nvl(vn_vl_014, 0)) -
                 (nvl(vn_vl_001, 0) + 
                  nvl(vn_vl_002, 0) + 
                  nvl(vn_vl_003, 0));
    --
  end if;
  --
  vn_fase := 33;
  --
  if nvl(vn_vl_016, 0) <= 0 then
    vn_vl_016 := 0;
  end if;
  --
  vn_fase := 34;
  --
  pkb_atualiza_reg_modp9(en_vl_001 => vn_vl_001,
                         en_vl_002 => vn_vl_002,
                         en_vl_003 => vn_vl_003,
                         en_vl_004 => vn_vl_004,
                         en_vl_005 => vn_vl_005,
                         en_vl_006 => vn_vl_006,
                         en_vl_007 => vn_vl_007,
                         en_vl_008 => vn_vl_008,
                         en_vl_009 => vn_vl_009,
                         en_vl_010 => vn_vl_010,
                         en_vl_011 => vn_vl_011,
                         en_vl_012 => vn_vl_012,
                         en_vl_013 => vn_vl_013,
                         en_vl_014 => vn_vl_014,
                         en_vl_015 => vn_vl_015,
                         en_vl_016 => vn_vl_016);
  --
exception
  when others then
    --
    gv_resumo_log := 'Erro na pk_apur_icms.pkb_monta_reg_modp9 fase (' || vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id Log_Generico.id%TYPE;
    begin
      --
      pk_log_generico.pkb_log_generico(sn_loggenerico_id => vn_loggenerico_id,
                                       ev_mensagem       => gv_mensagem_log,
                                       ev_resumo         => gv_resumo_log,
                                       en_tipo_log       => ERRO_DE_SISTEMA,
                                       en_referencia_id  => gn_referencia_id,
                                       ev_obj_referencia => gv_obj_referencia);
      --
    exception
      when others then
        null;
    end;
    --
    raise_application_error(-20101, gv_resumo_log);
    --
end pkb_monta_reg_modp9;

-------------------------------------------------------------------------------------------------------
-- Procedimento para limpar os dados do livro P9 de icms
procedure pkb_limpa_reg_modp9
is
   --
   vn_fase number := null;
   --
begin
   --
   vn_fase := 1;
   -- Limpar os dados das tabelas de apura��o de modelo P9 - detalhes
   delete from reg_apur_icms_mod9_det rd
    where rd.regapuricmsmod9_id in (select ra.id
                                      from reg_apur_icms_mod9 ra
                                     where ra.apuracaoicms_id = gt_row_apuracao_icms.id);
   --
   vn_fase := 2;
   -- Limpar os dados das tabelas de apura��o de modelo P9
   delete from reg_apur_icms_mod9 ra
    where ra.apuracaoicms_id = gt_row_apuracao_icms.id;
   --
   vn_fase := 3;
   --
   commit;
   --
exception
   when others then
      --
      gv_resumo_log := 'Erro na pk_apur_icms.pkb_limpa_reg_modp9 fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_resumo_log);
      --
end pkb_limpa_reg_modp9;

-------------------------------------------------------------------------------------------------------
--| Procedimento para montar os dados do livro de apura��o de ICMS Modelo P9
procedure pkb_monta_apur_modp9
is
   --
   vn_fase number := 0;
   --
begin
   --
   vn_fase := 1;
   -- limpa os dados
   pkb_limpa_reg_modp9;
   --
   vn_fase := 2;
   -- monta o registro de apura��o de icms do livro modelo P9
   pkb_monta_reg_modp9;
   --
exception
   when others then
      --
      gv_resumo_log := 'Erro na pk_apur_icms.pkb_monta_apur_modp9 fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_resumo_log);
      --
end pkb_monta_apur_modp9;

-------------------------------------------------------------------------------------------------------
--| Procedimento para cria��o do registro 1900 para sub-apura��o do icms
procedure pkb_cria_sub_apur( est_log_generico in out nocopy dbms_sql.number_table )
is
   --
   vn_fase             number := 0;
   vn_loggenerico_id   log_generico.id%type;
   vn_dm_ind_apur_icms number := 0;
   vv_descr_compl      subapur_icms.descr_compl%type;
   --
   cursor c_dados is
      select substr(cod.cod_aj,3,2) cod_aj
           , nvl(sum(ipdf.vl_icms),0) vl_icms
        from nota_fiscal            nf
           , sit_docto              sd
           , mod_fiscal             mf
           , nfinfor_fiscal         nfi
           , inf_prov_docto_fiscal  ipdf
           , cod_ocor_aj_icms       cod
       where nf.empresa_id        = gt_row_apuracao_icms.empresa_id
         and nf.dm_st_proc        = 4 -- 4-autorizada
         and nf.dm_arm_nfe_terc   = 0 -- N�o � nota de armazenamento fiscal
         and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
               or
              (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
               or
              (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
               or
              (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
         and sd.id                = nf.sitdocto_id
         and sd.cd           not in ('01', '07') -- extempor�neos
         and mf.id                = nf.modfiscal_id
         and mf.cod_mod          in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
         and nfi.notafiscal_id    = nf.id
         and ipdf.nfinforfisc_id  = nfi.id
         and cod.id               = ipdf.codocorajicms_id
         and cod.dm_reflexo_apur in (2,5) -- reflexo na apura��o do icms: 2-C-Estorno de D�bito, 5-D-Estorno de Cr�dito
         and cod.dm_tipo_apur    in (3,4,5,6,7,8) -- tipo de apura��o: 3-Apura��o 1, 4-Apura��o 2, 5-Apura��o 3, 6-Apura��o 4, 7-Apura��o 5, 8-Apura��o 6
       group by substr(cod.cod_aj,3,2)
       order by substr(cod.cod_aj,3,2);
   --
begin
   --
   vn_fase := 1;
   --
   for r_reg in c_dados
   loop
      --
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      vn_fase := 2;
      --
      if r_reg.cod_aj in ('23','53') then
         vn_dm_ind_apur_icms := 3;
      elsif r_reg.cod_aj in ('24','54') then
            vn_dm_ind_apur_icms := 4;
      elsif r_reg.cod_aj in ('25','55') then
            vn_dm_ind_apur_icms := 5;
      elsif r_reg.cod_aj in ('26','56') then
            vn_dm_ind_apur_icms := 6;
      elsif r_reg.cod_aj in ('27','57') then
            vn_dm_ind_apur_icms := 7;
      elsif r_reg.cod_aj in ('28','58') then
            vn_dm_ind_apur_icms := 8;
      else
         vn_dm_ind_apur_icms := 0;
      end if;
      --
      vn_fase := 3;
      --
      vv_descr_compl := pk_csf.fkg_dominio( ev_dominio => 'SUBAPUR_ICMS.DM_IND_APUR_ICMS'
                                          , ev_vl      => vn_dm_ind_apur_icms );
      --
      vn_fase := 4;
      --
      if nvl(vn_dm_ind_apur_icms,0) <> 0 then
         --
         vn_fase := 5;
         --
         begin
            insert into subapur_icms( id
                                    , empresa_id
                                    , dm_situacao
                                    , dt_ini
                                    , dt_fin
                                    , dm_ind_apur_icms
                                    , descr_compl
                                    , vl_tot_transf_debitos_oa
                                    , vl_tot_aj_debitos_oa
                                    , vl_estornos_cred_oa
                                    , vl_tot_transf_creditos_oa
                                    , vl_tot_aj_creditos_oa
                                    , vl_estornos_deb_oa
                                    , vl_sld_credor_ant_oa
                                    , vl_sld_apurado_oa
                                    , vl_tot_ded
                                    , vl_icms_recolher_oa
                                    , vl_sld_credor_transp_oa
                                    , vl_deb_esp_oa
                                    )
                              values( subapuricms_seq.nextval         -- id
                                    , gt_row_apuracao_icms.empresa_id -- empresa_id
                                    , 0                               -- dm_situacao
                                    , gt_row_apuracao_icms.dt_inicio  -- dt_ini
                                    , gt_row_apuracao_icms.dt_fim     -- dt_fin
                                    , vn_dm_ind_apur_icms             -- dm_ind_apur_icms
                                    , vv_descr_compl                  -- descr_compl
                                    , 0  -- vl_tot_transf_debitos_oa
                                    , 0  -- vl_tot_aj_debitos_oa
                                    , 0  -- vl_estornos_cred_oa
                                    , 0  -- vl_tot_transf_creditos_oa
                                    , 0  -- vl_tot_aj_creditos_oa
                                    , 0  -- vl_estornos_deb_oa
                                    , 0  -- vl_sld_credor_ant_oa
                                    , 0  -- vl_sld_apurado_oa
                                    , 0  -- vl_tot_ded
                                    , 0  -- vl_icms_recolher_oa
                                    , 0  -- vl_sld_credor_transp_oa
                                    , 0  -- vl_deb_esp_oa
                                    );
         exception
            when dup_val_on_index then
               null;
            when others then
               --
               gv_resumo_log := 'Problemas ao incluir sub-apura��o de icms. Erro = '||sqlerrm;
               --
               vn_loggenerico_id := null;
               --
               pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                           , ev_mensagem       => gv_mensagem_log
                                           , ev_resumo         => gv_resumo_log
                                           , en_tipo_log       => erro_de_validacao
                                           , en_referencia_id  => gn_referencia_id
                                           , ev_obj_referencia => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na mem�ria
               pk_log_generico.pkb_gt_log_generico ( en_loggenerico   => vn_loggenerico_id
                                              , est_log_generico => est_log_generico );
               --
         end;
         --
      end if;
      --
      vn_fase := 6;
      --
      commit;
      --
   end loop;
   --
exception
   when others then
      --
      gv_resumo_log := 'Erro na pk_apur_icms.pkb_cria_sub_apur fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_resumo_log);
      --
end pkb_cria_sub_apur;

-------------------------------------------------------------------------------------------------------
--| Valida os dados a Apura��o de ICMS
procedure pkb_validar_dados ( est_log_generico  in out nocopy  dbms_sql.number_table )
is
   --
   vn_fase                      number := 0;
   vn_loggenerico_id            log_generico.id%type;
   vn_vl_total_debito           apuracao_icms.vl_total_debito%type     := 0;
   vn_soma_aj_debito            apuracao_icms.vl_ajust_debito%type     := 0;
   vn_soma_tot_aj_debitos       apuracao_icms.vl_total_ajust_deb%type  := 0;
   vn_soma_estornos_cred        apuracao_icms.vl_estorno_credito%type  := 0;
   vn_vl_total_credito          apuracao_icms.vl_total_credito%type    := 0;
   vn_soma_aj_credito           apuracao_icms.vl_ajust_credito%type    := 0;
   vn_soma_tot_aj_credito       apuracao_icms.vl_total_ajust_cred%type := 0;
   vn_soma_estorno_deb          apuracao_icms.vl_estorno_debido%type   := 0;
   vn_vl_saldo_credor_ant       apuracao_icms.vl_saldo_credor_ant%type := 0;
   vn_vl_saldo_apurado          apuracao_icms.vl_saldo_apurado%type    := 0;
   vn_vl_saldo_credor_transp    apuracao_icms.vl_saldo_credor_ant%type := 0;
   vn_vl_total_deducao          apuracao_icms.vl_total_deducao%type    := 0;
   vn_vl_icms_recolher          apuracao_icms.vl_icms_recolher%type    := 0;
   vn_vl_deb_esp                apuracao_icms.vl_deb_esp%type          := 0;
   vn_vl_orig_rec               obrig_rec_apur_icms.vl_orig_rec%type   := 0;
   vn_vl_aj_apur_gia            ajust_apur_icms_gia.vl_aj_apur%type    := 0;
   vv_resumo_log                log_generico.resumo%type               := null;
   vd_data                      date                                   := null;
   vn_qtde                      number                                 := 0;
   --
   cursor c_aj_apur is
      select ai.id ajustapuracaoicms_id
           , ai.codajsaldoapuricms_id
           , nvl(sum(nvl(ai.vl_aj_apur,0)),0) vl_aj_apur
        from ajust_apuracao_icms ai
       where ai.apuracaoicms_id = gt_row_apuracao_icms.id
       group by ai.id
           , ai.codajsaldoapuricms_id;
   --
   cursor c_aj_gia( en_ajustapuracaoicms_id in ajust_apuracao_icms.id%type ) is
      select nvl(sum(nvl(ag.vl_aj_apur,0)),0) vl_aj_apur_gia
        from ajust_apur_icms_gia ag
       where ag.ajustapuracaoicms_id = en_ajustapuracaoicms_id;
   --
   cursor c_ajust_rj is
      select sg.cd
           , aa.compl_dados_1
           , aa.compl_dados_2
           , aa.compl_dados_3
        from ajust_apuracao_icms ai
           , ajust_apur_icms_gia aa
           , subitem_gia         sg
       where ai.apuracaoicms_id      = gt_row_apuracao_icms.id
         and aa.ajustapuracaoicms_id = ai.id
         and sg.id                   = aa.subitemgia_id;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(gt_row_apuracao_icms.empresa_id, 0) > 0
      and trunc(gt_row_apuracao_icms.dt_inicio) is not null
      and trunc(gt_row_apuracao_icms.dt_fim) is not null then
      --
      vn_fase := 2;
      --  Re-calcula o Vlr. Total do D�bito
      vn_vl_total_debito := nvl(fkg_som_vl_icms_c190_c590_d590,0) +
                            nvl(fkg_soma_vl_icms_c320,0) +
                            nvl(fkg_soma_vl_icms_c390,0) +
                            nvl(fkg_soma_vl_icms_c490_d390,0) +
                            nvl(fkg_soma_vl_icms_c690,0) +
                            nvl(fkg_soma_vl_icms_c790,0) +
                            nvl(fkg_soma_vl_icms_c800,0) +
                            nvl(fkg_soma_vl_icms_d190,0) +
                            nvl(fkg_soma_vl_icms_d300,0) +
                            nvl(fkg_soma_vl_icms_d410,0) +
                            nvl(fkg_soma_vl_icms_d690,0) +
                            nvl(fkg_soma_vl_icms_d696,0);
      --
      vn_fase := 3;
      --
      -- Valida��o: Compara o Vlr do D�bito total na apura��o de icms
      -- com a soma dos valores de icms nos doc. fiscais.
      if nvl(gt_row_apuracao_icms.vl_total_debito,0) <> nvl(vn_vl_total_debito, 0) then
         --
         vn_fase := 3.1;
         --
         gv_resumo_log := 'O "Valor de total dos d�bitos por Sa�das e presta��es com d�bito de imposto" na Apura��o do ICMS ('||
                          trim(to_char(nvl(gt_row_apuracao_icms.vl_total_debito,0),'9999G999G999G990D00'))||') est� divergente da "Soma dos Valor do ICMS '||
                          'nos Documentos Fiscais referente aos d�bitos" ('||trim(to_char(nvl(vn_vl_total_debito,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_VALIDACAO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 4;
      --  Re-calcula Vlr Dos Ajuste a D�bito decorrentes do doc. fiscal
      vn_soma_aj_debito := nvl(fkg_soma_aj_debito, 0);
      --
      vn_fase := 4.1;
      -- Valida��o: Compara o Vlr do D�bito Ajuste a d�bitos do ICMS decorrentes do doc. fiscal
      -- com a soma dos valores de icms nos doc. fiscais referentes a essa opera��o.
      if nvl(gt_row_apuracao_icms.vl_ajust_debito,0) <> nvl(vn_soma_aj_debito, 0) then
         --
         vn_fase := 4.2;
         --
         gv_resumo_log := 'O "Valor total dos ajustes a d�bito decorrentes do documento fiscal" na Apura��o do ICMS ('||
                          trim(to_char(nvl(gt_row_apuracao_icms.vl_ajust_debito,0),'9999G999G999G990D00'))||') est� divergente da "Soma dos Documentos Fiscais '||
                          'referente aos Ajustes a d�bitos do ICMS" ('||trim(to_char(nvl(vn_soma_aj_debito,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_VALIDACAO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 5;
      -- Re-calcula valor dos Ajustes a D�bitos
      vn_soma_tot_aj_debitos := nvl(fkg_soma_tot_aj_debitos, 0);
      --
      vn_fase := 5.1;
      -- Valida��o: Compara o Vlr Tot. dos Ajuste a debitos na Apura��o de ICMS
      -- com os Vlrs de Icms Lan�ados na tabela de Ajuste de D�bitos.
      if nvl(gt_row_apuracao_icms.vl_total_ajust_deb,0) <> nvl(vn_soma_tot_aj_debitos, 0) then
         --
         vn_fase := 5.2;
         --
         gv_resumo_log := 'O "Valor total de Ajustes a D�bito" na Apura��o do ICMS ('||
                          trim(to_char(nvl(gt_row_apuracao_icms.vl_total_ajust_deb,0),'9999G999G999G990D00'))||') est� divergente da "Soma dos lan�amentos '||
                          'de Ajustes a d�bitos do ICMS" ('||trim(to_char(nvl(vn_soma_tot_aj_debitos,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_VALIDACAO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 6;
      --  Re-calcula Vlr de Estorno de Credito
      vn_soma_estornos_cred := nvl(fkg_soma_estornos_cred, 0);
      --
      vn_fase := 6.1;
      -- Valida��o: Compara o Vlr Tot. dos Ajuste "A Estorno de cr�ditos " com a soma
      -- dos lan�amentos de "Estornos de Cr�ditos".
      if nvl(gt_row_apuracao_icms.vl_estorno_credito,0) <> nvl(vn_soma_estornos_cred, 0) then
         --
         vn_fase := 6.2;
         --
         gv_resumo_log := 'O "Valor total de ajustes Estornos de Cr�ditos" na Apura��o do ICMS ('||
                          trim(to_char(nvl(gt_row_apuracao_icms.vl_estorno_credito,0),'9999G999G999G990D00'))||') est� divergente da "Soma dos lan�amentos '||
                          'de Ajustes a Estornos de Cr�ditos" ('||trim(to_char(nvl(vn_soma_estornos_cred,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_VALIDACAO
                                     , en_referencia_id   => gn_referencia_id
                                    , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 7;
      -- Re-Calculo do Valor Total de Cr�dito:
      --| Nada mais � do que a soma das quatro fun��es descritas abaixo.
      vn_vl_total_credito := ( nvl(fkg_tot_cred_c190_c590_d590, 0) + nvl(fkg_totcredc190_c590_d590_5605, 0) ) +
                             ( nvl(fkg_tot_cred_d190,0) + nvl(fkg_tot_cred_d190_5605, 0) );
      --
      vn_fase := 7.1;
      --
      -- Valida��o: Compara o Vlr Tot. de Cr�dito da Apura��o de ICMS com a soma do vlr. de icms
      -- nos Doc. Fiscais referente ao cr�dito.
      if nvl(gt_row_apuracao_icms.vl_total_credito,0) <> nvl(vn_vl_total_credito, 0) then
         --
         vn_fase := 7.2;
         --
         gv_resumo_log := 'O "Valor total dos cr�ditos por Entradas a aquisi��es com cr�dito do imposto" na Apura��o do ICMS ('||
                          trim(to_char(nvl(gt_row_apuracao_icms.vl_total_credito,0),'9999G999G999G990D00'))||') est� divergente da "Soma do Valor de ICMS '||
                          'nos Documentos Fiscais referente ao cr�dito" ('||trim(to_char(nvl(vn_vl_total_credito,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_VALIDACAO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 8;
      -- Re-calcula Vlr. de Ajuste de cr�dito decorrente de doc. fiscal
      vn_soma_aj_credito := nvl(fkg_soma_aj_credito, 0);
      --
      vn_fase := 8.1;
      -- Valida��o: Compara o Vlr. Total dos Ajustes a cr�dito decorrentes do Doc. Fiscal
      -- na Apura��o de ICMS com a soma do Vlr de ICMS nos doc. fiscais correspondentes
      if nvl(gt_row_apuracao_icms.vl_ajust_credito,0) <> nvl(vn_soma_aj_credito, 0) then
         --
         vn_fase := 8.2;
         --
         gv_resumo_log := 'O "Valor total dos ajustes a cr�ditos decorrentes do documento fiscal" na Apura��o do ICMS ('||
                          trim(to_char(nvl(gt_row_apuracao_icms.vl_ajust_credito,0),'9999G999G999G990D00'))||') est� divergente da "Soma dos Valores do ICMS '||
                          'nos Documentos Fiscais referentes a Ajuste a Cr�dito" ('||trim(to_char(nvl(vn_soma_aj_credito,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_VALIDACAO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 9;
      -- Re-calcula Vlr. do Lanc. de Ajustes a Cr�dito
      vn_soma_tot_aj_credito := nvl(fkg_soma_tot_aj_credito, 0);
      --
      vn_fase := 9.1;
      -- Valida��o: Compara o Vlr. Total dos Ajustes a cr�dito
      -- na Apura��o de ICMS com Lancamentos de Ajuste a Cr�dito.
      if nvl(gt_row_apuracao_icms.vl_total_ajust_cred,0) <> nvl(vn_soma_tot_aj_credito, 0) then
         --
         vn_fase := 9.2;
         --
         gv_resumo_log := 'O "Valor total dos Ajustes a Cr�dito" na Apura��o do ICMS ('||
                          trim(to_char(nvl(gt_row_apuracao_icms.vl_total_ajust_cred,0),'9999G999G999G990D00'))||') est� divergente da "Soma dos Lan�amentos '||
                          'de Ajuste a Cr�dito" ('||trim(to_char(nvl(vn_soma_tot_aj_credito,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_VALIDACAO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 10;
      -- Re-calcula vlr do estorno de debito
      vn_soma_estorno_deb := nvl(fkg_soma_estorno_deb, 0);
      --
      vn_fase := 10.1;
      -- Valida��o: Compara o Vlr Tot. dos "Estorno de D�bitos" com a soma
      -- dos lan�amentos de "Estorno de D�bitos".
      if nvl(gt_row_apuracao_icms.vl_estorno_debido,0) <> nvl(vn_soma_estorno_deb, 0) then
         --
         vn_fase := 10.2;
         --
         gv_resumo_log := 'O "Valor total de Ajustes Estorno de D�bitos" na Apura��o do ICMS ('||
                          trim(to_char(nvl(gt_row_apuracao_icms.vl_total_ajust_cred,0),'9999G999G999G990D00'))||') est� divergente da "Soma dos lan�amentos '||
                          'de Ajustes Estornos de D�bitos" ('||trim(to_char(nvl(vn_soma_estorno_deb,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_VALIDACAO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 11;
      --
      -- Busca o C�lculo do Valor Credor Anterior
      vn_vl_saldo_credor_ant := nvl(fkg_saldo_credor_ant, 0);
      --
      vn_fase := 11.1;
      -- Valida��o: S� faz a valida��o se o Valor do Cr�dito Anterior n�o foi inserido manualmente,
      -- ou seja, Se o Valor de Cr�dito � maior que zero tanto na Apura��o do ICMS
      -- quanto no c�lculo do m�s anterior.
      if nvl(gt_row_apuracao_icms.vl_saldo_credor_ant,0) > 0 and
         vn_vl_saldo_credor_ant > 0 and
         ( nvl(gt_row_apuracao_icms.vl_saldo_credor_ant,0) <> nvl(vn_vl_saldo_credor_ant, 0) ) then
         --
         vn_fase := 11.2;
         --
         gv_resumo_log := 'O "Valor total de Saldo credor per�odo anterior" na Apura��o do ICMS ('||
                          trim(to_char(nvl(gt_row_apuracao_icms.vl_saldo_credor_ant,0),'9999G999G999G990D00'))||') est� divergente da "C�lculo do Valor '||
                          'Credor do M�s Anterior" ('||trim(to_char(nvl(vn_vl_saldo_credor_ant,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_VALIDACAO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 12;
      -- Re-calcula o Valor Apurado.
      -- Se o Vlr do Saldo Anterior n�o foi inserido utiliza o Vlr Credor Anterior Calculado. Caso contr�rio,
      -- utiliza o valor inserido na Apura��o Manualmente.
      vn_vl_saldo_apurado := ( nvl(vn_vl_total_debito, 0)
                             + nvl(vn_soma_aj_debito, 0)
                             + nvl(vn_soma_tot_aj_debitos, 0)
                             + nvl(vn_soma_estornos_cred, 0) )
                           - ( nvl(vn_vl_total_credito, 0)
                             + nvl(vn_soma_aj_credito, 0)
                             + nvl(vn_soma_tot_aj_credito, 0)
                             + nvl(vn_soma_estorno_deb, 0)
                             + ( case when nvl(gt_row_apuracao_icms.vl_saldo_credor_ant, 0) = vn_vl_saldo_credor_ant then
                                           nvl(vn_vl_saldo_credor_ant, 0)
                                      else
                                           nvl(gt_row_apuracao_icms.vl_saldo_credor_ant, 0)
                                 end ) );
      --
      vn_fase := 12.1;
      -- Seta Valores nas v�riaveis de saldo e credor a transporta
      if nvl(vn_vl_saldo_apurado, 0) < 0 then
         --
         vn_vl_saldo_credor_transp := nvl(vn_vl_saldo_apurado, 0) * (-1);
         vn_vl_saldo_apurado := 0;
         --
      else
         --
         vn_vl_saldo_credor_transp := 0;
         --
      end if;
      --
      vn_fase := 12.2;
      -- Valida��o: Compara o Vlr do Saldo Apurado na Apura��o de ICMS com
      -- o Vlr do Saldo Calculado
      if nvl(gt_row_apuracao_icms.vl_saldo_apurado,0) <> nvl(vn_vl_saldo_apurado, 0)  then
         --
         vn_fase := 12.3;
         --
         gv_resumo_log := 'O "Valor do saldo devedor apurado" na Apura��o do ICMS ('||trim(to_char(nvl(gt_row_apuracao_icms.vl_saldo_apurado,0),'9999G999G999G990D00'))||
                          ') est� divergente da "C�lculo do Saldo Apurado" ('||trim(to_char(nvl(vn_vl_saldo_apurado,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_VALIDACAO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 13;
      -- Re-calcula o vlr da Dedu��o
      vn_vl_total_deducao := nvl(fkg_soma_tot_ded_c197, 0) + nvl(fkg_soma_tot_ded_e111, 0);
      --
      vn_fase := 13.1;
      -- Valida��o: Compara o Vlr da Dedu��o na Apura��o de ICMS com
      -- o Vlr Total da Dedu��o Calculada
      if ( nvl(gt_row_apuracao_icms.vl_total_deducao,0) <> nvl(vn_vl_total_deducao, 0) ) then
         --
         vn_fase := 13.2;
         --
         gv_resumo_log := 'O "Valor total de dedu��es" na Apura��o do ICMS ('||trim(to_char(nvl(gt_row_apuracao_icms.vl_total_deducao,0),'9999G999G999G990D00'))||
                          ') est� divergente da "Soma das Dedu��es" no per�odo ('||trim(to_char(nvl(vn_vl_total_deducao,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_VALIDACAO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 14;
      -- Re-calculo do Vlr de ICMS a Recolher
      vn_vl_icms_recolher := nvl(vn_vl_saldo_apurado, 0) - nvl(vn_vl_total_deducao, 0);
      --
      vn_fase := 14.1;
      --
      if nvl(vn_vl_icms_recolher,0) < 0 then
         --
         --vn_vl_icms_recolher := 0;
         --
         vn_vl_saldo_credor_transp := nvl(vn_vl_saldo_credor_transp,0)
                                      + (nvl(vn_vl_icms_recolher,0) * (-1));
         --
         vn_vl_icms_recolher := 0;                             
         --
      end if;
      --
      vn_fase := 14.2;
      --
      -- Valida��o: Compara o Vlr de ICMS a Recolher na Apura��o de ICMS com
      -- o Vlr ICMS a Recolher C�lculado
      if ( nvl(gt_row_apuracao_icms.vl_icms_recolher,0) <> nvl(vn_vl_icms_recolher, 0) ) then
         --
         vn_fase := 14.3;
         --
         gv_resumo_log := 'O "Valor total do ICMS a recolher" na Apura��o do ICMS ('||trim(to_char(nvl(gt_row_apuracao_icms.vl_icms_recolher,0),'9999G999G999G990D00'))||
                          ') est� divergente do "C�lculo do ICMS a Recolher" no per�odo ('||trim(to_char(nvl(vn_vl_icms_recolher,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_VALIDACAO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 15;
      --
      -- Valida��o: Compara o Vlr do Saldo Credor a Transp. na Apura��o de ICMS com
      -- o Vlr do Saldo Credor C�lculado.
      if ( nvl(gt_row_apuracao_icms.vl_saldo_credor_transp,0) <> nvl(vn_vl_saldo_credor_transp, 0) ) then
         --
         vn_fase := 15.1;
         --
         gv_resumo_log := 'O "Valor do total de Saldo credor a transportar para o per�odo seguinte" na Apura��o do ICMS ('||
                          trim(to_char(nvl(gt_row_apuracao_icms.vl_saldo_credor_transp,0),'9999G999G999G990D00'))||') est� divergente do "C�lculo do Saldo '||
                          'Credor" no per�odo ('||trim(to_char(nvl(vn_vl_saldo_credor_transp,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_VALIDACAO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 16;
      -- Re-Calcula Valores Recolhidos ou a recolher extra-apura��o.
      vn_vl_deb_esp := nvl(fkg_soma_cred_ext_op_c,0)
                       + nvl(fkg_soma_cred_ext_op_d,0)
                       + nvl(fkg_soma_dep_esp_c197_d197,0)
                       + nvl(fkg_soma_dep_esp_e111,0);
      vn_fase := 16.1;
      -- Valida��o: Compara o Vlr de Extra-apura��o na Apura��o de ICMS com
      -- o Vlr de Extra-apura��o C�lculado.
      if ( nvl(gt_row_apuracao_icms.vl_deb_esp,0) <> nvl(vn_vl_deb_esp, 0) ) then
         --
         vn_fase := 16.2;
         --
         gv_resumo_log := 'O "Valor recolhidos ou a recolher, extra-apura��o" na Apura��o do ICMS ('||
                          trim(to_char(nvl(gt_row_apuracao_icms.vl_deb_esp,0),'9999G999G999G990D00'))||') est� divergente do "C�lculo dos Valores Recolhidos '||
                          'ou a recolher, extra-apura��o" no per�odo ('||trim(to_char(nvl(vn_vl_deb_esp,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_VALIDACAO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 17;
      --
      -- Busca o valor da obriga��o a recolher
      Begin
         select sum(v.vl_orig_rec)
           into vn_vl_orig_rec
           from obrig_rec_apur_icms v
          where v.apuracaoicms_id = gt_row_apuracao_icms.id;
      exception
         when others then
            vn_vl_orig_rec := 0;
      end;
      --
      vn_fase := 17.1;
      -- Valida��o: Verifica se as obriga��es de imposto a recolher foram lan�adas
      -- corretamente com o valor de icms a recolher na apura��o de icms.
      if ( nvl(gt_row_apuracao_icms.vl_icms_recolher, 0)
           + nvl(gt_row_apuracao_icms.vl_deb_esp, 0) ) <> nvl(vn_vl_orig_rec, 0) then
         --
         vn_fase := 17.2;
         --
         gv_resumo_log := 'O "Valor da Obriga��o a recolher" em Obriga��es de ICMS a Recolher ('||trim(to_char(nvl(vn_vl_orig_rec,0),'9999G999G999G990D00'))||
                          ') est� divergente do c�lculo: "Valor total do ICMS a recolher" mais "Valor recolhidos ou a recolher, extra-apura��o", na Apura��o de '||
                          'ICMS ('||trim(to_char((nvl(gt_row_apuracao_icms.vl_icms_recolher,0) + nvl(gt_row_apuracao_icms.vl_deb_esp,0)),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_VALIDACAO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 18;
      -- Caso exista registro na tabela "AJUST_APUR_ICMS_GIA", a soma dos valores deve ser igual ao campo VL_AJ_APUR da tabela AJUST_APURACAO_ICMS
      for r_aj_apur in c_aj_apur
      loop
         --
         exit when c_aj_apur%notfound or (c_aj_apur%notfound) is null;
         --
         vn_fase := 18.1;
         --
         open c_aj_gia(en_ajustapuracaoicms_id => r_aj_apur.ajustapuracaoicms_id);
         fetch c_aj_gia into vn_vl_aj_apur_gia;
         close c_aj_gia;
         --
         vn_fase := 18.2;
         --
         if nvl(vn_vl_aj_apur_gia,0) > 0 and
            nvl(r_aj_apur.vl_aj_apur,0) <> nvl(vn_vl_aj_apur_gia,0) then
            --
            vn_fase := 18.3;
            --
            gv_resumo_log := 'C�digo de Ajuste da Apura��o = '||pk_csf_efd.fkg_cod_codajsaldoapuricms(r_aj_apur.codajsaldoapuricms_id)||'. O Valor de '||
                             'ajuste ('||trim(to_char(nvl(r_aj_apur.vl_aj_apur,0),'9999G999G999G990D00'))||'), est� diferente do Valor de ajuste referente '||
                             'a GIA ('||trim(to_char(nvl(vn_vl_aj_apur_gia,0),'9999G999G999G990D00'))||').';
            --
            vn_loggenerico_id := null;
            --
            pk_log_generico.pkb_log_generico( sn_loggenerico_id => vn_loggenerico_id
                                       , ev_mensagem       => gv_mensagem_log
                                       , ev_resumo         => gv_resumo_log
                                       , en_tipo_log       => erro_de_validacao
                                       , en_referencia_id  => gn_referencia_id
                                       , ev_obj_referencia => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na mem�ria
            pk_log_generico.pkb_gt_log_generico( en_loggenerico   => vn_loggenerico_id
                                          , est_log_generico => est_log_generico );
            --
         end if;
         --
      end loop;
      --
      vn_fase := 19;
      -- Se a empresa relacionada a abertura da GIA pertence ao estado do Rio de Janeiro, os campos Complementares relacionados ao Ajuste devem ser validados.
      if gv_ibge_estado = '33' then -- Estado do Rio de Janeiro
         --
         vn_fase := 19.1;
         vv_resumo_log := null;
         --
         for r_ajust_rj in c_ajust_rj
         loop
            --
            exit when c_ajust_rj%notfound or (c_ajust_rj%notfound) is null;
            --
            vn_fase := 19.2;
            --
            if r_ajust_rj.cd in ('N029999', 'N039999', 'N079999', 'N089999', 'N149999', 'N309999', 'S029999', 'S039999', 'S079999', 'S089999', 'S149999', 'S309999') then
               --
               vn_fase := 19.3;
               --
               if trim(r_ajust_rj.compl_dados_1) is null or
                  trim(r_ajust_rj.compl_dados_2) is null then
                  --
                  vn_fase := 19.4;
                  --
                  vv_resumo_log := 'Para os c�digos de Sub-Item: "N029999", "N039999", "N079999", "N089999", "N149999", "N309999", "S029999", "S039999", '||
                                   '"S079999", "S089999", "S149999", ou "S309999"; devem ser informados valores para os campos: "Complemento Dados 1" como '||
                                   'sendo a "Descri��o da Ocorr�ncia", e "Complemento Dados 2" como sendo a "Legisla��o Tribut�ria". Verifique na aba '||
                                   '"Ocorr�ncia GIA" relacionada com a aba "Ajuste/Benef�cio/Incentivo".';
                  --
               end if;
               --
               vn_fase := 19.5;
               --
               if trim(r_ajust_rj.compl_dados_3) is not null then
                  --
                  vn_fase := 19.6;
                  --
                  vv_resumo_log := 'Para os c�digos de Sub-Item: "N029999", "N039999", "N079999", "N089999", "N149999", "N309999", "S029999", "S039999", '||
                                   '"S079999", "S089999", "S149999", ou "S309999"; n�o deve ser informado valor para o campo: "Complemento Dados 3". '||
                                   'Verifique na aba "Ocorr�ncia GIA" relacionada com a aba "Ajuste/Benef�cio/Incentivo".';
                  --
               end if;
               --
            elsif r_ajust_rj.cd in ('N140001', 'N140002', 'N140005', 'N140006') then
                  --
                  vn_fase := 19.7;
                  --
                  if trim(r_ajust_rj.compl_dados_1) is null or
                     trim(r_ajust_rj.compl_dados_2) is null then
                     --
                     vn_fase := 19.8;
                     --
                     vv_resumo_log := 'Para os c�digos de Sub-Item: "N140001", "N140002", "N140005", ou "N140006"; devem ser informados valores para os '||
                                      'campos: "Complemento Dados 1" como sendo o "N�mero do Banco", e "Complemento Dados 2" como sendo a "Data de Pagamento" '||
                                      '(formato: ddmmrrrr). Verifique na aba "Ocorr�ncia GIA" relacionada com a aba "Ajuste/Benef�cio/Incentivo".';
                     --
                  end if;
                  --
                  vn_fase := 19.9;
                  --
                  if trim(r_ajust_rj.compl_dados_2) is not null then
                     --
                     vn_fase := 19.10;
                     --
                     begin
                        vd_data := r_ajust_rj.compl_dados_2;
                     exception
                        when others then
                           vv_resumo_log := 'Para os c�digos de Sub-Item: "N140001", "N140002", "N140005", ou "N140006"; deve ser informado valor para o '||
                                            'campo: "Complemento Dados 2" como sendo a "Data de Pagamento" no formato: ddmmrrrr. Verifique na aba "Ocorr�ncia '||
                                            'GIA" relacionada com a aba "Ajuste/Benef�cio/Incentivo".';
                     end;
                     --
                  end if;
                  --
                  vn_fase := 19.11;
                  --
                  if trim(r_ajust_rj.compl_dados_3) is not null then
                     --
                     vn_fase := 19.12;
                     --
                     vv_resumo_log := 'Para os c�digos de Sub-Item: "N140001", "N140002", "N140005", ou "N140006"; n�o deve ser informado valor para o '||
                                      'campo: "Complemento Dados 3". Verifique na aba "Ocorr�ncia GIA" relacionada com a aba "Ajuste/Benef�cio/Incentivo".';
                     --
                  end if;
                  --
            elsif r_ajust_rj.cd in ('N070005', 'N070006', 'N140003', 'N140008', 'N140009') then
                  --
                  vn_fase := 19.13;
                  --
                  if trim(r_ajust_rj.compl_dados_1) is null then
                     --
                     vn_fase := 19.14;
                     --
                     vv_resumo_log := 'Para os c�digos de Sub-Item: "N070005", "N070006", "N140003", "N140008", ou "N140009"; deve ser informado valor para o '||
                                      'campo: "Complemento Dados 1" como sendo o "N�mero do Processo". Verifique na aba "Ocorr�ncia GIA" relacionada com a '||
                                      'aba "Ajuste/Benef�cio/Incentivo".';
                     --
                  end if;
                  --
                  vn_fase := 19.15;
                  --
                  if trim(r_ajust_rj.compl_dados_2) is not null or
                     trim(r_ajust_rj.compl_dados_3) is not null then
                     --
                     vn_fase := 19.16;
                     --
                     vv_resumo_log := 'Para os c�digos de Sub-Item: "N070005", "N070006", "N140003", "N140008", ou "N140009"; n�o devem ser informados valores '||
                                      'para os campos: "Complemento Dados 1" e "Complemento Dados 2". Verifique na aba "Ocorr�ncia GIA" relacionada com a '||
                                      'aba "Ajuste/Benef�cio/Incentivo".';
                     --
                  end if;
                  --
            elsif r_ajust_rj.cd in ('O350006') then
                  --
                  vn_fase := 19.17;
                  --
                  if trim(r_ajust_rj.compl_dados_1) is null or
                     trim(r_ajust_rj.compl_dados_2) is null or
                     trim(r_ajust_rj.compl_dados_3) is null then
                     --
                     vn_fase := 19.18;
                     --
                     vv_resumo_log := 'Para o c�digo de Sub-Item: "O350006"; devem ser informados valores para os campos: "Complemento Dados 1" como sendo '||
                                      'a "Data de In�cio do Per�odo" (formato: ddmmrrrr), "Complemento Dados 2" como sendo o "Tipo de Per�odo", e "Complemento '||
                                      'Dados 3" como sendo o valor da "Base de C�lculo". Verifique na aba "Ocorr�ncia GIA" relacionada com a aba "Ajuste/'||
                                      'Benef�cio/Incentivo".';
                     --
                  end if;
                  --
                  vn_fase := 19.19;
                  --
                  if trim(r_ajust_rj.compl_dados_1) is not null then
                     --
                     vn_fase := 19.20;
                     --
                     begin
                        vd_data := r_ajust_rj.compl_dados_1;
                     exception
                        when others then
                           vv_resumo_log := 'Para o c�digo de Sub-Item: "O350006"; deve ser informado valor para o campo: "Complemento Dados 1" como sendo a '||
                                            '"Data de In�cio do Per�odo" no formato: ddmmrrrr. Verifique na aba "Ocorr�ncia GIA" relacionada com a aba '||
                                            '"Ajuste/Benef�cio/Incentivo".';
                     end;
                     --
                  end if;
                  --
            elsif r_ajust_rj.cd in ('O350007', 'O350009') then
                  --
                  vn_fase := 19.21;
                  --
                  if trim(r_ajust_rj.compl_dados_1) is null or
                     trim(r_ajust_rj.compl_dados_2) is null or
                     trim(r_ajust_rj.compl_dados_3) is null then
                     --
                     vn_fase := 19.22;
                     --
                     vv_resumo_log := 'Para o c�digo de Sub-Item: "O350007", "O350009"; devem ser informados valores para os campos: "Complemento Dados 1" '||
                                      'como sendo a "Data do Desembara�o" (formato: ddmmrrrr), "Complemento Dados 2" como sendo o "Tipo de Declara��o de '||
                                      'Importa��o", e "Complemento Dados 3" como sendo o valor da "N�mero de Declara��o de Importa��o/Outros". Verifique na '||
                                      'aba "Ocorr�ncia GIA" relacionada com a aba "Ajuste/Benef�cio/Incentivo".';
                     --
                  end if;
                  --
                  vn_fase := 19.23;
                  --
                  if trim(r_ajust_rj.compl_dados_1) is not null then
                     --
                     vn_fase := 19.24;
                     --
                     begin
                        vd_data := r_ajust_rj.compl_dados_1;
                     exception
                        when others then
                           vv_resumo_log := 'Para o c�digo de Sub-Item: "O350007", "O350009"; deve ser informado valor para o campo: "Complemento Dados 1" '||
                                            'como sendo a "Data do Desembara�o" no formato: ddmmrrrr. Verifique na aba "Ocorr�ncia GIA" relacionada com a aba '||
                                            '"Ajuste/Benef�cio/Incentivo".';
                     end;
                     --
                  end if;
                  --
            elsif r_ajust_rj.cd in ('O350011', 'O350014') then
                  --
                  vn_fase := 19.25;
                  --
                  if trim(r_ajust_rj.compl_dados_1) is null or
                     trim(r_ajust_rj.compl_dados_2) is null then
                     --
                     vn_fase := 19.26;
                     --
                     vv_resumo_log := 'Para o c�digo de Sub-Item: "O350011", "O350014"; devem ser informados valores para os campos: "Complemento Dados 1" '||
                                      'como sendo a "Data de In�cio do Per�odo" (formato: ddmmrrrr), e "Complemento Dados 2" como sendo o "Tipo de Per�odo". '||
                                      'Verifique na aba "Ocorr�ncia GIA" relacionada com a aba "Ajuste/Benef�cio/Incentivo".';
                     --
                  end if;
                  --
                  vn_fase := 19.27;
                  --
                  if trim(r_ajust_rj.compl_dados_1) is not null then
                     --
                     vn_fase := 19.28;
                     --
                     begin
                        vd_data := r_ajust_rj.compl_dados_1;
                     exception
                        when others then
                           vv_resumo_log := 'Para o c�digo de Sub-Item: "O350011", "O350014"; deve ser informado valor para o campo: "Complemento Dados 1" '||
                                            'como sendo a "Data de In�cio do Per�odo" no formato: ddmmrrrr. Verifique na aba "Ocorr�ncia GIA" relacionada com '||
                                            'a aba "Ajuste/Benef�cio/Incentivo".';
                     end;
                     --
                  end if;
                  --
                  vn_fase := 19.29;
                  --
                  if trim(r_ajust_rj.compl_dados_3) is not null then
                     --
                     vn_fase := 19.30;
                     --
                     vv_resumo_log := 'Para o c�digo de Sub-Item: "O350011", "O350014"; n�o deve ser informado valor para o campo: "Complemento Dados 3". '||
                                      'Verifique na aba "Ocorr�ncia GIA" relacionada com a aba "Ajuste/Benef�cio/Incentivo".';
                     --
                  end if;
                  --
            elsif r_ajust_rj.cd in ('O350012', 'O350013') then
                  --
                  vn_fase := 19.31;
                  --
                  if trim(r_ajust_rj.compl_dados_1) is null then
                     --
                     vn_fase := 19.32;
                     --
                     vv_resumo_log := 'Para o c�digo de Sub-Item: "O350012", "O350013"; deve ser informado valor para o campo: "Complemento Dados 1" '||
                                      'como sendo uma "Descri��o da Ocorr�ncia". Verifique na aba "Ocorr�ncia GIA" relacionada com a aba "Ajuste/Benef�cio'||
                                      '/Incentivo".';
                     --
                  end if;
                  --
                  vn_fase := 19.33;
                  --
                  if trim(r_ajust_rj.compl_dados_2) is not null or
                     trim(r_ajust_rj.compl_dados_3) is not null then
                     --
                     vn_fase := 19.34;
                     --
                     vv_resumo_log := 'Para o c�digo de Sub-Item: "O350012", "O350013"; n�o devem ser informados valores para os campos: "Complemento Dados 2" '||
                                      'e "Complemento Dados 3". Verifique na aba "Ocorr�ncia GIA" relacionada com a aba "Ajuste/Benef�cio/Incentivo".';
                     --
                  end if;
                  --
            else
               -- Outros c�digos n�o devem permitir informa��es nos campos Complementares
               vn_fase := 19.35;
               --
               if trim(r_ajust_rj.compl_dados_1) is not null or
                  trim(r_ajust_rj.compl_dados_2) is not null or
                  trim(r_ajust_rj.compl_dados_3) is not null then
                  --
                  vn_fase := 19.36;
                  --
                  vv_resumo_log := 'Para o c�digo de Sub-Item informado, n�o � permitido informar dados nos campos Complementares: Dados 1, Dados 2, e/ou '||
                                   'Dados 3. Verifique na aba "Ocorr�ncia GIA" relacionada com a aba "Ajuste/Benef�cio/Incentivo".';
                  --
               end if;
               --
            end if;
            --
         end loop;
         --
         vn_fase := 19.37;
         --
         if vv_resumo_log is not null then
            --
            vn_fase := 19.38;
            --
            gv_resumo_log := vv_resumo_log;
            --
            vn_loggenerico_id := null;
            --
            pk_log_generico.pkb_log_generico( sn_loggenerico_id => vn_loggenerico_id
                                            , ev_mensagem       => gv_mensagem_log
                                            , ev_resumo         => gv_resumo_log
                                            , en_tipo_log       => erro_de_validacao
                                            , en_referencia_id  => gn_referencia_id
                                            , ev_obj_referencia => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na mem�ria
            pk_log_generico.pkb_gt_log_generico( en_loggenerico   => vn_loggenerico_id
                                               , est_log_generico => est_log_generico );
            --
         end if;
         --
      else -- Estado da empresa da abertura n�o � Rio de Janeiro
         --
         vn_fase := 19.39;
         --
         begin
            select count(*)
              into vn_qtde
              from ajust_apuracao_icms ai
                 , ajust_apur_icms_gia aa
             where ai.apuracaoicms_id      = gt_row_apuracao_icms.id
               and aa.ajustapuracaoicms_id = ai.id
               and ((aa.compl_dados_1 is not null)
                     or
                    (aa.compl_dados_2 is not null)
                     or
                    (aa.compl_dados_3 is not null));
         exception
            when others then
               vn_qtde := 1;
         end;
         --
         vn_fase := 19.40;
         --
         if nvl(vn_qtde,0) > 0 then
            --
            gv_resumo_log := 'A abertura do GIA pertence a uma empresa que n�o � do estado do Rio de Janeiro, portanto os campos Complementares Dados_1, '||
                             'Dados_2 e Dados_3, n�o devem ser preenchidos. Verificar na aba "Ocorr�ncia GIA" relacionada com a aba "Ajuste/Benef�cio/Incentivo".';
            --
            vn_loggenerico_id := null;
            --
            pk_log_generico.pkb_log_generico( sn_loggenerico_id => vn_loggenerico_id
                                            , ev_mensagem       => gv_mensagem_log
                                            , ev_resumo         => gv_resumo_log
                                            , en_tipo_log       => erro_de_validacao
                                            , en_referencia_id  => gn_referencia_id
                                            , ev_obj_referencia => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na mem�ria
            pk_log_generico.pkb_gt_log_generico( en_loggenerico   => vn_loggenerico_id
                                               , est_log_generico => est_log_generico );
            --
         end if;
         --
      end if;
      --
      vn_fase := 20;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      --
      gv_resumo_log := 'Erro na pk_apur_icms.pkb_validar_dados fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_validar_dados;

-------------------------------------------------------------------------------------------------------
--| Procedimento valida as informa��es da Apura��o de ICMS
procedure pkb_validar ( en_apuracaoicms_id in apuracao_icms.id%type )
is
   --
   vn_fase            number := 0;
   vt_log_generico    dbms_sql.number_table;
   vn_loggenerico_id  Log_Generico.id%TYPE;
   --
begin
   --
   vn_fase := 1;
   -- recupera os dados da apura��o de imposto
   pkb_dados_apuracao_icms ( en_apuracaoicms_id => en_apuracaoicms_id );
   --
   vn_fase := 2;
   --
   if nvl(gt_row_apuracao_icms.id,0) > 0 then
      --
      vn_fase := 3;
      -- Limpar os logs
      delete log_generico o
      where o.obj_referencia = gv_obj_referencia
        and o.referencia_id  = gt_row_apuracao_icms.id;
      --
      vn_fase := 4;
      --
      commit;
      --
      vn_fase := 5;
      -- Inicia processo de valida��o do ICMS
      pkb_validar_dados ( est_log_generico => vt_log_generico );
      --
      vn_fase := 6;
      --
      if nvl(vt_log_generico.count,0) <= 0 then
         --
         vn_fase := 7;
         -- Procedimento para montar os dados do livro de apura��o de ICMS Modelo P9
         pkb_monta_apur_modp9;
         --
      end if;
      --
      vn_fase := 8;
      --
      if nvl(vt_log_generico.count,0) <= 0 then
         --
         vn_fase := 9;
         -- Procedimento para cria��o do registro 1900 para sub-apura��o do icms
         pkb_cria_sub_apur( est_log_generico => vt_log_generico );
         --
      end if;
      --
      vn_fase := 10;
      --
      if nvl(vt_log_generico.count,0) <= 0 then
         --
         vn_fase := 11;
         -- Como n�o h� erros de valida��o ai limpa os caracteres numa �nica vez.
         pkb_limpa_caracteres_bloco_e ( en_apuracaoicms_id => gt_row_apuracao_icms.id);
         --
         vn_fase := 12;
         --  Atualiza status como processado
         update apuracao_icms set dm_situacao = 3
          where id = gt_row_apuracao_icms.id;
         --
         gv_resumo_log := 'Apura��o de ICMS Processada com sucesso!';
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => INFO_APUR_IMPOSTO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
      else
         --
         vn_fase := 13;
         --  Atualiza status de erros de valida��o
         update apuracao_icms set dm_situacao = 4
          where id = gt_row_apuracao_icms.id;
         --
         gv_resumo_log := 'C�lculo da Apura��o de ICMS possui erros de valida��o!';
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => INFO_APUR_IMPOSTO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
      end if;
      --
      vn_fase := 14;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_apur_icms.pkb_validar fase ( '||vn_fase||' ):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_apuracaoicms_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_validar;

-------------------------------------------------------------------------------------------------------
--| Procedimento desfaz a situa��o da Apura��o de ICMS e volta para seu anterior
procedure pkb_desfazer(en_apuracaoicms_id in apuracao_icms.id%type) is
  --
  vn_fase              number := 0;
  vv_descr_dm_situacao dominio.dominio%type;
  vn_loggenerico_id    log_generico.id%type;
  --
begin
  --
  vn_fase := 1;
  --
  -- Recupera os dados da apura��o de imposto
  pkb_dados_apuracao_icms(en_apuracaoicms_id => en_apuracaoicms_id);
  --
  vn_fase := 2;
  --
  if nvl(gt_row_apuracao_icms.id, 0) > 0 then
    --
    vn_fase := 3;
    --
    -- Limpar os logs
    delete log_generico o
     where o.obj_referencia = gv_obj_referencia
       and o.referencia_id  = gt_row_apuracao_icms.id;
    --
    vn_fase := 4;
    --
    -- Limpa os dados livro modelo 9
    pkb_limpa_reg_modp9;
    --
    vn_fase := 5;
    --
    -- Se o DM_SITUACAO = 4 "Erro de Valida��o" ou 3 "Processada", defaz para 1 "C�lculado"
    if gt_row_apuracao_icms.dm_situacao in (4, 3) then
      --
      vn_fase := 6;
      --
      update apuracao_icms
         set dm_situacao = 1
       where id          = gt_row_apuracao_icms.id;
      --
      vn_fase := 7;
      --
      vv_descr_dm_situacao := pk_csf.fkg_dominio(ev_dominio => 'APURACAO_ICMS.DM_SITUACAO',
                                                 ev_vl      => 1);
      --
    elsif gt_row_apuracao_icms.dm_situacao in (1, 2) then
      --
      vn_fase := 8;
      --
      -- Zera o valor da Obriga��o da Recolher com Receita 2167
      update obrig_rec_apur_icms
         set vl_orig_rec = 0
       where id in (select obr.id
                      from obrig_rec_apur_icms obr, 
                           aj_obrig_rec        aor,
                           cod_rec_uf          cru
                     where obr.apuracaoicms_id = gt_row_apuracao_icms.id
                       and cru.id           (+)= obr.codrecuf_id
                       and cru.cod_rec         = '2167'
                       and aor.id              = obr.ajobrigrec_id
                       and aor.cd              = '090');
      --
      vn_fase := 8.1;
      --
      -- Existe Desenvolve no per�odo?
      begin
        select *
          into gt_param_desenv_ba
          from param_desenv_ba
         where 1 = 1
           and empresa_id = gt_row_apuracao_icms.empresa_id
           and (dt_ini <= gt_row_apuracao_icms.dt_inicio and dt_fin >= gt_row_apuracao_icms.dt_fim);
      exception
        when dup_val_on_index then
          gt_param_desenv_ba := null;
          gv_mensagem_log    := 'Erro localizado mais de um par�metro ativo para o Desenvolve Bahia fase ( ' || vn_fase || ' ):' || sqlerrm;
          pk_log_generico.pkb_log_generico(sn_loggenerico_id => vn_loggenerico_id,
                                           ev_mensagem       => gv_mensagem_log,
                                           ev_resumo         => gv_mensagem_log,
                                           en_tipo_log       => ERRO_DE_SISTEMA,
                                           en_referencia_id  => gt_row_apuracao_icms.id,
                                           ev_obj_referencia => gv_obj_referencia);
        when others then
          gt_param_desenv_ba := null;
      end;
      --
      vn_fase := 8.2;
      --
      if gt_param_desenv_ba.id > 0 then
        --
        vn_fase := 8.21;
        --
        -- Remove anteriores se houver
        delete from infor_ajust_apur_icms
         where ajustapuracaoicms_id in (select id
                                          from ajust_apuracao_icms
                                         where apuracaoicms_id       = gt_row_apuracao_icms.id
                                           and codajsaldoapuricms_id = gt_param_desenv_ba.codajsaldoapuricms_id_deducao);
        --
        vn_fase := 8.22;
        --
        delete from ajust_apur_icms_gia
         where ajustapuracaoicms_id in (select id
                                          from ajust_apuracao_icms
                                         where apuracaoicms_id       = gt_row_apuracao_icms.id
                                           and codajsaldoapuricms_id = gt_param_desenv_ba.codajsaldoapuricms_id_deducao);
        --
        vn_fase := 8.23;
        --            
        delete from ajust_apuracao_icms
         where apuracaoicms_id       = gt_row_apuracao_icms.id
           and codajsaldoapuricms_id = gt_param_desenv_ba.codajsaldoapuricms_id_deducao;
        --
        vn_fase := 8.24;
        --
        delete from ajust_apur_icms_gia
         where ajustapuracaoicms_id in (select id
                                          from ajust_apuracao_icms
                                         where apuracaoicms_id       = gt_row_apuracao_icms.id
                                           and codajsaldoapuricms_id = gt_param_desenv_ba.codajsaldoapuricms_id_deb_esp);
        --
        vn_fase := 8.25;
        --
        delete from ajust_apuracao_icms
         where apuracaoicms_id       = gt_row_apuracao_icms.id
           and codajsaldoapuricms_id = gt_param_desenv_ba.codajsaldoapuricms_id_deb_esp;
        --
        vn_fase := 8.26;
        --
        delete from rel_det_desenv_ba
         where reldesenvba_id in (select id
                                    from rel_desenv_ba
                                   where apuracaoicms_id = gt_row_apuracao_icms.id);
        --
        vn_fase := 8.27;
        --
        delete from rel_desenv_ba
         where apuracaoicms_id = gt_row_apuracao_icms.id;
        --
      end if;
      --
      vn_fase := 8.9;
      --
      -- Se o DM_SITUACAO = 1 "Calculado" ou 2 "Erro no C�lculo", defaz para 0 "Aberto"
      update apuracao_icms
         set dm_situacao            = 0,
             vl_total_debito        = 0,
             vl_ajust_debito        = 0,
             vl_total_ajust_deb     = 0,
             vl_estorno_credito     = 0,
             vl_total_credito       = 0,
             vl_ajust_credito       = 0,
             vl_total_ajust_cred    = 0,
             vl_estorno_debido      = 0,
             vl_saldo_apurado       = 0,
             vl_total_deducao       = 0,
             vl_icms_recolher       = 0,
             vl_saldo_credor_transp = 0,
             vl_deb_esp             = 0,
             vl_saldo_credor_ant    = 0
       where id = gt_row_apuracao_icms.id;
      --
      vn_fase := 9;
      --
      vv_descr_dm_situacao := pk_csf.fkg_dominio(ev_dominio => 'APURACAO_ICMS.DM_SITUACAO',
                                                 ev_vl      => 0);
      --
    end if;
    --
    vn_fase := 10;
    --
    commit;
    --
    vn_fase := 11;
    --
    gv_resumo_log := 'Desfeito a situa��o de "' || pk_csf.fkg_dominio(ev_dominio => 'APURACAO_ICMS.DM_SITUACAO', ev_vl      => gt_row_apuracao_icms.dm_situacao) || '" para a situa��o "' || vv_descr_dm_situacao || '"';
    --
    pk_log_generico.pkb_log_generico(sn_loggenerico_id => vn_loggenerico_id,
                                     ev_mensagem       => gv_mensagem_log,
                                     ev_resumo         => gv_resumo_log,
                                     en_tipo_log       => info_apur_imposto,
                                     en_referencia_id  => gn_referencia_id,
                                     ev_obj_referencia => gv_obj_referencia);
    --
  end if;
  --
exception
  when others then
    --
    gv_mensagem_log := 'Erro na pk_apur_icms.pkb_desfazer fase ( ' || vn_fase || ' ):' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico.id%type;
    begin
      --
      pk_log_generico.pkb_log_generico(sn_loggenerico_id => vn_loggenerico_id,
                                       ev_mensagem       => gv_mensagem_log,
                                       ev_resumo         => gv_mensagem_log,
                                       en_tipo_log       => erro_de_sistema,
                                       en_referencia_id  => en_apuracaoicms_id,
                                       ev_obj_referencia => gv_obj_referencia);
      --
    exception
      when others then
        null;
    end;
    --
    raise_application_error(-20101, gv_mensagem_log);
    --
end pkb_desfazer;

-------------------------------------------------------------------------------------------------------
-- Procedimento de inserir o ajuste da apura��o de ICMS
procedure pkb_insere_ajust_apuracao_icms ( en_apuracaoicms_id        in ajust_apuracao_icms.apuracaoicms_id%type
                                         , en_codajsaldoapuricms_id  in ajust_apuracao_icms.codajsaldoapuricms_id%type
                                         , en_subitemgia_id          in ajust_apur_icms_gia.subitemgia_id%type
                                         , ev_descr_compl_aj         in ajust_apuracao_icms.descr_compl_aj%type
                                         , en_vl_aj_apur             in ajust_apuracao_icms.vl_aj_apur%type
                                         )
is
   --
   vn_fase         number;
   vn_qtde         number;
   vn_qtde_gia     number;
   vt_subitem_gia  subitem_gia%rowtype;
   --
begin
   --
   vn_fase := 1;
   --
   vt_subitem_gia := pk_csf_gia.fkg_subitem_gia_row ( en_subitemgia_id => en_subitemgia_id );
   --
   vn_fase := 1.1;
   --
   vn_qtde := 0;
   --
   begin
      --
      select count(1)
        into vn_qtde
        from ajust_apuracao_icms aa
       where aa.apuracaoicms_id       = en_apuracaoicms_id
         and aa.codajsaldoapuricms_id = en_codajsaldoapuricms_id;
      --
   exception
      when others then
         vn_qtde := 0;
   end;
   --
   vn_fase := 2;
   --
   if nvl(vn_qtde,0) <= 0 then
      --
      vn_fase := 2.1;
      --
      insert into ajust_apuracao_icms ( id
                                      , apuracaoicms_id
                                      , codajsaldoapuricms_id
                                      , descr_compl_aj
                                      , vl_aj_apur
                                      )
                               values ( ajustapuracaoicms_seq.nextval --id
                                      , en_apuracaoicms_id -- apuracaoicms_id
                                      , en_codajsaldoapuricms_id -- codajsaldoapuricms_id
                                      , ev_descr_compl_aj -- descr_compl_aj
                                      , en_vl_aj_apur -- vl_aj_apur
                                      );
      --
      vn_fase := 2.2;
      --
      if nvl(vt_subitem_gia.id,0) > 0 then
         --
         vn_fase := 2.3;
         --
         insert into ajust_apur_icms_gia ( id
                                         , ajustapuracaoicms_id
                                         , subitemgia_id
                                         , vl_aj_apur
                                         , flegal
                                         , descr_ocor
                                         )
                                  values ( ajustapuricmsgia_seq.nextval -- id
                                         , ajustapuracaoicms_seq.currval --ajustapuracaoicms_id
                                         , vt_subitem_gia.id -- subitemgia_id
                                         , en_vl_aj_apur -- vl_aj_apur
                                         , substr(vt_subitem_gia.flegal,1,100) --flegal
                                         , ev_descr_compl_aj -- ddescr_ocor
                                         );
         --
      end if;
      --
   else
      --
      vn_fase := 3;
      --
      update ajust_apuracao_icms aa
         set aa.vl_aj_apur      = en_vl_aj_apur
           , aa.descr_compl_aj  = ev_descr_compl_aj
       where aa.apuracaoicms_id       = en_apuracaoicms_id
         and aa.codajsaldoapuricms_id = en_codajsaldoapuricms_id;
      --
      vn_fase := 3.1;
      --
      if nvl(vt_subitem_gia.id,0) > 0 then
         --
         vn_fase := 3.2;
         --
         vn_qtde_gia := 0;
         --
         begin
            --
            select count(1)
              into vn_qtde_gia
              from ajust_apur_icms_gia ig
             where ig.subitemgia_id = vt_subitem_gia.id
               and ig.ajustapuracaoicms_id in ( select max(aa.id)
                                                  from ajust_apuracao_icms aa
                                                 where aa.apuracaoicms_id        = en_apuracaoicms_id
                                                   and aa.codajsaldoapuricms_id  = en_codajsaldoapuricms_id
                                              );
            --
         exception
            when others then
               vn_qtde_gia := null;
         end;
         --
         vn_fase := 3.3;
         --
         if nvl(vn_qtde_gia,0) > 0 then
            --
            update ajust_apur_icms_gia ig
               set ig.vl_aj_apur = en_vl_aj_apur
                 , ig.descr_ocor = ev_descr_compl_aj
             where ig.subitemgia_id = vt_subitem_gia.id
               and ig.ajustapuracaoicms_id in ( select max(aa.id)
                                                  from ajust_apuracao_icms aa
                                                 where aa.apuracaoicms_id        = en_apuracaoicms_id
                                                   and aa.codajsaldoapuricms_id  = en_codajsaldoapuricms_id
                                              );
             --
         else
            --
            vn_fase := 3.4;
            --
            insert into ajust_apur_icms_gia ( id
                                            , ajustapuracaoicms_id
                                            , subitemgia_id
                                            , vl_aj_apur
                                            , flegal
                                            , descr_ocor
                                            )
                                     values ( ajustapuricmsgia_seq.nextval -- id
                                            , ( select max(aa.id)
                                                  from ajust_apuracao_icms aa
                                                 where aa.apuracaoicms_id        = en_apuracaoicms_id
                                                   and aa.codajsaldoapuricms_id  = en_codajsaldoapuricms_id
                                              )
                                            , vt_subitem_gia.id -- subitemgia_id
                                            , en_vl_aj_apur -- vl_aj_apur
                                            , vt_subitem_gia.flegal --flegal
                                            , ev_descr_compl_aj -- ddescr_ocor
                                            );
            --
         end if;
         --
      end if;
      --
   end if;
   --
   vn_fase := 4;
   --
   commit;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_apur_icms.pkb_insere_ajust_apuracao_icms fase ( '||vn_fase||' ):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => gt_row_apuracao_icms.id
                                     , ev_obj_referencia  => gv_obj_referencia
                                     );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_insere_ajust_apuracao_icms;

-------------------------------------------------------------------------------------------------------
-- Procedimento de criar o ajuste do CIAP
procedure pkb_criar_ajuste_ciap
is
   --
   vn_fase                       number;
   vn_vl_ajuste_ciap             number(15,2);
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(gt_row_param_efd_icms_ipi.codajsaldoapuricms_id_ciap,0) > 0 then
      --
      vn_fase := 3;
      --
      begin
         select sum( nvl(iac.vl_icms_aprop,0) + nvl(iac.vl_som_icms_oc,0) )
           into vn_vl_ajuste_ciap
           from icms_atperm_ciap iac
          where iac.empresa_id      = gt_row_apuracao_icms.empresa_id
            and (trunc(iac.dt_ini) >= gt_row_apuracao_icms.dt_inicio and trunc(iac.dt_fin) <= gt_row_apuracao_icms.dt_fim)
            and iac.dm_st_proc      = 1; -- Validado
      exception
         when others then
            vn_vl_ajuste_ciap := 0;
      end;
      --
      vn_fase := 4;
      --
      if nvl(vn_vl_ajuste_ciap,0) > 0 then
         --
         vn_fase := 5;
         --
         pkb_insere_ajust_apuracao_icms ( en_apuracaoicms_id        => gt_row_apuracao_icms.id
                                        , en_codajsaldoapuricms_id  => gt_row_param_efd_icms_ipi.codajsaldoapuricms_id_ciap
                                        , en_subitemgia_id          => gt_row_param_efd_icms_ipi.subitemgia_id_ciap
                                        , ev_descr_compl_aj         => 'Ajuste oriundo do CIAP'
                                        , en_vl_aj_apur             => vn_vl_ajuste_ciap
                                        );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_apur_icms.pkb_criar_ajuste_ciap fase ( '||vn_fase||' ):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => gt_row_apuracao_icms.id
                                     , ev_obj_referencia  => gv_obj_referencia
                                     );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_criar_ajuste_ciap;

-------------------------------------------------------------------------------------------------------
-- Procedimento de cria��o do ajuste do diferencial de aliquota na apura��o de ICMS
procedure pkb_criar_ajuste_difal
is
   --
   vn_fase            number;
   vn_vl_ajuste_difal number(15,2);
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(gt_row_param_efd_icms_ipi.codajsaldoapuricms_id_difal,0) > 0 then
      --
      vn_fase := 2;
      --
      begin
         --
         select sum(nvl(da.vl_dif_aliq,0)) vl_icms
           into vn_vl_ajuste_difal
           from nota_fiscal            nf
              , item_nota_fiscal       inf
              , itemnf_dif_aliq        da
          where nf.empresa_id        = gt_row_apuracao_icms.empresa_id
            and nf.dm_st_proc        = 4
            and nf.dm_arm_nfe_terc   = 0 -- N�o � nota de armazenamento fiscal
            and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
                  or
                 (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
                  or
                 (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
                  or
                 (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
            and inf.notafiscal_id    = nf.id
            and da.itemnf_id         = inf.id;
         --
      exception
         when others then
            vn_vl_ajuste_difal := 0;
      end;
      --
      vn_fase := 3;
      --
      if nvl(vn_vl_ajuste_difal,0) > 0 then
         --
         vn_fase := 4;
         --
         pkb_insere_ajust_apuracao_icms ( en_apuracaoicms_id        => gt_row_apuracao_icms.id
                                        , en_codajsaldoapuricms_id  => gt_row_param_efd_icms_ipi.codajsaldoapuricms_id_difal
                                        , en_subitemgia_id          => gt_row_param_efd_icms_ipi.subitemgia_id_difal
                                        , ev_descr_compl_aj         => 'Ajuste oriundo do DIFAL'
                                        , en_vl_aj_apur             => vn_vl_ajuste_difal
                                        );
         --
      end if;
      --
   end if;
   --
   vn_fase := 5;
   --
   if nvl(gt_row_param_efd_icms_ipi.codajsaldoapuricms_id_dif_sc,0) > 0 then
      --
      vn_fase := 6;
      --
      begin
         --
         select sum(nvl(nd.vl_dif_aliq,0)) vl_icms
           into vn_vl_ajuste_difal
           from mod_fiscal             mf
              , nota_fiscal            nf
              , nfregist_analit        na
              , nfregist_analit_difal  nd
          where nf.empresa_id        = gt_row_apuracao_icms.empresa_id
            and nf.dm_st_proc        = 4
            and nf.dm_arm_nfe_terc   = 0 -- N�o � nota de armazenamento fiscal
            and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
                  or
                 (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
                  or
                 (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
                  or
                 (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
            and mf.cod_mod in ('06', '29', '28', '21', '22')
            and mf.id = nf.modfiscal_id
            and nf.id = na.notafiscal_id
            and na.id = nd.nfregistanalit_id;
         --
      exception
         when others then
            vn_vl_ajuste_difal := 0;
      end;
      --
      vn_fase := 7;
      --
      if nvl(vn_vl_ajuste_difal,0) > 0 then
         --
         vn_fase := 8;
         --
         pkb_insere_ajust_apuracao_icms ( en_apuracaoicms_id        => gt_row_apuracao_icms.id
                                        , en_codajsaldoapuricms_id  => gt_row_param_efd_icms_ipi.codajsaldoapuricms_id_dif_sc
                                        , en_subitemgia_id          => gt_row_param_efd_icms_ipi.subitemgia_id_difal_nfsc
                                        , ev_descr_compl_aj         => 'Ajuste oriundo do DIFAL'
                                        , en_vl_aj_apur             => vn_vl_ajuste_difal
                                        );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_apur_icms.pkb_criar_ajuste_difal fase ( '||vn_fase||' ):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => gt_row_apuracao_icms.id
                                     , ev_obj_referencia  => gv_obj_referencia 
                                     );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_criar_ajuste_difal;

-------------------------------------------------------------------------------------------------------
-- Procedimento de cria��o da Infor. Prov. Docto Fiscal para o DIFAL
procedure pkb_criar_infprovdoctofiscal
is
   --
   vn_fase                   number;
   vb_inseriu                boolean;
   vn_obslanctofiscal_id     obs_lancto_fiscal.id%type;
   vn_nfinforfiscal_id       nfinfor_fiscal.id%type;
   vn_infprovdoctofiscal_id  inf_prov_docto_fiscal.id%type;
   vn_loggenerico_id         Log_Generico.id%TYPE;
   --
   cursor c_nf is
   select nf.id notafiscal_id
     from nota_fiscal nf
    where nf.empresa_id      = gt_row_apuracao_icms.empresa_id
      and nf.dm_st_proc      = 4
      and nf.dm_arm_nfe_terc = 0 -- N�o � nota de armazenamento fiscal
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_apuracao_icms.dt_inicio) and trunc(gt_row_apuracao_icms.dt_fim)))
    order by nf.id;
   --
   cursor c_difal (en_notafiscal_id nota_fiscal.id%type) is
   select da.*
     from item_nota_fiscal inf
        , itemnf_dif_aliq  da
    where inf.notafiscal_id = en_notafiscal_id
      and da.itemnf_id      = inf.id;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(gt_row_param_efd_icms_ipi.codocorajicms_id_difal,0) > 0 then
      --
      vn_fase := 2;
      --
      vn_obslanctofiscal_id := pk_csf.fkg_id_obs_lancto_fiscal ( en_multorg_id => pk_csf.fkg_multorg_id_empresa(en_empresa_id => gt_row_apuracao_icms.empresa_id)
                                                               , ev_cod_obs    => 'DIFAL' );
      --
      if nvl(vn_obslanctofiscal_id,0) > 0 then
         --
         for rec_nf in c_nf loop
            exit when c_nf%notfound or (c_nf%notfound) is null;
            --
            vn_fase := 3;
            --
            vb_inseriu := false;
            --
            begin
               --
               select min(id)
                 into vn_nfinforfiscal_id
                 from nfinfor_fiscal
                where 1 = 1
                  and notafiscal_id       = rec_nf.notafiscal_id
                  and obslanctofiscal_id  = vn_obslanctofiscal_id;
               --
            exception
               when others then
                  vn_nfinforfiscal_id := null;
            end;
            --
            vn_fase := 3.1;
            --
            for rec_difal in c_difal(rec_nf.notafiscal_id) loop
               exit when c_difal%notfound or (c_difal%notfound) is null;
               --
               vn_fase := 4;
               --
               if nvl(vn_nfinforfiscal_id,0) <= 0 then
                  --
                  if not vb_inseriu then
                     --
                     vn_fase := 5;
                     --
                     insert into nfinfor_fiscal ( id
                                                , notafiscal_id
                                                , obslanctofiscal_id
                                                , txt_compl
                                                )
                                         values ( nfinforfiscal_seq.nextval --id
                                                , rec_nf.notafiscal_id -- notafiscal_id
                                                , vn_obslanctofiscal_id --obslanctofiscal_id
                                                , 'Diferencial de al�quota' -- txt_compl
                                                );
                     --
                     vn_fase    := 6;
                     vb_inseriu := true;
                     --
                  end if;
                  --
                  vn_fase := 7;
                  --
                  insert into inf_prov_docto_fiscal ( id
                                                    , nfinforfisc_id
                                                    , codocorajicms_id
                                                    , descr_compl_aj
                                                    , itemnf_id
                                                    , vl_bc_icms
                                                    , aliq_icms
                                                    , vl_icms
                                                    , vl_outros
                                                    )
                                             values ( infprovdoctofiscal_Seq.nextval --id
                                                    , nfinforfiscal_seq.currval --nfinforfisc_id
                                                    , gt_row_param_efd_icms_ipi.codocorajicms_id_difal -- codocorajicms_id
                                                    , 'Diferencial de al�quota' -- descr_compl_aj
                                                    , rec_difal.itemnf_id --itemnf_id
                                                    , rec_difal.vl_bc_icms -- vl_bc_icms
                                                    , rec_difal.aliq_ie -- aliq_icms
                                                    , rec_difal.vl_dif_aliq -- vl_icms
                                                    , 0 -- vl_outros
                                                    );
                  --
               else
                  --
                  vn_fase := 8;
                  --
                  begin
                     --
                     select min(id)
                       into vn_infprovdoctofiscal_id
                       from inf_prov_docto_fiscal
                      where 1 = 1
                        and nfinforfisc_id = vn_nfinforfiscal_id
                        and itemnf_id      = rec_difal.itemnf_id;
                     --
                  exception
                     when others then
                        vn_infprovdoctofiscal_id := null;
                  end;
                  --
                  vn_fase := 8.1;
                  --
                  if nvl(vn_infprovdoctofiscal_id,0) <= 0 then
                     --
                     vn_fase := 8.11;
                     --
                     insert into inf_prov_docto_fiscal ( id
                                                       , nfinforfisc_id
                                                       , codocorajicms_id
                                                       , descr_compl_aj
                                                       , itemnf_id
                                                       , vl_bc_icms
                                                       , aliq_icms
                                                       , vl_icms
                                                       , vl_outros
                                                       )
                                                values ( infprovdoctofiscal_Seq.nextval --id
                                                       , vn_nfinforfiscal_id --nfinforfisc_id
                                                       , gt_row_param_efd_icms_ipi.codocorajicms_id_difal -- codocorajicms_id
                                                       , 'Diferencial de al�quota' -- descr_compl_aj
                                                       , rec_difal.itemnf_id --itemnf_id
                                                       , rec_difal.vl_bc_icms -- vl_bc_icms
                                                       , rec_difal.aliq_ie -- aliq_icms
                                                       , rec_difal.vl_dif_aliq -- vl_icms
                                                       , 0 -- vl_outros
                                                       );
                     --
                  else
                     --
                     vn_fase := 8.12;
                     --
                     update inf_prov_docto_fiscal set codocorajicms_id  = gt_row_param_efd_icms_ipi.codocorajicms_id_difal
                                                    , descr_compl_aj    = 'Diferencial de al�quota'
                                                    , vl_bc_icms        = rec_difal.vl_bc_icms
                                                    , aliq_icms         = rec_difal.aliq_ie
                                                    , vl_icms           = rec_difal.vl_dif_aliq
                      where id = vn_infprovdoctofiscal_id;
                     --
                  end if;
                  --
               end if;
               --
            end loop;
            --
            commit;
            --
         end loop;
         --
      else
         --
         vn_fase := 9;
         --
         gv_mensagem_log := 'N�o foi definido a "Observa��o do Lan�amento Fiscal" DIFAL-Diferencial de al�quota, para registro das "Informa��es Provenientes do Documento Fiscal".';
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gt_row_apuracao_icms.id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_apur_icms.pkb_criar_infprovdoctofiscal fase ( '||vn_fase||' ):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_SISTEMA
                                          , en_referencia_id   => gt_row_apuracao_icms.id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_criar_infprovdoctofiscal;

-------------------------------------------------------------------------------------------------------
-- Procedimento de cria��o do ajuste do diferencial de aliquota na apura��o de ICMS, atraves de apura��o do ICMS-DIFAL
procedure pkb_criar_ajuste_difal_apur_id
is
   --
   vn_fase            number;
   vn_vl_ajuste_difal number(15,2);
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(gt_row_param_efd_icms_ipi.codajsaldoapuricms_id_difpart,0) > 0 then
      --
      vn_fase := 2;
      --
      begin
         --
         select sum(o.vl_or)
           into vn_vl_ajuste_difal
           from per_apur_icms_difal      p
              , apur_icms_difal          a
              , obr_rec_apur_icms_difal  o
              , aj_obrig_rec             aor
          where p.empresa_id             = gt_row_apuracao_icms.empresa_id
            and p.dt_inicio              = gt_row_apuracao_icms.dt_inicio
            and p.dt_fim                 = gt_row_apuracao_icms.dt_fim
            and p.dm_tipo                = 0 -- Real
            and a.perapuricmsdifal_id    = p.id
            and a.estado_id              = gn_estado_id
            and a.dm_situacao            = 3 -- Processada
            and o.apuricmsdifal_id       = a.id
            and aor.id                   = o.ajobrigrec_id
            and aor.cd in ('000');
         --
      exception
         when others then
            vn_vl_ajuste_difal := 0;
      end;
      --
      vn_fase := 3;
      --
      if nvl(vn_vl_ajuste_difal,0) > 0 then
         --
         vn_fase := 4;
         --
         pkb_insere_ajust_apuracao_icms ( en_apuracaoicms_id        => gt_row_apuracao_icms.id
                                        , en_codajsaldoapuricms_id  => gt_row_param_efd_icms_ipi.codajsaldoapuricms_id_difpart
                                        , en_subitemgia_id          => gt_row_param_efd_icms_ipi.subitemgia_id_difpart
                                        , ev_descr_compl_aj         => 'Ajuste oriundo da Apura��o ICMS-DIFAL'
                                        , en_vl_aj_apur             => vn_vl_ajuste_difal
                                        );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_apur_icms.pkb_criar_ajuste_difal_apur_id fase ( '||vn_fase||' ):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => gt_row_apuracao_icms.id
                                     , ev_obj_referencia  => gv_obj_referencia 
                                     );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_criar_ajuste_difal_apur_id;

-------------------------------------------------------------------------------------------------------
-- Procedimento Monta como deve ser o DIFAL
procedure pkb_monta_difal
is
   --
   vn_fase                        number;
   --
begin
   --
   vn_fase := 1;
   -- verifica como ser� o Lan�amento do Diferencial de Al�quota
   if gt_row_param_efd_icms_ipi.dm_lcto_difal = 1 then
      --
      vn_fase := 2.1;
      -- 1 - Apura��o de ICMS
      -- cria��o do ajuste do diferencial de aliquota na apura��o de ICMS
      pkb_criar_ajuste_difal;
      --
   elsif gt_row_param_efd_icms_ipi.dm_lcto_difal = 2 then
      --
      vn_fase := 2.2;
      -- 2-Registro C197 (Infor. Prov. Docto Fiscal)
      -- cria��o da Infor. Prov. Docto Fiscal para o DIFAL
      pkb_criar_infprovdoctofiscal;
      --
   end if;
   --
   vn_fase := 3;
   -- cria��o do ajuste do diferencial de aliquota na apura��o de ICMS, atraves de apura��o do ICMS-DIFAL/Partilha de ICMS
   pkb_criar_ajuste_difal_apur_id;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_apur_icms.pkb_monta_difal fase ( '||vn_fase||' ):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => gt_row_apuracao_icms.id
                                     , ev_obj_referencia  => gv_obj_referencia 
                                     );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_monta_difal;

-------------------------------------------------------------------------------------------------------
--| Procedimento de calcular a apuracao de ICMS
procedure pkb_calc_apuracao_icms
is
   --
   vn_fase             number := 0;
   --
begin
   --
         vn_fase := 7;
         -- recupera dados para apura��o
         -- 02-VL_TOT_DEBITOS - Valor total dos d�bitos por "Sa�das e presta��es com d�bito do imposto"
         /*Campo 02 - Valida��o: o valor informado deve corresponder ao somat�rio de todos os documentos fiscais de sa�da que geram d�bito de ICMS.
         Deste somat�rio, est�o exclu�dos os documentos extempor�neos (COD_SIT com valor igual �01�), os documentos complementares extempor�neos (COD_SIT
         com valor igual �07�) e os documentos fiscais com CFOP 5605 � Transfer�ncia de saldo devedor de ICMS de outro estabelecimento da mesma empresa.
         Devem ser inclu�dos os documentos fiscais com CFOP igual a 1605 - Recebimento, por transfer�ncia, de saldo devedor do ICMS de outro estabelecimento
         da mesma empresa. O valor neste campo deve ser igual � soma dos VL_ICMS de todos os registros C190, C320, C390, C490, C590, C690, C790, C850, C890,
         D190, D300, D390, D410, D590, D690, D696, com as datas dos campos DT_DOC (C300, C405, C600, D300, D355, D400, D600) ou DT_E_S (C100, C500) ou 
         DT_DOC_FIN (C700, D695) ou DT_A_P (D100, D500) dentro do per�odo informado no registro E100.
*/
         --
         gt_row_apuracao_icms.vl_total_debito := nvl(fkg_som_vl_icms_c190_c590_d590,0) +
                                                 nvl(fkg_soma_vl_icms_c320,0) +
                                                 nvl(fkg_soma_vl_icms_c390,0) +
                                                 nvl(fkg_soma_vl_icms_c490_d390,0) +
                                                 nvl(fkg_soma_vl_icms_c690,0) +
                                                 nvl(fkg_soma_vl_icms_c790,0) +
                                                 nvl(fkg_soma_vl_icms_c800,0) +
                                                 nvl(fkg_soma_vl_icms_d190,0) +
                                                 nvl(fkg_soma_vl_icms_d300,0) +
                                                 nvl(fkg_soma_vl_icms_d410,0) +
                                                 nvl(fkg_soma_vl_icms_d690,0) +
                                                 nvl(fkg_soma_vl_icms_d696,0);
         --
-------------------------------------------------------------------------------------------------------
         --
         vn_fase := 8;
         -- 03-VL_AJ_DEBITOS-Valor total dos ajustes a d�bito decorrentes do documento fiscal.
         /*Campo 03 - Valida��o: o valor informado deve corresponder ao somat�rio do campo VL_ICMS dos registros C197 e D197, se o terceiro caractere do campo
           COD_AJ dos registros C197 ou D197 for igual a �3�, �4� ou �5� e o quarto caractere for igual a �0�, �3�, �4� ou �5�. Deste somat�rio, est�o exclu�dos
           os documentos extempor�neos (COD_SIT com valor igual �01�) e os documentos complementares extempor�neos (COD_SIT com valor igual �07�), cujos valores
           devem ser prestados no campo DEB_ESP juntamente com os demais valores extra-apura��o.
           Ser�o considerados os registros cujos documentos estejam compreendidos no per�odo informado no registro E100, utilizando para tanto o campo DT_E_S
           (C100) e DT_DOC ou DT_A_P (D100). Quando o campo DT_E_S (C100) for vazio, utilizar o campo DT_DOC.*/
         --
         gt_row_apuracao_icms.vl_ajust_debito := nvl(fkg_soma_aj_debito,0);
         --
-------------------------------------------------------------------------------------------------------
         --
         vn_fase := 9;
         --
         -- 04-VL_TOT_AJ_DEBITOS
         /*Campo 04 - Valida��o: o valor informado deve corresponder ao somat�rio do campo VL_AJ_APUR dos registros E111,
se o terceiro caracter for igual a �0� e o quarto caracter do campo COD_AJ_APUR do registro E111 for igual a �0�.*/
         --
         gt_row_apuracao_icms.vl_total_ajust_deb := nvl(fkg_soma_tot_aj_debitos, 0);
         --
-------------------------------------------------------------------------------------------------------
         --
         vn_fase := 10;
         --
         -- 05-VL_ESTORNOS_CRED
         /*Campo 05 - Valida��o: o valor informado deve corresponder ao somat�rio do campo VL_AJ_APUR dos registros E111,
se o terceiro caracter for igual a �0� e o quarto caracter do campo COD_AJ_APUR do registro E111 for igual a �1�.*/
         --
         gt_row_apuracao_icms.vl_estorno_credito := nvl(fkg_soma_estornos_cred, 0);
         --
-------------------------------------------------------------------------------------------------------
         --
         vn_fase := 11;
         --
         -- 06-VL_TOT_CREDITOS - Valor total dos cr�ditos por "Entradas e aquisi��es com cr�dito do imposto"
         /*Campo 06 - Valida��o: o valor informado deve corresponder ao somat�rio de todos os documentos fiscais de entrada que
geram cr�dito de ICMS. O valor neste campo deve ser igual � soma dos VL_ICMS de todos os registros C190, C590, D190
e D590. Deste somat�rio, est�o exclu�dos os documentos fiscais com CFOP 1605 e inclu�dos os documentos fiscais com
CFOP 5605. Os documentos fiscais devem ser somados conforme o per�odo informado no registro E100 e a data informada
no campo DT_E_S (C100, C500) ou campo DT_A_P (D100, D500), exceto se COD_SIT do documento for igual a �01�
(extempor�neo) ou igual a 07 (NF Complementar extempor�nea), cujo valor ser� somado no primeiro per�odo de apura��o
informado no registro E100.*/
         --
         gt_row_apuracao_icms.vl_total_credito := ( nvl(fkg_tot_cred_c190_c590_d590, 0) + nvl(fkg_totcredc190_c590_d590_5605, 0) ) +
                                                  ( nvl(fkg_tot_cred_d190,0) + nvl(fkg_tot_cred_d190_5605, 0) );
         --
-------------------------------------------------------------------------------------------------------
         --
         vn_fase := 12;
         --
         -- 07-VL_AJ_CREDITOS
         /*Campo 07 - Valida��o: o valor informado deve corresponder ao somat�rio do campo VL_ICMS dos registros C197 e D197, se o
           terceiro caractere do c�digo de ajuste dos registros C197 ou D197 for �0�, �1� ou �2� e o quarto caractere for "0", �3�, �4� ou �5�.
           Devem ser considerados os documentos fiscais compreendidos no per�odo informado no registro E100, analisando-se as datas informadas
           no campo DT_E_S do registro C100 e DT_DOC ou DT_A_P do registro D100, exceto se COD_SIT do registro C100 e D100 for igual a �01� (extempor�neo)
           ou igual a �07� (Complementar extempor�nea), cujo valor deve ser somado no primeiro per�odo de apura��o informado no registro E100.*/
         --
         gt_row_apuracao_icms.vl_ajust_credito := nvl(fkg_soma_aj_credito, 0);
         --
-------------------------------------------------------------------------------------------------------
         --
         vn_fase := 13;
         --
         -- 08-VL_TOT_AJ_CREDITOS
         /*Campo 08 - Valida��o: o valor informado deve corresponder ao somat�rio dos valores constantes dos registros E111,
quando o terceiro caracter for igual a �0� e o quarto caracter for igual a �2�, do COD_AJ_APUR do registro E111.*/
         --
         gt_row_apuracao_icms.vl_total_ajust_cred := nvl(fkg_soma_tot_aj_credito, 0);
         --
-------------------------------------------------------------------------------------------------------
         --
         vn_fase := 14;
         --
         -- 09-VL_ESTORNOS_DEB
         /*Campo 09 - Valida��o: o valor informado deve corresponder ao somat�rio do VL_AJ_APUR dos registros E111, quando
o terceiro caracter for igual a �0� e o quarto caracter for igual a �3�, do COD_AJ_APUR do registro E111.*/
         --
         gt_row_apuracao_icms.vl_estorno_debido := nvl(fkg_soma_estorno_deb, 0);
         --
-------------------------------------------------------------------------------------------------------
         --
         vn_fase := 15;
         --
         -- 10-VL_SLD_CREDOR_ANT -- Se n�o informado manualmente, busca o anterior
         if nvl(gt_row_apuracao_icms.vl_saldo_credor_ant,0) <= 0 then
            --
            gt_row_apuracao_icms.vl_saldo_credor_ant := fkg_saldo_credor_ant;
            --
         end if;
         --
-------------------------------------------------------------------------------------------------------
         --
         vn_fase := 16;
         --
         -- 11-VL_SLD_APURADO
         /*Campo 11 - Valida��o: o valor informado deve ser preenchido com base na express�o: soma do total de d�bitos
(VL_TOT_DEBITOS) com total de ajustes (VL_AJ_DEBITOS +VL_TOT_AJ_DEBITOS) com total de estorno de cr�dito
(VL_ESTORNOS_CRED) menos a soma do total de cr�ditos (VL_TOT_CREDITOS) com total de ajuste de cr�ditos
(VL_,AJ_CREDITOS + VL_TOT_AJ_CREDITOS) com total de estorno de d�bito (VL_ESTORNOS_DEB) com saldo
credor do per�odo anterior (VL_SLD_CREDOR_ANT). Se o valor da express�o for maior ou igual a �0� (zero), ent�o este
valor deve ser informado neste campo e o campo 14 (VL_SLD_CREDOR_TRANSPORTAR) deve ser igual a �0� (zero).
Se o valor da express�o for menor que �0� (zero), ent�o este campo deve ser preenchido com �0� (zero) e o valor absoluto
da express�o deve ser informado no campo VL_SLD_CREDOR_TRANSPORTAR.*/
         --
         gt_row_apuracao_icms.vl_saldo_apurado := ( gt_row_apuracao_icms.vl_total_debito
                                                  + gt_row_apuracao_icms.vl_ajust_debito
                                                  + gt_row_apuracao_icms.vl_total_ajust_deb 
                                                  + gt_row_apuracao_icms.vl_estorno_credito )
                                                  - ( gt_row_apuracao_icms.vl_total_credito
                                                    + gt_row_apuracao_icms.vl_ajust_credito
                                                    + gt_row_apuracao_icms.vl_total_ajust_cred 
                                                    + gt_row_apuracao_icms.vl_estorno_debido
                                                    + gt_row_apuracao_icms.vl_saldo_credor_ant );
         --
         vn_fase := 17;
         --
         if nvl(gt_row_apuracao_icms.vl_saldo_apurado,0) < 0 then
            --
            gt_row_apuracao_icms.vl_saldo_credor_transp := gt_row_apuracao_icms.vl_saldo_apurado * (-1);
            gt_row_apuracao_icms.vl_saldo_apurado := 0;
            --
         else
            --
            gt_row_apuracao_icms.vl_saldo_credor_transp := 0;
            --
         end if;
         --
-------------------------------------------------------------------------------------------------------
         --
         vn_fase := 18;
         --
         -- 12-VL_TOT_DED
         /*Campo 12 - Valida��o: o valor informado deve corresponder ao somat�rio do campo VL_ICMS do registro C197, se o
terceiro caracter do c�digo de ajuste do registro C197, for �6� e o quarto caracter for �0�, somado ao valor total informado
nos registros E111, quando o terceiro caracter for igual a �0� e o quarto caracter for igual a �4�, do campo
COD_AJ_APUR do registro E111.
Para o somat�rio do campo VL_ICMS do registro C197 devem ser considerados os documentos fiscais compreendidos no
per�odo informado no registro E100, comparando com a data informada no campo DT_E_S do registro C100, exceto se
COD_SIT do registro C100 for igual a �01� (extempor�neo) ou igual a �07� (NF Complementar extempor�nea), cujo valor
deve ser somado no primeiro per�odo de apura��o informado no registro E100, quando houver mais de um per�odo de
apura��o. Quando o campo DT_E_S n�o for informado, utilizar o campo DT_DOC.
Neste campo s�o informados os valores que, segundo a legisla��o da UF, devam ser tratados como �Dedu��o do imposto�,
ainda que no campo VL_SLD_APURADO tenha como resultado o valor zero.*/
         --
         gt_row_apuracao_icms.vl_total_deducao := nvl(fkg_soma_tot_ded_c197, 0) + nvl(fkg_soma_tot_ded_e111, 0);
         --
-------------------------------------------------------------------------------------------------------
         --
         vn_fase := 19;
         --
         -- 13-VL_ICMS_RECOLHER
         /*Campo 13 � Valida��o: o valor informado deve corresponder � diferen�a entre o campo VL_SLD_APURADO e o campo
VL_TOT_DED. Se o resultado dessa opera��o for negativo, informe o valor zero neste campo, e o valor absoluto correspondente
no campo VL_SLD_CREDOR_TRANSPORTAR. Verificar se a legisla��o da UF permite que dedu��o seja
maior que o saldo devedor.
O valor da soma deste campo com o campo DEB_ESP deve ser igual � soma dos valores do campo VL_OR do registro
E116.*/
         --
         gt_row_apuracao_icms.vl_icms_recolher := nvl(gt_row_apuracao_icms.vl_saldo_apurado,0) - nvl(gt_row_apuracao_icms.vl_total_deducao,0);
         --
         vn_fase := 20;
         --
         if nvl(gt_row_apuracao_icms.vl_icms_recolher,0) < 0 then
            --
            vn_fase := 20.1;
         -- 14-VL_SLD_CREDOR_TRANSPORTAR
         /*Campo 14 � Valida��o: se o valor da express�o: soma do total de d�bitos (VL_TOT_DEBITOS) com total de ajustes
(VL_AJ_DEBITOS + VL_TOT_AJ_DEBITOS) com total de estorno de cr�dito (VL_ESTORNOS_CRED) menos a soma
do total de cr�ditos (VL_TOT_CREDITOS) com total de ajuste de cr�ditos (VL_AJ_CREDITOS +
VL_TOT_AJ_CREDITOS) com total de estorno de d�bito (VL_ESTORNOS_DEB) com saldo credor do per�odo anterior
(VL_SLD_CREDOR_ANT) for maior que �0� (zero), este campo deve ser preenchido com �0� (zero) e o campo 11
(VL_SLD_APURADO) deve ser igual ao valor do resultado. Se for menor que �0� (zero), o valor absoluto do resultado
deve ser informado neste campo e o campo VL_SLD_APURADO deve ser informado com �0� (zero).*/
            --
            gt_row_apuracao_icms.vl_saldo_credor_transp := nvl(gt_row_apuracao_icms.vl_saldo_credor_transp,0)
                                                           + (gt_row_apuracao_icms.vl_icms_recolher * (-1));
            --
            gt_row_apuracao_icms.vl_icms_recolher := 0;
            --
         end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_apur_icms.pkb_calc_apuracao_icms fase ( '||vn_fase||' ):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => gt_row_apuracao_icms.id
                                     , ev_obj_referencia  => gv_obj_referencia 
                                     );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_calc_apuracao_icms;

-------------------------------------------------------------------------------------------------------
--| Procedimento Montar Desenvolve Bahia
procedure pkb_monta_desenvolve_ba
is
   --
   vn_fase                  number := 0;
   vn_loggenerico_id        log_generico.id%type;
   vt_rel_desenv_ba         rel_desenv_ba%rowtype;
   vn_valor                 rel_det_desenv_ba.valor%type;
   vv_texto                 rel_det_desenv_ba.texto%type;
   vn_valor_acm_debito      number;
   vn_valor_acm_credito     number;
   vn_ajustapuracaoicms_id  ajust_apuracao_icms.id%type;
   vt_obrig_rec_apur_icms   obrig_rec_apur_icms%rowtype;
   vv_descr_compl_aj        ajust_apuracao_icms.descr_compl_aj%type;
   --
   cursor c_cfop is
   select c.cd
        , c.descr
        , i.*
     from cfop_param_des_ba i
        , cfop c
    where i.paramdesenvba_id = gt_param_desenv_ba.id
      and c.id = i.cfop_id
    order by c.cd;
   --
   cursor c_codaj is
   select c.cod_aj_apur
        , c.descr
        , i.*
     from codaj_param_des_ba i
        , cod_aj_saldo_apur_icms c
    where i.paramdesenvba_id = gt_param_desenv_ba.id
      and c.id = i.codajsaldoapuricms_id
    order by c.cod_aj_apur;
   --
   procedure pkb_ins_rel_det_desenv_ba ( en_reldesenvba_id  in rel_desenv_ba.id%type
                                       , en_dm_tipo         in rel_det_desenv_ba.dm_tipo%type
                                       , ev_texto           in rel_det_desenv_ba.texto%type
                                       , en_valor           in rel_det_desenv_ba.valor%type
                                       )
   is
      --
   begin
      --
      insert into rel_det_desenv_ba ( id
                                    , reldesenvba_id
                                    , dm_tipo
                                    , texto
                                    , valor
                                    )
                             values ( reldetdesenvba_seq.nextval --id
                                    , en_reldesenvba_id -- reldesenvba_id
                                    , en_dm_tipo -- dm_tipo
                                    , ev_texto -- texto
                                    , en_valor -- valor
                                    );
      --
   end pkb_ins_rel_det_desenv_ba;
   --
begin
   --
   vn_fase := 1;
   --
   if gv_sigla_estado = 'BA' then -- Sim � Bahia
      --
      vn_fase := 2;
      -- Existe Desenvolve no per�odo?
      begin
         --
         select *
           into gt_param_desenv_ba
           from param_desenv_ba
          where 1 = 1
            and empresa_id = gt_row_apuracao_icms.empresa_id
            and ( dt_ini <= gt_row_apuracao_icms.dt_inicio and dt_fin >= gt_row_apuracao_icms.dt_fim );
         --
      exception
         when dup_val_on_index then
            gt_param_desenv_ba := null;
            gv_mensagem_log := 'Erro localizado mais de um par�metro ativo para o Desenvolve Bahia fase ( '||vn_fase||' ):'||sqlerrm;
            pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                             , ev_mensagem        => gv_mensagem_log
                                             , ev_resumo          => gv_mensagem_log
                                             , en_tipo_log        => ERRO_DE_VALIDACAO
                                             , en_referencia_id   => gt_row_apuracao_icms.id
                                             , ev_obj_referencia  => gv_obj_referencia
                                             );
         when others then
            gt_param_desenv_ba := null;
      end;
      --
      vn_fase := 2.1;
      --
      if gt_param_desenv_ba.id > 0 then
         --
         vn_fase := 3;
         --
         vt_rel_desenv_ba := null;
         -- Cria o cabe�alho da Desenvolve Bahia
         begin
            --
            select reldesenvba_seq.nextval
              into vt_rel_desenv_ba.id
              from dual;
            --
         exception
            when others then
               vt_rel_desenv_ba.id := 0;
         end;
         --
         vt_rel_desenv_ba.apuracaoicms_id := gt_row_apuracao_icms.id;
         --
         vn_fase := 3.1;
         --
         insert into rel_desenv_ba ( id
                                   , apuracaoicms_id
                                   )
                            values ( vt_rel_desenv_ba.id --id
                                   , vt_rel_desenv_ba.apuracaoicms_id -- apuracaoicms_id
                                   );
         --
         vn_fase := 3.2;
         --
         vn_valor_acm_debito := 0;
         vn_valor_acm_credito := 0;
         --
         --| Monta os valores de D�bitos Fiscais e Cr�ditos Fiscais
         vn_fase := 4;
         --
         -- Recupera pelo CFOP
         for rec_cfop in c_cfop loop
            exit when c_cfop%notfound or (c_cfop%notfound) is null;
            --
            vn_fase := 4.1;
            --
            vn_valor := 0;
            vv_texto := null;
            --| recupera o valor do relat�rio de CFOP
            begin
               --
               select vl_imp_trib
                 into vn_valor
                 from rel_resumo_cfop
                where empresa_id  = gt_row_apuracao_icms.empresa_id
                  and usuario_id  = gn_usuario_id
                  and sigla_imp   = 'ICMS'
                  and cfop        = rec_cfop.cd;
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
            vn_fase := 4.2;
            --
            vv_texto := trim(substr(rec_cfop.cd || ' - ' || rec_cfop.descr, 1, 255));
            --
            vn_fase := 4.3;
            --
            pkb_ins_rel_det_desenv_ba ( en_reldesenvba_id  => vt_rel_desenv_ba.id
                                      , en_dm_tipo         => rec_cfop.dm_tipo
                                      , ev_texto           => vv_texto
                                      , en_valor           => vn_valor
                                      );
            --
            if rec_cfop.dm_tipo = 2 then -- Debito
               vn_valor_acm_debito := nvl(vn_valor_acm_debito,0) + nvl(vn_valor,0);
            else
               -- Credito
               vn_valor_acm_credito := nvl(vn_valor_acm_credito,0) + nvl(vn_valor,0);
            end if;
            --
         end loop;
         --
         vn_fase := 5;
         -- Por C�digos de Ajustes de Apura��o de ICMS
         for rec_codaj in c_codaj loop
            exit when c_codaj%notfound or (c_codaj%notfound) is null;
            --
            vn_fase := 5.1;
            --
            vn_valor := 0;
            vv_texto := null;
            -- Recupera o Valor do Ajuste da Apura��o de ICMS
            begin
               --
               select aai.vl_aj_apur
                 into vn_valor
                 from ajust_apuracao_icms        aai
                where aai.apuracaoicms_id        = gt_row_apuracao_icms.id
                  and aai.codajsaldoapuricms_id  = rec_codaj.codajsaldoapuricms_id;
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
            vn_fase := 5.2;
            --
            vv_texto := trim(substr(rec_codaj.cod_aj_apur || ' - ' || rec_codaj.descr, 1, 255));
            --
            vn_fase := 5.3;
            --
            pkb_ins_rel_det_desenv_ba ( en_reldesenvba_id  => vt_rel_desenv_ba.id
                                      , en_dm_tipo         => rec_codaj.dm_tipo
                                      , ev_texto           => vv_texto
                                      , en_valor           => vn_valor
                                      );
            --
            if rec_codaj.dm_tipo = 2 then -- Debito
               vn_valor_acm_debito := nvl(vn_valor_acm_debito,0) + nvl(vn_valor,0);
            else
               -- Credito
               vn_valor_acm_credito := nvl(vn_valor_acm_credito,0) + nvl(vn_valor,0);
            end if;
            --
         end loop;
         --
         vn_fase := 6;
         --
         -- D�bitos Fiscais
         vt_rel_desenv_ba.vl_dnvp := nvl(vn_valor_acm_debito,0);
         -- Cr�ditos Fiscais
         vt_rel_desenv_ba.vl_cnvp := nvl(vn_valor_acm_credito,0);
         --
         -- SDM - Saldo devedor mensal do ICMS A RECOLHER (A)
         vt_rel_desenv_ba.vl_sdm := gt_row_apuracao_icms.vl_icms_recolher;
         --
         vn_fase := 6.1;
         -- (=) SDPI - Saldo devedor Passivel de incentivo pelo DESENVOLVE (A-B+C)
         vt_rel_desenv_ba.vl_sdpi := nvl(vt_rel_desenv_ba.vl_sdm,0) - nvl(vt_rel_desenv_ba.vl_dnvp,0) + nvl(vt_rel_desenv_ba.vl_cnvp,0);
         --
         vn_fase := 6.2;
         -- INDICE DE DILA��O DA EMPRESA
         vt_rel_desenv_ba.perc_dilacao := nvl(gt_param_desenv_ba.perc_dilacao,0);
         --
         if nvl(vt_rel_desenv_ba.perc_dilacao,0) > 0 then
            -- Parcela dilatada Resol. 33/06
            vt_rel_desenv_ba.vl_parc_dilatada := nvl(vt_rel_desenv_ba.vl_sdpi,0) * (vt_rel_desenv_ba.perc_dilacao/100);
         else
            vt_rel_desenv_ba.vl_parc_dilatada := 0;
         end if;
         --
         vv_descr_compl_aj := 'Dila��o do prazo do icms autorizada pela resolu��o n� ' || nvl(trim(gt_param_desenv_ba.nro_aut),0)
                              || ' (Indicar o n�mero) do Conselho Deliberativo do DESENVOLVE com vencimento no dia ' || nvl(trim(gt_param_desenv_ba.dia_vcto),0)
                              || ', conforme art. 5�, � 2� do Decreto n� 8.205/02, Regulamento DESENVOLVE.';
         --
         vn_fase := 6.3;
         --
         if nvl(vt_rel_desenv_ba.vl_parc_dilatada,0) > 0 then
            -- Registre o Ajuste de Dedu��o da Parcela Dilatada
            vn_fase := 6.31;
            --
            -- verifica se exsite ajuste
            begin
               --
               select id
                 into vn_ajustapuracaoicms_id
                 from ajust_apuracao_icms
                where 1 = 1
                  and apuracaoicms_id        = gt_row_apuracao_icms.id
                  and codajsaldoapuricms_id  = gt_param_desenv_ba.codajsaldoapuricms_id_deducao;
               --
            exception
               when others then
                  vn_ajustapuracaoicms_id := 0;
            end;
            --
            vn_fase := 6.32;
            --
            if nvl(vn_ajustapuracaoicms_id,0) > 0 then
               -- Remove anteriores se houver
               delete from infor_ajust_apur_icms
                where ajustapuracaoicms_id = vn_ajustapuracaoicms_id;
               --
               delete from ajust_apuracao_icms
                where id = vn_ajustapuracaoicms_id;
               --
            end if;
            --
            vn_fase := 6.33;
            --
            insert into ajust_apuracao_icms ( id
                                            , apuracaoicms_id
                                            , codajsaldoapuricms_id
                                            , descr_compl_aj
                                            , vl_aj_apur
                                            )
                                     values ( ajustapuracaoicms_seq.nextval -- id
                                            , gt_row_apuracao_icms.id -- apuracaoicms_id
                                            , gt_param_desenv_ba.codajsaldoapuricms_id_deducao -- codajsaldoapuricms_id
                                            , vv_descr_compl_aj -- descr_compl_aj
                                            , vt_rel_desenv_ba.vl_parc_dilatada -- vl_aj_apur
                                            );
            --
            vn_fase := 6.34;
            --
            insert into infor_ajust_apur_icms ( id
                                              , ajustapuracaoicms_id
                                              , num_da
                                              , num_proc
                                              , origproc_id
                                              , descr_proc
                                              , txt_compl
                                              )
                                       values ( inforajustapuricms_seq.nextval --id
                                              , ajustapuracaoicms_seq.currval -- ajustapuracaoicms_id
                                              , nvl(trim(gt_param_desenv_ba.nro_aut),0) -- num_da
                                              , null -- num_proc
                                              , null -- origproc_id
                                              , vv_descr_compl_aj -- descr_proc
                                              , null -- txt_compl
                                              );
            --
            commit;
            --
         end if;
         --
         vn_fase := 6.4;
         --
         -- Re-calcula os valores de apura��o de icms
         -- Chama procedimento de c�lcular a apura��o de icms
         pkb_calc_apuracao_icms;
         --
         vn_fase := 6.5;
         -- Saldo Devedor conf. RAICMS
         vt_rel_desenv_ba.vl_sld_dev_raicms := vt_rel_desenv_ba.vl_sdm;
         --
         vn_fase := 6.6;
         -- (-) Dila��o
         vt_rel_desenv_ba.vl_dilacao := nvl(vt_rel_desenv_ba.vl_parc_dilatada,0);
         --
         vn_fase := 6.7;
         -- ICMS normal a recolher - Dia 09 m�s seguinte ao da apura��o
         vt_rel_desenv_ba.vl_icms_normal_rec := nvl(vt_rel_desenv_ba.vl_sld_dev_raicms,0) - nvl(vt_rel_desenv_ba.vl_dilacao,0);
         --
         vn_fase := 6.8;
         -- INDICE DE DESCONTO POR ANTECIPA��O (1o. M�S)
         vt_rel_desenv_ba.perc_desc := nvl(gt_param_desenv_ba.perc_desc,0);
         --
         vn_fase := 7;
         -- Valor a recolher ICMS DESENVOLVE at� dia 20 m�s seguinte ao da apura��o
         if nvl(vt_rel_desenv_ba.perc_desc,0) > 0
            and nvl(vt_rel_desenv_ba.vl_dilacao,0) > 0
            and nvl(gt_param_desenv_ba.dia_vcto,0) > 0 -- Dia do Pagamento
            then
            --
            vn_fase := 7.1;
            -- Verifica se existe Ajuste para o "Pagamento Antecipado".
            --
            if nvl(gt_param_desenv_ba.codajsaldoapuricms_id_deb_esp,0) > 0 then
               --
               vn_fase := 7.2;
               -- Verifica se existe obriga��o a recolher para c�digo receita 2167
               vt_obrig_rec_apur_icms := null;
               --
               begin
                  --
                  select obr.*
                    into vt_obrig_rec_apur_icms
                    from obrig_rec_apur_icms  obr
                       , aj_obrig_rec         aor
                       , cod_rec_uf           cru
                   where obr.apuracaoicms_id  = gt_row_apuracao_icms.id
                     and cru.id            (+)= obr.codrecuf_id
                     and cru.cod_rec          = '2167'
                     and aor.id               = obr.ajobrigrec_id
                     and aor.cd               = '090';
                  --
               exception
                  when others then
                     vt_obrig_rec_apur_icms := null;
               end;
               --
               vn_fase := 7.3;
               if nvl(vt_obrig_rec_apur_icms.id,0) > 0 then
                  --
                  vt_rel_desenv_ba.vl_icms_desenvolve_rec := nvl(vt_rel_desenv_ba.vl_dilacao,0) * ( 1 - (vt_rel_desenv_ba.perc_desc/100) );
                  --
                  vn_fase := 7.4;
                  --
                  -- Lan�a o ajuste
                  pkb_insere_ajust_apuracao_icms ( en_apuracaoicms_id        => gt_row_apuracao_icms.id
                                                 , en_codajsaldoapuricms_id  => gt_param_desenv_ba.codajsaldoapuricms_id_deb_esp
                                                 , ev_descr_compl_aj         => vv_descr_compl_aj
                                                 , en_subitemgia_id          => null
                                                 , en_vl_aj_apur             => vt_rel_desenv_ba.vl_icms_desenvolve_rec
                                                 );
                  --
                  vn_fase := 7.5;
                  --
                  -- Atualiza Obriga��o a recolher
                  update obrig_rec_apur_icms set VL_ORIG_REC = vt_rel_desenv_ba.vl_icms_desenvolve_rec
                   where id = vt_obrig_rec_apur_icms.id;
                  --
               else
                  --
                  vt_rel_desenv_ba.vl_icms_desenvolve_rec := nvl(vt_rel_desenv_ba.vl_dilacao,0);
                  vt_rel_desenv_ba.perc_desc := 0;
                  --
               end if;
               --
            else
               --
               vt_rel_desenv_ba.vl_icms_desenvolve_rec := nvl(vt_rel_desenv_ba.vl_dilacao,0);
               vt_rel_desenv_ba.perc_desc := 0;
               --
            end if;
            --
         else
            --
            vt_rel_desenv_ba.vl_icms_desenvolve_rec := nvl(vt_rel_desenv_ba.vl_dilacao,0);
            vt_rel_desenv_ba.perc_desc := 0;
            --
         end if;
         --
         vn_fase := 99;
         --
         update rel_desenv_ba set vl_sdm                  = vt_rel_desenv_ba.vl_sdm
                                , vl_dnvp                 = vt_rel_desenv_ba.vl_dnvp
                                , vl_cnvp                 = vt_rel_desenv_ba.vl_cnvp
                                , vl_sdpi                 = vt_rel_desenv_ba.vl_sdpi
                                , perc_dilacao            = vt_rel_desenv_ba.perc_dilacao
                                , vl_parc_dilatada        = vt_rel_desenv_ba.vl_parc_dilatada
                                , vl_sld_dev_raicms       = vt_rel_desenv_ba.vl_sld_dev_raicms
                                , vl_dilacao              = vt_rel_desenv_ba.vl_dilacao
                                , vl_icms_normal_rec      = vt_rel_desenv_ba.vl_icms_normal_rec
                                , perc_desc               = vt_rel_desenv_ba.perc_desc
                                , vl_icms_desenvolve_rec  = vt_rel_desenv_ba.vl_icms_desenvolve_rec
          where id = vt_rel_desenv_ba.id;
         --
         commit;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_apur_icms.pkb_monta_desenvolve_ba fase ( '||vn_fase||' ):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_SISTEMA
                                          , en_referencia_id   => gt_row_apuracao_icms.id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_monta_desenvolve_ba;

-------------------------------------------------------------------------------------------------------
--| Procedimento faz a apura��o do ICMS
procedure pkb_apuracao ( en_apuracaoicms_id in apuracao_icms.id%type )
is
   --
   vn_fase             number := 0;
   vn_loggenerico_id   log_generico.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_apuracaoicms_id,0) > 0 then
      --
      vn_fase := 2;
      --
      gn_usuario_id := 0;
      -- pega o usu�rio do MultOrg da Empresa
      begin
         --
         select mo.usuario_id
           into gn_usuario_id
           from apuracao_icms ai
              , empresa e
              , mult_org mo
          where ai.id = en_apuracaoicms_id
            and e.id = ai.empresa_id
            and mo.id = e.multorg_id;
         --
      exception
         when others then
            gn_usuario_id := null;
      end;
      --
      vn_fase := 2.1;
      --
      if nvl(gn_usuario_id,0) > 0 then
         --
         pkb_rel_resumo_cfop ( en_apuracaoicms_id => en_apuracaoicms_id
                             , en_usuario_id      => gn_usuario_id
                             );
         --
      end if;
      --
      vn_fase := 2.2;
      -- recupera os dados da apura��o de imposto
      pkb_dados_apuracao_icms ( en_apuracaoicms_id => en_apuracaoicms_id );
      --
      vn_fase := 3;
      --
      if nvl(gt_row_apuracao_icms.id,0) > 0 then
         --
         vn_fase := 4;
         --| chama procedimento que gera o Registro C190 de Nota Fiscal
         pk_csf_api.pkb_gera_C190 ( en_empresa_id => gt_row_apuracao_icms.empresa_id
                                  , ed_dt_ini     => gt_row_apuracao_icms.dt_inicio
                                  , ed_dt_fin     => gt_row_apuracao_icms.dt_fim
                                  );
         --
         vn_fase := 5;
         -- Cria ajuste do CIAP
         pkb_criar_ajuste_ciap;
         --
         vn_fase := 6;
         -- Monta como deve ser o DIFAL
         pkb_monta_difal;
         --
         -- Chama procedimento de c�lcular a apura��o de icms
         pkb_calc_apuracao_icms;
         --
         vn_fase := 21;
         --
         if nvl(gt_row_apuracao_icms.vl_icms_recolher,0) > 0 then
            --
            -- Procedimento Montar Desenvolve Bahia
            pkb_monta_desenvolve_ba;
            --
         end if;
         --
-------------------------------------------------------------------------------------------------------
         --
         vn_fase := 22;
         --
         -- 15-DEB_ESP
         /*Campo 15 � Preenchimento: Informar o correspondente ao somat�rio dos valores:
a) de ICMS correspondentes aos documentos fiscais extempor�neos (COD_SIT igual a �01�) e das notas fiscais
complementares extempor�neas (COD_SIT igual a �07�);
b) de ajustes do campo VL_ICMS do registro C197, se o terceiro caracter do c�digo informado no campo COD_AJ
do registro C197 for igual a �7� (d�bitos especiais) e o quarto caracter for igual a �0� ou �2� (opera��es pr�prias
ou outras apura��es) referente aos documentos compreendidos no per�odo a que se refere a escritura��o; e
c) de ajustes do campo VL_AJ_APUR do registro E111, se o terceiro caracter do c�digo informado no campo
COD_AJ_APUR do registro E111 for igual a �0� (apura��o ICMS pr�prio) e o quarto caracter for igual a �5�(d�bito especial).*/
         --
         gt_row_apuracao_icms.vl_deb_esp := nvl(fkg_soma_cred_ext_op_c,0)
                                            + nvl(fkg_soma_cred_ext_op_d,0)
                                            + nvl(fkg_soma_dep_esp_c197_d197,0)
                                            + nvl(fkg_soma_dep_esp_e111,0);
         --
-------------------------------------------------------------------------------------------------------
         --
         vn_fase := 23;
         --
         update apuracao_icms set dm_situacao             = 1 -- Calculada
                                , vl_total_debito         = nvl(gt_row_apuracao_icms.vl_total_debito,0)
                                , vl_ajust_debito         = nvl(gt_row_apuracao_icms.vl_ajust_debito,0)
                                , vl_total_ajust_deb      = nvl(gt_row_apuracao_icms.vl_total_ajust_deb,0)
                                , vl_estorno_credito      = nvl(gt_row_apuracao_icms.vl_estorno_credito,0)
                                , vl_total_credito        = nvl(gt_row_apuracao_icms.vl_total_credito,0)
                                , vl_ajust_credito        = nvl(gt_row_apuracao_icms.vl_ajust_credito,0)
                                , vl_total_ajust_cred     = nvl(gt_row_apuracao_icms.vl_total_ajust_cred,0)
                                , vl_estorno_debido       = nvl(gt_row_apuracao_icms.vl_estorno_debido,0)
                                , vl_saldo_credor_ant     = nvl(gt_row_apuracao_icms.vl_saldo_credor_ant,0)
                                , vl_saldo_apurado        = nvl(gt_row_apuracao_icms.vl_saldo_apurado,0)
                                , vl_total_deducao        = nvl(gt_row_apuracao_icms.vl_total_deducao,0)
                                , vl_icms_recolher        = nvl(gt_row_apuracao_icms.vl_icms_recolher,0)
                                , vl_saldo_credor_transp  = nvl(gt_row_apuracao_icms.vl_saldo_credor_transp,0)
                                , vl_deb_esp              = nvl(gt_row_apuracao_icms.vl_deb_esp,0)
          where id           = gt_row_apuracao_icms.id
            and dm_situacao  = 0; -- Aberta
         --
         vn_fase := 24;
         --
         commit;
         --
         vn_fase := 25;
         --
         gv_resumo_log := 'C�lculo da Apura��o de ICMS realizado com sucesso!';
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => INFO_APUR_IMPOSTO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      update apuracao_icms set dm_situacao = 2 -- Erro no Calculo
       where id = en_apuracaoicms_id;
      --
      commit;
      --
      gv_mensagem_log := 'Erro na pk_apur_icms.pkb_apuracao fase ( '||vn_fase||' ):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_apuracaoicms_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_apuracao;

-------------------------------------------------------------------------------------------------------
--| Procedimento faz a execu��o da montagem de dados para o relat�rio de resumo por cfop
procedure pkb_rel_resumo_cfop ( en_apuracaoicms_id in apuracao_icms.id%type
                              , en_usuario_id      in neo_usuario.id%type )
is
   --
   vn_fase number := 0;
   --
begin
   --
   vn_fase := 1;
   -- recupera os dados da apura��o de imposto
   pkb_dados_apuracao_icms ( en_apuracaoicms_id => en_apuracaoicms_id );
   --
   vn_fase := 2;
   --
   if nvl(gt_row_apuracao_icms.id,0) > 0 then
      --
      vn_fase := 3;
      --
      pb_rel_resumo_cfop ( en_empresa_id  => gt_row_apuracao_icms.empresa_id
                         , en_usuario_id  => en_usuario_id
                         , en_tipoimp_id  => pk_csf.fkg_tipo_imposto_id ( 1 ) -- fun��o para retornar o identificador do tipo de imposto 1-ICMS
                         , en_cfop_id     => null
                         , ed_dt_ini      => gt_row_apuracao_icms.dt_inicio
                         , ed_dt_fin      => gt_row_apuracao_icms.dt_fim
                         , en_consol_empr => 0 ); -- 0-n�o, 1-sim
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_apur_icms.pkb_rel_resumo_cfop fase ( '||vn_fase||' ):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_apuracaoicms_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_rel_resumo_cfop;

-------------------------------------------------------------------------------------------------------
--
-- Procedure para Gera��o da Guia de Pagamento de Imposto
--
procedure pkg_gera_guia_pgto (en_apuracaoicms_id apuracao_icms.id%type,
                              en_usuario_id      neo_usuario.id%type) 
is
   --       
   vn_fase              number := 0;       
   vt_csf_log_generico  dbms_sql.number_table;
   vn_guiapgtoimp_id    guia_pgto_imp.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   -- Gera��o das Guias do Imposto ICMS ---
   for x in (
      select ora.id obrigrecapuricms_id,ai.id apuracaoicms_id,  pdgi.empresa_id_guia, pdgi.obs,
             e.pessoa_id, ai.dt_inicio, ai.dt_fim, pdgi.pessoa_id_sefaz, pdgi.dm_origem, pdgi.dm_tipo,
             sum(ora.vl_orig_rec) vl_orig_rec
         from OBRIG_REC_APUR_ICMS  ora,
              APURACAO_ICMS         ai,
              PARAM_GUIA_PGTO      pgp,
              PARAM_DET_GUIA_IMP  pdgi,
              EMPRESA                e
      where ai.id                 = ora.apuracaoicms_id
        and pgp.empresa_id        = ai.empresa_id
        and pdgi.paramguiapgto_id = pgp.id
        and pdgi.tipoimp_id       = pk_csf.fkg_Tipo_Imposto_id(1) -- ICMS
        and e.id                  = pdgi.empresa_id_guia
        and ai.id                 = en_apuracaoicms_id
      group by ai.id, ora.id, pdgi.empresa_id_guia, pdgi.obs,
               e.pessoa_id, ai.dt_inicio, ai.dt_fim, pdgi.pessoa_id_sefaz, pdgi.dm_origem, pdgi.dm_tipo)
   loop
      --
      vn_fase := 2;
      --
      if nvl(x.vl_orig_rec,0) > 0 then
         -- Popula a Vari�vel de Tabela -- 
         pk_csf_api_gpi.gt_row_guia_pgto_imp.id                       := null;                          
         pk_csf_api_gpi.gt_row_guia_pgto_imp.empresa_id               := x.empresa_id_guia;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.usuario_id               := en_usuario_id;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_situacao              := 0;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.tipoimposto_id           := pk_csf.fkg_Tipo_Imposto_id(1); -- ICMS
         pk_csf_api_gpi.gt_row_guia_pgto_imp.tiporetimp_id            := null;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.tiporetimpreceita_id     := null;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.pessoa_id                := x.pessoa_id;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_tipo                  := x.dm_tipo;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_origem                := x.dm_origem;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.nro_via_impressa         := 1;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.dt_ref                   := x.dt_inicio;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.dt_vcto                  := x.dt_fim;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_princ                 := x.vl_orig_rec;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_multa                 := 0;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_juro                  := 0;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_outro                 := 0;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_total                 := x.vl_orig_rec;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.obs                      := x.obs;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.pessoa_id_sefaz          := x.pessoa_id_sefaz;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.nro_tit_financ           := null;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.dt_alteracao             := sysdate;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_ret_erp               := 0;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.id_erp                   := null;
         --
         vn_fase := 2.1;
         --
         vn_guiapgtoimp_id := 0;
         --
         -- Chama a procedure de integra��o e finaliza��o da guia
         pk_csf_api_pgto_imp_ret.pkb_finaliza_pgto_imp_ret(est_log_generico  => vt_csf_log_generico,
                                                           en_empresa_id     => x.empresa_id_guia,
                                                           en_dt_ini         => x.dt_inicio,
                                                           en_dt_fim         => x.dt_fim,
                                                           sn_guiapgtoimp_id => vn_guiapgtoimp_id);
         --
         vn_fase := 2.2;
         --
         -- Atualiza o id da guia de pagamento
         update OBRIG_REC_APUR_ICMS ora set
            ora.guiapgtoimp_id = vn_guiapgtoimp_id
         where ora.id = x.obrigrecapuricms_id;   
         --
         vn_fase := 2.3;
         --
         -- Atualiza o flag de gera��o de guia
         update APURACAO_ICMS ai set
            ai.dm_situacao_guia = 1
         where ai.id = x.apuracaoicms_id;   
         --
      end if;
      --
   end loop;   
   --
   commit;
   --
exception
   when others then
      gv_mensagem_log := 'Erro na pk_apur_iss.pkg_gera_guia_pgto fase('||vn_fase||'): '||sqlerrm;
      pkb_grava_log_generico(en_apuracaoicms_id, ERRO_DE_SISTEMA);   
      --     
end pkg_gera_guia_pgto; 
--
-------------------------------------------------------------------------------------------------------
-- Procedure para Estorno da Guia de Pagamento de Imposto
procedure pkg_estorna_guia_pgto (en_apuracaoicms_id apur_iss_simplificada.id%type,
                                 en_usuario_id neo_usuario.id%type)  
is
   --
   vn_fase              number := 0;       
   vt_csf_log_generico  dbms_sql.number_table;
   --
begin
   --
   for x in (
      select * 
         from APURACAO_ICMS ai
      where ai.id = en_apuracaoicms_id)
   loop   
      pk_csf_api_pgto_imp_ret.pkb_estorna_pgto_imp_ret(est_log_generico => vt_csf_log_generico,
                                                       en_empresa_id    => x.empresa_id,
                                                       en_dt_ini        => x.dt_inicio,
                                                       en_dt_fim        => x.dt_fim,
                                                       en_pgtoimpret_id => null);
      --  
      if nvl(vt_csf_log_generico.count,0) > 0 then
         --
         vn_fase := 3.1;
         --
         update guia_pgto_imp t set
           t.dm_situacao = 2 -- Erro de Valida��o
         , t.usuario_id  = en_usuario_id  
         where t.empresa_id = x.empresa_id
           and t.dt_ref between x.dt_inicio 
                            and x.dt_fim;
         --
      else
         --
         vn_fase := 3.2;
         --
         update guia_pgto_imp t set
              t.dm_situacao = 3 -- Cancelado
            , t.usuario_id  = en_usuario_id  
         where t.empresa_id = x.empresa_id
           and t.dt_ref between x.dt_inicio 
                            and x.dt_fim;
         --      
         vn_fase := 3.3;
         --
         -- Atualiza o flag de gera��o de guia
         update APURACAO_ICMS ai set
            ai.dm_situacao_guia = 0
         where ai.id = en_apuracaoicms_id;   
         --
      end if;                                                           
      -- 
   end loop;
   --   
   commit;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_apur_iss.pkg_estorna_guia_pgto fase('||vn_fase||'): '||sqlerrm;
      pkb_grava_log_generico(en_apuracaoicms_id, ERRO_DE_SISTEMA);   
      --                                                          
end pkg_estorna_guia_pgto; 
--
-------------------------------------------------------------------------------------------------------
--
end pk_apur_icms;
/
