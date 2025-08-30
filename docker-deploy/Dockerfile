FROM public.ecr.aws/sam/build-nodejs18.x:latest

# Install additional tools
RUN yum update -y && \
    yum install -y git curl jq && \
    yum clean all

# Set working directory
WORKDIR /app

# Copy application files
COPY . .

# Install dependencies
RUN npm install --prefix src/handlers/hello-world/ && \
    npm install --prefix src/layers/common/nodejs/

# Make scripts executable
RUN chmod +x deploy-anywhere.sh && \
    chmod +x infrastructure/scripts/*.sh && \
    chmod +x governance/*.sh && \
    chmod +x testing/*.sh

# Set entrypoint
ENTRYPOINT ["./deploy-anywhere.sh"]
