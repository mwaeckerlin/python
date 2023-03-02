FROM mwaeckerlin/very-base AS build
RUN $PKG_INSTALL python3
RUN for file in \
    /usr/bin/python \
    /usr/lib/python* \
    $(ldd /usr/bin/python | sed -n 's,.* \([^ ]*/lib/[^ ]*\) .*,\1,p'); \
    do \
    path=${file%/*}; \
    test -d /tmp/root/$path || mkdir -p /tmp/root/$path; \
    cp -La $file /tmp/root/$file; \
    done
RUN ls -R /tmp/root
RUN /usr/bin/python --version

FROM mwaeckerlin/scratch
ENV CONTAINERNAME    "python"
ENV PATH             ""
CMD                  ["/usr/bin/python", "main.py"]
USER "${RUN_USER}"
WORKDIR /app
COPY --from=build /tmp/root /
