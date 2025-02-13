      DECLARE @DataInicial DateTime
      DECLARE @DataFinal DateTime
      DECLARE @DescontarKMSuprimida CHAR(1)

      
      SET @DataInicial = '2024-01-01'
      SET @DataFinal = GETDATE()
      SET @DescontarKMSuprimida = 'N'
      
      SELECT
        D.Empresa,
        D.Estabelecimento,
        'Escala' Origem,
        EP.OIDFCVProgramada,
        EP.OIDHistoricoJornada,
        F.DataOperacao,
        F.LinhaCodigo,
        HL.Descricao as LinhaDescricao,
        F.TabelaCodigo,
        F.Jornada,
        CE.TipoTarefa,
        HJ.HoraInicio HoraInicioJornada,
        HJ.HoraFim HoraFimJornada,
        HJ.Duracao DuracaoJornada,
        ISNULL(HJ.Viagens,0) Viagens,
        HJ.KmJornada
	  INTO #FcvTemporaria
      FROM
        EscalaProgramada EP
      INNER JOIN FCVProgramada F  
        ON F.OIDFCVProgramada = EP.OIDFCVProgramada
      INNER JOIN HistoricoProjetoMov HPM  
        ON HPM.OIDHistoricoProjetoMov = EP.OIDHistoricoProjetoMov
      INNER JOIN HistoricoProjeto HP  
        ON HP.OIDHistoricoProjeto = HPM.OIDHistoricoProjeto
      INNER JOIN ProjetoEscala PE  
        ON PE.OIDDocumento = HP.OIDDocumento
      INNER JOIN GrupoProjetoEscala GPE  
        ON GPE.OIDGrupoProjetoEscala = PE.OIDGrupoProjetoEscala
      INNER JOIN CargoEscala CE  
        ON CE.OIDCargoEscala = GPE.OIDCargoEscala
      INNER JOIN HistoricoJornada HJ  
        ON HJ.OIDHistoricoJornada = EP.OIDHistoricoJornada
      INNER JOIN HistoricoTabela HT  
        ON HT.OIDHistoricoTabela = HJ.OIDHistoricoTabela
      INNER JOIN HistoricoLinha HL  
        ON HL.OIDHistoricoLinha = HT.OIDHistoricoLinha
      INNER JOIN Documento D 
        ON D.OIDDocumento = PE.OIDDocumento
      WHERE
      
          EXISTS (SELECT EPM.OIDEscalaProgramadaMov FROM EscalaProgramadaMov EPM WHERE EPM.OIDEscalaProgramada = EP.OIDEscalaProgramada)
         AND
        CE.TipoTarefa = 'M' AND
        F.DataOperacao >= @DataInicial AND
        F.DataOperacao <= @DataFinal
      
      UNION ALL
      
      SELECT
        D.Empresa,
        D.Estabelecimento,
        'Especial     '+D.OIDDocumento Origem,
        EEE.OIDDocumento OIDFCVProgramada,
        NULL OIDHistoricoJornada,
      
          CONVERT(DATETIME, CONVERT(CHAR(10), EEE.DtHoraInicio, 120)) DataOperacao,
        L.Codigo LinhaCodigo,
        L.Descricao,
        EEE.Tabela TabelaCodigo,
        EEE.Jornada,
        'M' TipoTarefa,
        '' HoraInicioJornada,
        '' HoraFimJornada,
        ''  DuracaoJornada,
        ISNULL(EEE.Viagens,0) Viagens,
        ISNULL(EEE.KmPrevista,0) KMJornada
      FROM
        EscalaEventoEspecial EEE 
        INNER JOIN Documento D ON D.OIDDocumento = EEE.OIDDocumento
        INNER JOIN Linha L ON L.OIDLinha = EEE.OIDLinha
      WHERE
      
          CONVERT(DATETIME, CONVERT(CHAR(10), EEE.DtHoraInicio, 120)) >=  @DataInicial 
        AND
      
          CONVERT(DATETIME, CONVERT(CHAR(10), EEE.DtHoraInicio, 120)) <= @DataFinal
      SELECT DISTINCT
        *,
        (ViagensRealizadas - Viagens) DiferencaViagens,
         DBO.AsMinutos(TempoParado) TempoParadoMinutos
      INTO #FCVProgReal
      FROM
      (
      SELECT
        *,
        CASE
          WHEN KMTotalProgramada <> 0 THEN
             (KMRealizado * Viagens / KMTotalProgramada)
          ELSE
             (KMRealizado * Viagens)
        END ViagensRealizadas,
        (KMRealizado - KmTotalProgramada) Diferenca
      FROM
      (
      SELECT
        Movimento.Empresa,
        Movimento.Estabelecimento,
        Movimento.Origem,
        Movimento.DataOperacao,
        Movimento.LinhaCodigo,
        Movimento.LinhaDescricao Descricao,
        Movimento.TabelaCodigo,
        Movimento.Jornada,
        Movimento.HoraInicioEscala,
        Movimento.HoraInicioJornada,
        Movimento.HoraFimJornada,
        Movimento.DuracaoJornada,
        Movimento.HoraFimEscala,
        CASE
      
            WHEN DBO.AsMinutos(Movimento.HoraInicioEscala) > DBO.AsMinutos(Movimento.HoraFimEscala) THEN
      
              DBO.AsHoras(DBO.AsMinutos(Movimento.HoraFimEscala) - (DBO.AsMinutos(Movimento.HoraInicioEscala) - 1440))
          ELSE
              DBO.AsHoras(DBO.AsMinutos(Movimento.HoraFimEscala) - DBO.AsMinutos(Movimento.HoraInicioEscala))
          END DuracaoEscala,
        CASE
      
            WHEN DBO.AsMinutos(Movimento.HoraInicioEscala) > DBO.AsMinutos(Movimento.HoraFimEscala) THEN
      
              DBO.AsMinutos(Movimento.HoraFimEscala) - (DBO.AsMinutos(Movimento.HoraInicioEscala) - 1440)
          ELSE
      
              DBO.AsMinutos(Movimento.HoraFimEscala) - DBO.AsMinutos(Movimento.HoraInicioEscala)
          END DuracaoMinutosEscala,
      
        Movimento.KMProgramadaJornada,
        Movimento.KMMorta,
      
          (Movimento.KMProgramadaJornada + Movimento.KmMorta) KMTotalProgramada,
        Movimento.Viagens,   
        Movimento.HoraInicioRealizado,
        Movimento.HoraFimRealizado,
        CASE
          WHEN Movimento.Origem = 'Escala' THEN
            CASE
      
                WHEN DBO.AsMinutos(Movimento.HoraInicioRealizado) > DBO.AsMinutos(Movimento.HoraFimRealizado) THEN
      
                  DBO.AsHoras(DBO.AsMinutos(Movimento.HoraFimRealizado) - DBO.AsMinutos(Movimento.HoraInicioRealizado) - 1440)
              ELSE
      
                  DBO.AsHoras(DBO.AsMinutos(Movimento.HoraFimRealizado) - DBO.AsMinutos(Movimento.HoraInicioRealizado))
            END
          ELSE 
            (SELECT 
      
                DBO.ASHoras(DATEDIFF(minute, EEE2.DtHoraInicio, EEE2.DTHoraFim))
             FROM
               EscalaEventoEspecial EEE2
             INNER JOIN Documento D2
               ON D2.OIDDocumento = EEE2.OIDDocumento  
             WHERE
               D2.Estabelecimento = Movimento.Estabelecimento AND
               EEE2.OIDDocumento = Movimento.OIDFCVProgramada)
        END DuracaoRealizado,
        CASE
          WHEN Movimento.Origem = 'Escala' THEN
            CASE
      
                WHEN DBO.AsMinutos(Movimento.HoraInicioRealizado) > DBO.AsMinutos(Movimento.HoraFimRealizado) THEN
      
                  DBO.AsMinutos(Movimento.HoraFimRealizado) - DBO.AsMinutos(Movimento.HoraInicioRealizado) - 1440
              ELSE
      
                  DBO.AsMinutos(Movimento.HoraFimRealizado) - DBO.AsMinutos(Movimento.HoraInicioRealizado)
            END
          ELSE 
            (SELECT 
              DATEDIFF(minute, EEE2.DtHoraInicio, EEE2.DTHoraFim)
             FROM
               EscalaEventoEspecial EEE2
             INNER JOIN Documento D2
               ON D2.OIDDocumento = EEE2.OIDDocumento
             WHERE
               D2.Estabelecimento = Movimento.Estabelecimento AND
               EEE2.OIDDocumento = Movimento.OIDFCVProgramada)
        END DuracaoRealizadoMinutos,
      
        CASE
          WHEN Movimento.Origem = 'Escala' THEN
            ISNULL(
            (SELECT
              SUM(EU.ValorReal - EU.AnteriorEscalaProgramada)
            FROM
              vEQuipamentoUtilizacao EU
            INNER JOIN Equipamento E
              ON E.OIDBem = EU.OIDBem
            INNER JOIN TipoRegistrador TR
              ON TR.OIDTipoRegistrador = E.OIDTipoRegistrador
            INNER JOIN EscalaProgramada EP
              ON EP.OIDEscalaProgramada = EU.OIDEscalaProgramada
            INNER JOIN Documento D
              ON D.OIDDocumento = EP.OIDDocumento
            WHERE
              D.Estabelecimento = Movimento.Estabelecimento AND
              TR.Sigla = 'KM' AND
              EP.OIDFCVProgramada = Movimento.OIDFCVProgramada),0)
          ELSE
            ISNULL(
            (SELECT
              SUM(EU.ValorReal - EU.AnteriorDocumento)
            FROM
              vEQuipamentoUtilizacao EU
            INNER JOIN Equipamento E
              ON E.OIDBem = EU.OIDBem
            INNER JOIN TipoRegistrador TR
              ON TR.OIDTipoRegistrador = E.OIDTipoRegistrador
            INNER JOIN Documento D
              ON D.OIDDocumento = EU.OIDDocumento
            WHERE
              TR.Sigla = 'KM' AND
              D.Estabelecimento = Movimento.Estabelecimento AND
              EU.OIDDocumento = Movimento.OIDFCVProgramada),0)
        END KMRealizado,
        DBO.AsHoras(Movimento.TempoParado) TempoParado
      FROM
      (
      SELECT
        F.Empresa,
        F.Estabelecimento,
        F.Origem,
        F.OIDFCVProgramada,
        F.DataOperacao,
        F.LinhaCodigo,
        F.LinhaDescricao,
        F.TabelaCodigo,
        F.Jornada,
        F.TipoTarefa,
        (SELECT TOP 1
           _EPM.HoraInicio
         FROM
           EscalaProgramadaMov _EPM
         INNER JOIN EscalaProgramada _EP
           ON _EP.OIDEscalaProgramada = _EPM.OIDEscalaProgramada
         INNER JOIN HistoricoProjetoMov _HPM 
           ON _HPM.OIDHistoricoProjetoMov = _EP.OIDHistoricoProjetoMov
         INNER JOIN HistoricoProjeto _HP
           ON _HP.OIDHistoricoProjeto = _HPM.OIDHistoricoProjeto
         INNER JOIN ProjetoEscala _PE
           ON _PE.OIDDocumento = _HP.OIDDocumento
         INNER JOIN Documento _D
           ON _D.OIDDocumento = _PE.OIDDocumento
         INNER JOIN GrupoProjetoEscala _GPE
           ON _GPE.OIDGrupoProjetoEscala = _PE.OIDGrupoProjetoEscala
         INNER JOIN CargoEscala _CE
           ON _CE.OIDCargoEscala = _GPE.OIDCargoEscala
         WHERE
           _D.Empresa = F.Empresa AND
           _D.Estabelecimento = F.Estabelecimento AND
           _EP.OIDFCVProgramada = F.OIDFCVProgramada AND
           _CE.TipoTarefa = F.TipoTarefa
         ORDER BY _EPM.HoraInicioTabela) HoraInicioEscala,
        F.HoraInicioJornada,
        F.HoraFimJornada,
        (SELECT TOP 1
           _EPM.HoraFim
         FROM
           EscalaProgramadaMov _EPM
         INNER JOIN EscalaProgramada _EP
           ON _EP.OIDEscalaProgramada = _EPM.OIDEscalaProgramada
         INNER JOIN HistoricoProjetoMov _HPM 
           ON _HPM.OIDHistoricoProjetoMov = _EP.OIDHistoricoProjetoMov
         INNER JOIN HistoricoProjeto _HP
           ON _HP.OIDHistoricoProjeto = _HPM.OIDHistoricoProjeto
         INNER JOIN ProjetoEscala _PE
           ON _PE.OIDDocumento = _HP.OIDDocumento
         INNER JOIN Documento _D
           ON _D.OIDDocumento = _PE.OIDDocumento
         INNER JOIN GrupoProjetoEscala _GPE
           ON _GPE.OIDGrupoProjetoEscala = _PE.OIDGrupoProjetoEscala
         INNER JOIN CargoEscala _CE
           ON _CE.OIDCargoEscala = _GPE.OIDCargoEscala      
         WHERE
           _D.Empresa = F.Empresa AND
           _D.Estabelecimento = F.Estabelecimento AND
           _EP.OIDFCVProgramada = F.OIDFCVProgramada AND
           _CE.TipoTarefa = F.TipoTarefa
         ORDER BY _EPM.HoraFim DESC) HoraFimEscala,
        F.DuracaoJornada,
        CASE 
          WHEN @DescontarKMSuprimida = 'S' THEN
          (
            SELECT
              CASE
                WHEN ISNULL(SUM(_C.KmSuprimida),0) <= F.KMJornada THEN 
                  F.KMJornada - ISNULL(SUM(_C.KmSuprimida),0) 
                ELSE 0
              END KmSuprimida
            FROM
            (
            SELECT
              ISNULL(
              (SELECT
                SUM(ISNULL(_HH.KMPontoaPonto,0))
               FROM
                HistoricoHorario _HH
               WHERE
                _HH.OIDHistoricoJornada = _EP.OIDHistoricoJornada AND
      
                  DBO.AsMinutos(_HH.Hora) > DBO.AsMinutos(_EPM.HoraInicioTabela) AND
                DBO.AsMinutos(_HH.Hora) <= DBO.AsMinutos(_EPM.HoraFimTabela)
              ),0) KmSuprimida
            FROM 
              EscalaProgramadaMov _EPM
            INNER JOIN EscalaProgramada _EP
              ON _EP.OIDEscalaProgramada = _EPM.OIDEscalaProgramada
          INNER JOIN HistoricoProjetoMov _HPM
      
              ON _HPM.OIDHistoricoProjetoMov = _EP.OIDHistoricoProjetoMov
          INNER JOIN HistoricoProjeto _HP
            ON _HP.OIDHistoricoProjeto = _HPM.OIDHistoricoProjeto
          INNER JOIN ProjetoEscala _PE
            ON _PE.OIDDocumento = _HP.OIDDocumento
          INNER JOIN GrupoProjetoEscala _GPE
            ON _GPE.OIDGrupoProjetoEscala = _PE.OIDGrupoProjetoEscala
          INNER JOIN CargoEscala _CE
            ON _CE.OIDCargoEscala = _GPE.OIDCargoEscala
            WHERE
              _EP.OIDFcvProgramada = F.OIDFCVProgramada AND
            _CE.TipoTarefa = 'M' AND
              ISNULL(_EPM.IndSuprimido,'N') = 'S'
            ) _C
          )
        ELSE
          F.KMJornada
        END KMProgramadaJornada,
        F.Viagens,
        (SELECT TOP 1 _ERE.HoraInicio
         FROM
           EscalaRealizadaEquipamento _ERE
         INNER JOIN EscalaProgramadaMov _EPM
      
             ON _EPM.OIDEscalaProgramadaMov = _ERE.OIDEscalaProgramadaMov
         INNER JOIN EscalaProgramada _EP
           ON _EP.OIDEscalaProgramada = _EPM.OIDEscalaProgramada
         INNER JOIN HistoricoProjetoMov _HPM 
           ON _HPM.OIDHistoricoProjetoMov = _EP.OIDHistoricoProjetoMov
         INNER JOIN HistoricoProjeto _HP
           ON _HP.OIDHistoricoProjeto = _HPM.OIDHistoricoProjeto
         INNER JOIN ProjetoEscala _PE
           ON _PE.OIDDocumento = _HP.OIDDocumento
         INNER JOIN Documento _D
           ON _D.OIDDocumento = _PE.OIDDocumento
         INNER JOIN GrupoProjetoEscala _GPE
           ON _GPE.OIDGrupoProjetoEscala = _PE.OIDGrupoProjetoEscala
         INNER JOIN CargoEscala _CE
           ON _CE.OIDCargoEscala = _GPE.OIDCargoEscala
         WHERE
           _ERE.HoraInicio <> _ERE.HoraFim AND
           _D.Empresa = F.Empresa AND
           _D.Estabelecimento = F.Estabelecimento AND
           _EP.OIDFCVProgramada = F.OIDFCVProgramada AND
           _CE.TipoTarefa = F.TipoTarefa
      
           ORDER BY _EPM.HoraInicioTabela, _ERE.Sequencia) HoraInicioRealizado,
        (SELECT TOP 1 _ERE.HoraFim
         FROM
           EscalaRealizadaEquipamento _ERE
         INNER JOIN EscalaProgramadaMov _EPM
      
             ON _EPM.OIDEscalaProgramadaMov = _ERE.OIDEscalaProgramadaMov
         INNER JOIN EscalaProgramada _EP
           ON _EP.OIDEscalaProgramada = _EPM.OIDEscalaProgramada
         INNER JOIN HistoricoProjetoMov _HPM 
           ON _HPM.OIDHistoricoProjetoMov = _EP.OIDHistoricoProjetoMov
         INNER JOIN HistoricoProjeto _HP
           ON _HP.OIDHistoricoProjeto = _HPM.OIDHistoricoProjeto
         INNER JOIN ProjetoEscala _PE
           ON _PE.OIDDocumento = _HP.OIDDocumento
         INNER JOIN Documento _D
           ON _D.OIDDocumento = _PE.OIDDocumento
         INNER JOIN GrupoProjetoEscala _GPE
           ON _GPE.OIDGrupoProjetoEscala = _PE.OIDGrupoProjetoEscala
         INNER JOIN CargoEscala _CE
           ON _CE.OIDCargoEscala = _GPE.OIDCargoEscala
         WHERE
           _ERE.HoraInicio <> _ERE.HoraFim AND
           _D.Empresa = F.Empresa AND
           _D.Estabelecimento = F.Estabelecimento AND
           _EP.OIDFCVProgramada = F.OIDFCVProgramada AND
           _CE.TipoTarefa = F.TipoTarefa
      
           ORDER BY _EPM.HoraInicioTabela DESC, _ERE.Sequencia DESC) HoraFimRealizado,
        ISNULL(
         (SELECT 
           SUM(HH.KMMorta) 
         FROM
           HistoricoHorario HH
         WHERE
           HH.OIDHistoricoJornada = F.OIDHistoricoJornada),0) KMMorta,
        ISNULL(
         (SELECT 
      
             SUM(DBO.AsMinutos(HH.Hora) - DBO.AsMinutos(HH.HoraChegada))        
         FROM
           HistoricoHorario HH
         WHERE
      
             HH.OIDHistoricoJornada = F.OIDHistoricoJornada),0) TempoParado
      FROM
        #FcvTemporaria F
      ) Movimento  
      ) V
      ) C
      WHERE
      
          (C.KmRealizado IS NOT NULL AND C.KMTotalProgramada IS NOT NULL) 
      ORDER BY 
        C.Origem,
        C.DataOperacao, 
        C.LinhaCodigo, 
        C.TabelaCodigo,
        C.Jornada
      
      IF @DescontarKMSuprimida = 'S'
      BEGIN
        UPDATE #FCVProgReal
          SET KMMorta = 0,
              Viagens = 0,
              KMTotalProgramada = 0,
              Diferenca = 0,
              DiferencaViagens = 0
        WHERE
          KMProgramadaJornada = 0
      END
      
      SELECT
        C.Estabelecimento,
        C.DataOperacao,
        C.LinhaCodigo,
        C.Descricao,
        C.KMProgramadaJornada,
        C.KMMorta,
        C.KMTotalProgramada,
        C.Viagens,   
        C.KMRealizado,
        C.ViagensRealizadas,
        C.Diferenca,
        C.DiferencaViagens
      FROM
        #FCVProgReal C
