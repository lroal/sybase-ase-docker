FROM ubuntu:20.04 as final
FROM ubuntu:20.04 as builder
ARG DOWNLOAD_URL
COPY resources/response_file.txt /tmp
RUN groupadd sybase && useradd -g sybase -s /bin/bash sybase

# needed by the ASE installer
RUN apt update \
&& apt upgrade -y \
&& apt -y install curl libaio1 unzip
RUN curl -L -o /tmp/ASE_Suite.linuxamd64.tgz ${DOWNLOAD_URL}
RUN cd /tmp && tar -xzf ASE_Suite.linuxamd64.tgz -C /tmp/ebf30399/
RUN cd /tmp ./ebf30399/setup.bin -f /tmp/response_file.txt -i silent -DAGREE_TO_SAP_LICENSE=true -DRUN_SILENT=true \
&& rm -rf /tmp/* \
&& rm -fr /opt/sap/shared/SAPJRE-* \
&& rm -fr /opt/sap/shared/ase/SAPJRE-* \
&& rm -fr /opt/sap/jre64 \
&& rm -fr /opt/sap/sybuninstall \
&& rm -fr /opt/sap/jConnect-16_0 \
&& rm -fr /opt/sap/jutils-3_0 \
&& rm -fr /opt/sap/ASE-16_0/bin/diag* \
&& rm -fr /opt/sap/OCS-16_0/devlib* \
&& rm -fr /opt/sap/SYBDIAG \
&& rm -fr /opt/sap/COCKPIT-4 \
&& rm -fr /opt/sap/WS-16_0 \
# we don't need non 64bit versions of the libs \
&& rm -fr /opt/sap/OCS-16_0/bin32 \
&& rm -fr /opt/sap/OCS-16_0/lib3p \
&& rm -fr /opt/sap/OCS-16_0/lib/*[!6][!4].a \
&& rm -fr /opt/sap/OCS-16_0/lib/*[!6][!4].so \
# remove graphical apps and java junks \
&& cd /opt/sap/ASE-16_0/bin && rm asecfg ddlgen *java sqlloc sqlupgrade srvbuild \
# remove useless packages \
&& apt -y remove curl unzip && apt -y autoremove \
#&& groupadd sybase && useradd -g sybase -s /bin/bash sybase &&  \
&& chown -R sybase:sybase /opt/sap
# && ["/bin/bash", "-c", "echo \"sybase\nsybase\" | (passwd sybase)"] \
ENV PATH=/home/sybase/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/sap/OCS-16_0/lib3p64/
COPY --chown=sybase resources/ase.rs /home/sybase/config/
# We create the database itself but then zip it and delete \
# the data folder to keep the image as small as possible. \
# This archive is unpacked in /data upon first launch. /data \
# should be bound to a Docker volume for persistence. \
RUN . /opt/sap/SYBASE.sh && $SYBASE/$SYBASE_ASE/bin/srvbuildres -r /home/sybase/config/ase.rs -D /opt/sap
RUN sed -i 's/PE=EE/PE=DE/g' /opt/sap/ASE-16_0/sysam/DB_TEST.properties
RUN sed -i 's/LT=EV/LT=DT/g' /opt/sap/ASE-16_0/sysam/DB_TEST.properties
RUN sed -i 's/PE=EE/PE=DE/g' /opt/sap/ASE-16_0/sysam/sysam.properties.template
RUN sed -i 's/LT=EV/LT=DT/g' /opt/sap/ASE-16_0/sysam/sysam.properties.template
COPY --chown=sybase resources/ase_start.sh /home/sybase/bin/
COPY --chown=sybase resources/ase_stop.sh /home/sybase/bin/
COPY --chown=sybase resources/entrypoint.sh /home/sybase/bin/
COPY --chown=sybase resources/to_utf8.sh /home/sybase/bin/
COPY --chown=sybase resources/health.sh /home/sybase/bin/
RUN /home/sybase/bin/to_utf8.sh
RUN tar -czf /tmp/data.tar.gz /data && rm -fr /data
#&& export LD_LIBRARY_PATH=/opt/sap/OCS-16_0/lib3p64/ \
#RUN chown -R sybase:sybase /home/sybase
#RUN . /opt/sap/SYBASE.sh && $SYBASE/$SYBASE_ASE/bin/charset -Usa -Psybase -SDB_TEST binary.srt utf8
#RUN /opt/sap/ASE-16_0/bin/charset -Usa -Psybase -SDB_TEST binary.srt utf8

FROM final
RUN apt update \
&& apt upgrade -y \
&& apt -y install libaio1 dos2unix \
&& apt -y autoremove
RUN groupadd sybase && useradd -g sybase -s /bin/bash sybase
RUN mkdir /opt/sap
RUN mkdir /home/sybase
RUN mkdir /docker-entrypoint.d

ENV LD_LIBRARY_PATH=/opt/sap/OCS-16_0/lib3p64/
ENV PATH=/home/sybase/bin:$PATH
COPY --from=builder --chown=sybase /tmp /tmp
COPY --from=builder --chown=sybase /opt/sap /opt/sap
COPY --from=builder --chown=sybase /home/sybase /home/sybase
HEALTHCHECK --interval=3s --timeout=0.5s \
  CMD /home/sybase/bin/health.sh || exit 1
EXPOSE 5000
ENTRYPOINT ["/home/sybase/bin/entrypoint.sh"]